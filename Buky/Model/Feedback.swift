//
//  Feedback.swift
//  Buky
//

import Foundation

struct Feedback: Encodable {
    let userId: String
    let storyId: String
    let rating: Bool
    let characters: [String]
    let lesson: String
    let tone: String
    let narrativeStructure: String
    let place: String
}
