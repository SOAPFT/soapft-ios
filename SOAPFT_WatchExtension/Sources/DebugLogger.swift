//
//  DebugLogger.swift
//  SOAPFT
//
//  Created by 바견규 on 8/8/25.
//

import Foundation
import Combine

final class DebugLogger: ObservableObject {
    static let shared = DebugLogger()

    @Published var logs: [String] = []

    private init() {}

    func log(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = Self.timestamp()
            self.logs.append("[\(timestamp)] \(message)")
            if self.logs.count > 100 {
                self.logs.removeFirst()
            }
        }
        print(message)
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}
