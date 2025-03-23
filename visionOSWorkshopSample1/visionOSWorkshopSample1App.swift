//
//  visionOSWorkshopSample1App.swift
//  visionOSWorkshopSample1
//
//  Created by Tempuno e.U. on 08.03.25.
//

import RealityKitContent
import SwiftUI

// TODO: Task 1 - Familiarize yourself with Reality Composer Pro
// To open RCP, click on Packages -> RealityKitContent -> Package on your left in the inspector
// Then you can open RCP on the top right corner with the open "Open in Reality Composer Pro"
// Task 1, Step 1: Modify the Game Scene - Add new objects, change materials, add lights etc.
// Task 1, Step 2: Add trail particles to the enemy
// (Optional) Task 1, Step 3: Change texture of the sun

@main
struct visionOSWorkshopSample1App: App {

    @State private var viewModel = ViewModel()
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    let debugPanelIdentifier = "DebugPanel"
    @State private var debugState = DebugState()
    
    init() {
        registerSystemAndComponents()
    }
    
    func registerSystemAndComponents() {
        BulletComponent.registerComponent()
        EnemyComponent.registerComponent()
        HealthComponent.registerComponent()
        HealthRuntimeComponent.registerComponent()
        SpawnableComponent.registerComponent()
        SpawnerComponent.registerComponent()
        TargetComponent.registerComponent()
        WeaponComponent.registerComponent()
        WeaponRuntimeComponent.registerComponent()
        
        HealthSystem.registerSystem()
        SpawnSystem.registerSystem()
        WeaponSystem.registerSystem()
    }

    var body: some Scene {
        WindowGroup {
            GeometryReader3D { geometry in
                GameView()
                    .environment(viewModel)
                    .environment(debugState)
#if DEBUG
                    .onAppear {
                        viewModel.debugState = debugState
                    }
                    .ornament(attachmentAnchor: .scene(.bottomFront)) {
                        MenuView()
                            .environment(viewModel)
                    }
                    .onChange(of: viewModel.debugPanelOpen) { _, newValue in
                        newValue ? openWindow(id: debugPanelIdentifier) : dismissWindow(id: debugPanelIdentifier)
                    }
#endif
                    .onChange(of: geometry.size) { _, newValue in
                        let scale = geometry.size * 0.00035
                        viewModel.root.scale = .init(x: Float(scale.size.width),
                                                     y: Float(scale.size.height),
                                                     z: Float(scale.size.depth))
                        viewModel.root.position.y = -1 * Float(scale.size.height)
                    }
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 2, depth: 2, in: .meters)
        
        WindowGroup(id: debugPanelIdentifier) {
            DebugPanelView(debugState: debugState)
                .onDisappear { viewModel.debugPanelOpen = false }
        }
        .defaultSize(width: 800, height: 600)
        .defaultWindowPlacement { _, context in
            if let mainWindow = context.windows.first {
                return WindowPlacement(.trailing(mainWindow))
            }
            return WindowPlacement(.none)
        }
    }
}
