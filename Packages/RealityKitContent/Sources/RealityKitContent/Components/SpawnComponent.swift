//
//  SpawnComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import RealityKit

public struct SpawnerComponent: Codable, Component {
    public var isActive = false
    public var spawnMaximum = 8
    public var spawnRate: Double = 3
    public var minimumSpawnRate: Double = 0.5
    public var shouldDecreaseSpawnRate: Bool = false
    public var rateDecrementalFactor: Double = 0.0001
}

public struct SpawnableComponent: Codable, Component {
    public var spawnerId: UInt64? = nil
    
    init(spawnerId: UInt64? = nil) {
        self.spawnerId = spawnerId
    }
}
