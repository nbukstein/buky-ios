//
//  Item.swift
//  Buky
//
//  Created by Nicolas Bukstein on 28/1/26.
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
