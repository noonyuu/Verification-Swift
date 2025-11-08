//
//  Item.swift
//  Verification
//
//  Created by shimizu on 2025/10/10.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
