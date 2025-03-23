//
//  WeaponComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import RealityKit

public struct WeaponComponent: Codable, Component {
    public var lastShotTime: Float = 0
    public var fireRate: Float = 0
    public var damage: Float = 10
}

public struct WeaponRuntimeComponent: Component {
    public var target: Entity? 
}
