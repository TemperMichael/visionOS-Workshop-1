//
//  DebugState.swift
//  visionOSWorkshopSample1
//
//  Created by Tempuno e.U. on 08.03.25.
//

import Foundation

@Observable
public final class DebugState {
    public struct Log: Identifiable {
        public var id = UUID()
        public let number: Int
        public let message: String
        public var isHighlighted: Bool = false
    }
    
    public var logs: [Log] {
        get { filterHighlights ? fullLogs.filter({ $0.isHighlighted }) : fullLogs }
        set { fullLogs = newValue }
    }
    public var shouldLog = true
    public var filterHighlights = false
    
    var fullLogs = [Log]()

    public func logger(_ message: String) {
        guard shouldLog else { return }
        fullLogs.append(Log(number: logs.count, message: message))
    }

    public func logger2(_ message: String,
                  function: String = #function, file: String = #file, line: Int = #line) {
        let url = URL(fileURLWithPath: file)
        let filename = url.lastPathComponent
        let thread = Thread.isMainThread ? "(m)" : "(-)"
        logger("\(filename): \(function): L\(line): T\(thread): " + message)
    }
    
    public init(shouldLog: Bool = true) {
        self.shouldLog = shouldLog
    }
}
