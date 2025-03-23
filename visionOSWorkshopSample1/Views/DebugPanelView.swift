//
//  DebugPanelView.swift
//  visionOSWorkshopSample1
//
//  Created by Tempuno e.U. on 08.03.25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct DebugPanelView: View {
    @State var debugState: DebugState
    @State private var searchText = ""
    
    var searchResults: [DebugState.Log] {
        if searchText.isEmpty {
            return debugState.logs
        } else {
            return debugState.logs.filter { $0.message.contains(searchText) || "\($0.number)".contains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
                List {
                    ForEach(searchResults.reversed()) { log in
                        Text("\(log.number): \(log.message)")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .foregroundStyle(log.isHighlighted ? .blue : .white)
                            .onTapGesture {
                                debugState.logs[log.number].isHighlighted.toggle()
                            }
                            .listRowBackground(Color.clear)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Toggle(isOn: $debugState.filterHighlights) {
                            Text("Filter highlights")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Toggle(isOn: $debugState.shouldLog) {
                            Text("Log enabled")
                        }
                    }
                    
                    ToolbarItem(placement: .bottomOrnament) {
                        Button(action: {
                            debugState.logger("-----------------------")
                        }, label: { Text("Add seperator")})
                        .buttonStyle(.bordered)
                    }
                    
                    ToolbarItem(placement: .bottomOrnament) {
                        Button(action: {
                            let nonHighlightedLogs = debugState.logs.filter({ !$0.isHighlighted })
                            debugState.logs.removeAll(where: { log in nonHighlightedLogs.contains(where: { $0.id == log.id }) })
                        }, label: { Text("Clear Non-highlights")})
                        .buttonStyle(.bordered)
                    }
                    
                    ToolbarItem(placement: .bottomOrnament) {
                        Button(action: {
                            debugState.logs.enumerated().forEach { index, _ in
                                debugState.logs[index].isHighlighted = false
                            }
                        }, label: { Text("Clear highlights")})
                        .buttonStyle(.bordered)
                        .tint(.orange)
                    }
                    
                    ToolbarItem(placement: .bottomOrnament) {
                        Button(action: {
                            debugState.logs.removeAll()
                        }, label: { Text("Clear logs")})
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .overlay {
                    if !debugState.logs.isEmpty && searchResults.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 32).fill(.thickMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .navigationTitle("Logs")
            }
            .searchable(text: $searchText)
            .padding()
    }
}

#Preview {
    @Previewable @State var debugState = DebugState()
    DebugPanelView(debugState: debugState)
}
