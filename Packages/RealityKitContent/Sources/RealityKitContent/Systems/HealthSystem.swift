//
//  HealthSystem.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import Combine
import Foundation
import RealityKit

@MainActor
public struct HealthSystem: System {
    
    public static let query = EntityQuery(where: .has(HealthComponent.self))
    
    private var subscriptions = [Cancellable]()

    public init(scene: RealityKit.Scene) {
        subscriptions.append(scene.subscribe(to: ComponentEvents.DidAdd.self, componentType: HealthComponent.self, { event in
            guard let component = event.entity.components[HealthComponent.self] else { return }
            let healthBar = ModelEntity(mesh: .generateBox(width: 0.2, height: 0.01, depth: 0.01), materials: [UnlitMaterial(color: .green)])
            event.entity.components.set(HealthRuntimeComponent(healthBarEntity: healthBar))
            
            event.entity.firstEntity(withComponent: ModelComponent.self) { modelEntity, _ in
                guard let parent = modelEntity.parent, let root = event.entity.scene?.findEntity(named: "Root")  else { return }
                let identifier = "ScaleIndependentEntity"
                let scaleIndependentEntity = parent.children.first(where: { $0.name == identifier }) ?? Entity()
                
                if parent.children.first(where: { $0.name == identifier }) == nil {
                    scaleIndependentEntity.name = identifier
                    parent.addChild(scaleIndependentEntity)
                    scaleIndependentEntity.transform.scale = 1 / parent.scale(relativeTo: nil)
                    scaleIndependentEntity.transform.scale *= root.scale
                }
                
                scaleIndependentEntity.addChild(healthBar)
                
                healthBar.position.y = modelEntity.visualBounds(relativeTo: root).extents.y + component.healthBarOffset
            }
        }))
    }
    
    public func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var healthComponent = entity.components[HealthComponent.self],
                  var healthRuntimeComponent = entity.components[HealthRuntimeComponent.self] else { continue }
            defer {
                entity.components[HealthComponent.self] = healthComponent
                entity.components[HealthRuntimeComponent.self] = healthRuntimeComponent
            }
            
            updateHealth(
                for: entity,
                component: &healthComponent,
                runtimeComponent: &healthRuntimeComponent
            )
        }
    }
    
    // TODO: Task 3, Step 3 - Adapt scale of health bar when health changes
    // TODO: Task 3, Step 4 - Remove entity when health is zero
    // TODO: Task 3, Step 5 - Add health component to Enemy in Reality Composer Pro
    private func updateHealth(
        for entity: Entity,
        component: inout HealthComponent,
        runtimeComponent: inout HealthRuntimeComponent
    ) {
        if runtimeComponent.healthBarEntity.scale.x > 0 {
            runtimeComponent.healthBarEntity.scale.x = component.health * 0.01
            
            if runtimeComponent.healthBarEntity.scale.x <= 0 {
                runtimeComponent.healthBarEntity.scale.x = 0
                
                let container = Entity()
                entity.parent?.addChild(container)
                container.setPosition(entity.position(relativeTo: nil), relativeTo: nil)
                if let root = entity.scene?.findEntity(named: "Root") {
                    container.scale *= (1 / entity.scale(relativeTo: nil)) * root.scale
                }
                
                var particleEffect = ParticleEmitterComponent.Presets.impact
                particleEffect.timing = .once(warmUp: nil, emit: .init(duration: 0.1))
                particleEffect.particlesInheritTransform = true
                container.components[ParticleEmitterComponent.self] = particleEffect
                
                entity.removeFromParent()
            }
        }
    }
}
