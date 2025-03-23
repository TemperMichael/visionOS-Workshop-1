//
//  BulletComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import RealityKit

public struct BulletComponent: Codable, Component {
    public var damage: Float = 0
    
    init(damage: Float) {
        self.damage = damage
    }
}
