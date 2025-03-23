//
//  SpawnSystem.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import Foundation
import RealityKit

@MainActor
public struct SpawnSystem: System {
    
    public static let query = EntityQuery(where: .has(SpawnerComponent.self))
    
    private var elapsedTime: TimeInterval = 0
    private var spawnIndex = 0
    
    public init(scene: RealityKit.Scene) { }
    
    public mutating func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var spawnerComponent = entity.components[SpawnerComponent.self],
                  spawnerComponent.isActive,
                  context.scene.performQuery(EntityQuery(where: .has(SpawnableComponent.self))).count(where: { $0.components[SpawnableComponent.self]?.spawnerId == entity.id }) < spawnerComponent.spawnMaximum else { continue }
            
            defer { entity.components[SpawnerComponent.self] = spawnerComponent }
            
            if elapsedTime == 0 {
                spawnEntity(in: entity)
            }
            
            elapsedTime += context.deltaTime
            
            if elapsedTime >= spawnerComponent.spawnRate {
                elapsedTime = 0
            }
            
            if spawnerComponent.shouldDecreaseSpawnRate &&
                spawnerComponent.spawnRate > spawnerComponent.minimumSpawnRate {
                spawnerComponent.spawnRate -= spawnerComponent.rateDecrementalFactor
            }
        }
    }
    
    // TODO: Task 2, Step 2 - Load entity from Reality Composer Pro
    private func loadEntity() async -> Entity? {
        return try? await Entity(named: "Prefabs/Enemy", in: realityKitContentBundle)
    }
    
    private func spawnEntity(in parent: Entity) {
        Task {
            guard let entity = await loadEntity() else {
                print("⚠️ Failed to load entity from Reality Composer Pro")
                return
            }
            
            let identifier = "ScaleIndependentEntity"
            let scaleIndependentEntity = parent.children.first(where: { $0.name == identifier }) ?? Entity()
            
            if parent.children.first(where: { $0.name == identifier }) == nil {
                scaleIndependentEntity.name = identifier
                parent.addChild(scaleIndependentEntity)
                scaleIndependentEntity.transform.scale = 1 / parent.scale
            }
            
            entity.children.first?.components.set(SpawnableComponent(spawnerId: parent.id))
            entity.children.first?.components.set(HoverEffectComponent())
            scaleIndependentEntity.addChild(entity)
            
            let randomYPosition: Float = Array(stride(from: 0.6, to: 1.8, by: 0.2)).randomElement()!
            entity.position = [0, randomYPosition, 0]
            
            entity.availableAnimations.forEach { entity.playAnimation($0.repeat()) }

            let spintClockWise = Bool.random()
            
            let orbitAnimation = OrbitAnimation(
                duration: 10,
                axis: [0, 1, 0],
                startTransform: randomTransform(around: entity.position, spintClockWise: spintClockWise),
                spinClockwise: spintClockWise,
                orientToPath: true,
                bindTarget: .transform,
                repeatMode: .repeat
            )
            
            if let animationResource = try? AnimationResource.generate(with: orbitAnimation) {
                entity.playAnimation(animationResource)
            }
            
            if let audioResource = entity.children.first?.components[AudioLibraryComponent.self]?.resources.first {
                entity.children.first?.playAudio(audioResource.value)
            }
        }
    }
    
    private func randomTransform(
        around center: SIMD3<Float>,
        innerRadius: Float = 0.4,
        outerRadius: Float = 0.8,
        spintClockWise: Bool
    ) -> Transform {
        let angle = Float.random(in: 0...(2 * .pi)) // Random angle in radians
        let radius = Float.random(in: innerRadius...outerRadius) // Random distance within bounds
        let x = center.x + radius * cos(angle)
        let z = center.z + radius * sin(angle)
        
        // Compute the direction from the center to the new position
        let direction = normalize(SIMD3<Float>(x, center.y, z) - center)

        // Calculate rotation so entity faces outward (yaw rotation)
        let yaw = atan2(direction.x, direction.z) + .pi / 2 * (spintClockWise ? -1 : 1) // Get angle in radians
        let rotation = simd_quatf(angle: yaw, axis: [0, 1, 0]) // Rotate around Y-axis

        return Transform(rotation: rotation, translation: SIMD3<Float>(x, center.y, z))
    }
}
