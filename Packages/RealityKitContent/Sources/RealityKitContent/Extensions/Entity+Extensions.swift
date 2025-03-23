//
//  Entity+Extensions.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 09.03.25.
//

import RealityKit

public extension Entity {
    
    func firstEntity<T: Component>(withComponent componentClass: T.Type, _ closure: (Entity, T) -> Void) {
        if let component = components[componentClass] {
            closure(self, component)
            return
        }
        
        for child in children {
            if let component = child.components[componentClass] {
                closure(child, component)
                return
            }
            
            child.firstEntity(withComponent: componentClass, closure)
        }
    }
    
    func forEachDescendant(_ closure: (Entity) -> Void) {
        for child in children {
            closure(child)
            child.forEachDescendant(closure)
        }
    }
}
