//
//  ViewModel+Extensions.swift
//  visionOSWorkshopSample1
//
//  Created by Tempuno e.U. on 08.03.25.
//

import Foundation

extension ViewModel {
    
    func printLog(_ message: String?) {
        debugState?.logger(message ?? "nil")
    }
}
