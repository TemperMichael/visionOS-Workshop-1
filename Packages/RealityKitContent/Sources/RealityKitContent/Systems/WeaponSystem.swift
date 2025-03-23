//
//  ShootSystem.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import Combine
import Foundation
import RealityKit

@MainActor
public struct WeaponSystem: System {
    
    public static let query = EntityQuery(where: .has(WeaponComponent.self))
    
    private var subscriptions = [Cancellable]()
    
    let bulletEntity = ModelEntity(mesh: .generateSphere(radius: 0.01),
                                   materials: [SimpleMaterial(color: .black, isMetallic: true)])

    public init(scene: RealityKit.Scene) {
        subscriptions.append(scene.subscribe(to: ComponentEvents.DidAdd.self, componentType: WeaponComponent.self, { event in
            guard event.entity.components[WeaponRuntimeComponent.self] == nil else { return }
            event.entity.components[WeaponRuntimeComponent.self] = WeaponRuntimeComponent()
        }))
    }
    
    public func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var weaponComponent = entity.components[WeaponComponent.self],
                  var weaponRuntimeComponent = entity.components[WeaponRuntimeComponent.self] else { continue }
            defer {
                entity.components[WeaponComponent.self] = weaponComponent
                entity.components[WeaponRuntimeComponent.self] = weaponRuntimeComponent
            }
            
            weaponComponent.lastShotTime += Float(context.deltaTime)
            
            if weaponComponent.lastShotTime >= weaponComponent.fireRate,
                let target = weaponRuntimeComponent.target,
               target.parent != nil {
                shoot(
                    from: entity,
                    to: target,
                    component: &weaponComponent,
                    runtimeComponent: &weaponRuntimeComponent
                )
                weaponComponent.lastShotTime = 0
            }
        }
    }
    
    private func shoot(
        from entity: Entity,
        to target: Entity,
        component: inout WeaponComponent,
        runtimeComponent: inout WeaponRuntimeComponent
    ) {
        let bullet = bulletEntity.clone(recursive: true)
        
        bullet.generateCollisionShapes(recursive: true)
        
        let ground = entity.scene?.findEntity(named: "GameRoot")
        ground?.addChild(bullet)

        bullet.components.set(BulletComponent(damage: component.damage))
        bullet.setPosition(entity.position(relativeTo: nil), relativeTo: nil)
                
        bullet.move(
            to: target.transformMatrix(relativeTo: nil),
            relativeTo: nil,
            duration: 1,
            timingFunction: .linear
        )
    }
}
