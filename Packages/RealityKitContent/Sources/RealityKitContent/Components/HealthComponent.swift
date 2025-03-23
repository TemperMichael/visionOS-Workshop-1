//
//  HealthComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import RealityKit

public struct HealthComponent: Codable, Component {
    public var health: Float = 100
    public var healthBarOffset: Float = 0
}

public struct HealthRuntimeComponent: Component {
    public var healthBarEntity: Entity
}
