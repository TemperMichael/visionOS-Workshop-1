//
//  ViewModel.swift
//  visionOSWorkshopSample1
//
//  Created by Tempuno e.U. on 08.03.25.
//

import RealityKit
import RealityKitContent
import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class ViewModel {
    
    let root: Entity = {
        $0.name = "Root"
        $0.position.y = -1
        return $0
    }(Entity())
    
    weak var debugState: DebugState?
    var debugPanelOpen = false
    
    var appState: AppState = .menu
    var score: Int = 0
    
    var targets: [Entity] = []
    
    // TODO: Task 2, Step 1 - Load entity from Reality Composer Pro
    func loadScene() async -> Entity? {
        return try? await Entity(named: "GameScene", in: realityKitContentBundle)
    }
    
    func startGame() {
        Task {
            if let scene = await loadScene() {
                score = 0
                
                targets.removeAll()
                root.children.removeAll()
                
                root.addChild(scene)
                
                root.scene?.performQuery(SpawnSystem.query).forEach {
                    $0.components[SpawnerComponent.self]?.isActive = true
                }
                
                appState = .playing
            }
        }
    }
    
    func stopGame() {
        appState = .menu
                
        root.scene?.performQuery(SpawnSystem.query).forEach {
            $0.components[SpawnerComponent.self]?.isActive = false
        }
        
        root.forEachDescendant {
            $0.stopAllAnimations()
            $0.stopAllAudio()
            $0.components.remove(ParticleEmitterComponent.self)
            $0.components.remove(WeaponComponent.self)
        }
        
        let gameOverText = ModelEntity(mesh: .generateText("Game Over", extrusionDepth: 0.01,
                                                           font: .systemFont(ofSize: 0.1),
                                                           alignment: .center),
                                       materials: [SimpleMaterial(color: .white, isMetallic: false)])
        gameOverText.position.x = -0.3

        let container = Entity()
        container.components.set(BillboardComponent())
        container.position.y = 0.5
        container.addChild(gameOverText)
        
        root.addChild(container)
    }
}
