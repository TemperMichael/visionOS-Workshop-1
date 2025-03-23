//
//  MenuView.swift
//  visionOSWorkshopSample1
//
//  Created by Tempuno e.U. on 09.03.25.
//

import SwiftUI

struct MenuView: View {
    
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        HStack {
            // TODO: Task 4, Step 2 - Add a button to start / stop the game
            // TODO: Task 4, Step 3 - Add a text view to show the current score

            Toggle(isOn: $viewModel.debugPanelOpen) {
                Image(systemName: "rectangle.and.text.magnifyingglass.rtl")
            }
            .toggleStyle(.button)
        }
    }
}

#Preview {
    MenuView()
}
