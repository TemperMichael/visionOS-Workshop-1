//
//  GameView.swift
//  visionOSWorkshopSample1
//
//  Created by Tempuno e.U. on 08.03.25.
//

import Combine
import SwiftUI
import RealityKit
import RealityKitContent

struct GameView: View {
    
    @Environment(ViewModel.self) var viewModel
    @Environment(DebugState.self) var debugState
    
    @State var subscriptions: [EventSubscription] = []

    var body: some View {
        RealityView { content in
            if let scene = await viewModel.loadScene() {
                viewModel.root.addChild(scene)
            }
            
            setupSubscriptions(for: content)
            
            // TODO: Task 4, Step 1 - Remove automatic game start
            // Should be commented out in final solution
            // viewModel.startGame()
            
            content.add(viewModel.root)
        }
        .gesture(SpatialTapGesture().targetedToEntity(where: .has(HealthComponent.self) && .has(EnemyComponent.self))
            .onEnded { event in
                guard viewModel.appState == .playing else { return }
                // TODO: Task 3, Step 6 - Reduce health of enemy by 50 when it gets tapped
                event.entity.components[HealthComponent.self]?.health -= 50
            }
        )
    }
    
    func setupSubscriptions(for content: RealityViewContent) {
        subscriptions.append(content.subscribe(to: ComponentEvents.DidAdd.self, componentType: TargetComponent.self, { event in
            guard !viewModel.targets.contains(event.entity) else { return }
            viewModel.targets.append(event.entity)
        }))
        
        subscriptions.append(content.subscribe(to: ComponentEvents.DidAdd.self, componentType: WeaponRuntimeComponent.self, { event in
            event.entity.components[WeaponRuntimeComponent.self]?.target = viewModel.targets.randomElement()
        }))
        
        subscriptions.append(content.subscribe(to: ComponentEvents.DidChange.self, componentType: HealthComponent.self, { event in
            guard let healthComponent = event.entity.components[HealthComponent.self] else { return }
            // TODO: Task 3, Step 7 - Stop game when target health is zero
            // TODO: Task 3, Step 8 - Increase score by 10 when enemy health is zero
            if healthComponent.health == 0  {
                if event.entity.components.has(TargetComponent.self) {
                    viewModel.stopGame()
                } else if event.entity.components.has(EnemyComponent.self) {
                    viewModel.score += 10
                }
            }
        }))
        
        subscriptions.append(content.subscribe(to: CollisionEvents.Began.self) { collisionEvent in
            if collisionEvent.entityA.components.has(TargetComponent.self),
               let bulletComponent = collisionEvent.entityB.components[BulletComponent.self] {
                // TODO: Task 3, Step 1 - Decrease health of target when bullet collides with it
                // TODO: Task 3, Step 2 - Remove bullet on collision
                collisionEvent.entityA.components[HealthComponent.self]?.health -= bulletComponent.damage
                collisionEvent.entityB.removeFromParent()
            }
        })
    }
}

#Preview(windowStyle: .volumetric) {
    GameView()
        .environment(ViewModel())
        .environment(DebugState())
}
