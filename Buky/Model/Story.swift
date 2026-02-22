//
//  Story.swift
//  Buky
//
//  Created by Nicolas Bukstein on 29/1/26.
//

import Foundation
import SwiftData

@Model
final class Story: Codable {

    private enum CodingKeys: String, CodingKey {
        case text
        case dateCreated
        case childAge = "age"
        case storyTimeLength = "duration"
        case place
        case characters
        case lesson
        case language
        case characterName = "character_name"
        case animalType = "animal_type"
        case animalName = "animal_name"
        case personType = "person_type"
        case personName = "person_name"
        case userId = "userId"
        case countryCode = "countryCode"
    }

    enum ChildAge: Codable, CaseIterable {
        case oneThree
        case threeFive
        case fiveSeven
        case sevenNine

        var ageRange: String {
            switch self {
            case .oneThree: "1-3"
            case .threeFive: "3-5"
            case .fiveSeven: "5-7"
            case .sevenNine: "7-9"
            }
        }
    }

    enum TimeLength: Codable, CaseIterable {
        case short
        case medium
        case long

        var timeRange: String {
            switch self {
            case .short: "1-3"
            case .medium: "3-7"
            case .long: "7-10"
            }
        }

        var apiValue: String {
            switch self {
            case .short: "short"
            case .medium: "medium"
            case .long: "long"
            }
        }
    }

    enum Place: String, Codable, CaseIterable {
        case mountain
        case castlle
        case woods
        case sea
        case river
        case space
        case house
        case city
    }

    enum Characters: String, Codable, CaseIterable {
        case superhero
        case animals
        case people
        case dragons
        case princess
        case kings
    }

    enum Lesson: String, Codable, CaseIterable {
        case respect
        case empathy
        case friendship
        case love
        case sharing
        case brave
        case quiteness
        case perseverance
        case compassion
        case hope
        case determination
        case patience
        case generosity
        case joy
    }

    enum CharacterSubtype: String, Codable, CaseIterable {
        // Animals
        case dog
        case cat
        case frog
        case elephant
        case lion
        case butterfly
        case cow
        // People
        case uncle
        case aunt
        case brother
        case sister
        case cousinBoy
        case cousinGirl
        case grandpa
        case grandma
        case person
    }

    var text: String?
    var dateCreated: Date?
    var childAge: ChildAge?
    var storyTimeLength: TimeLength?
    var place: Place?
    var characters: [Characters]
    var lesson: Lesson?
    var language: String?
    var animalType: CharacterSubtype?
    var animalName: String?
    var personType: CharacterSubtype?
    var personName: String?
    var userId: String?
    var countryCode: String?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        dateCreated = nil //todo
        childAge = try container.decodeIfPresent(ChildAge.self, forKey: .childAge)
        storyTimeLength = try container.decodeIfPresent(TimeLength.self, forKey: .storyTimeLength)
        place = try container.decodeIfPresent(Place.self, forKey: .place)
        characters = try container.decodeIfPresent(Array<Characters>.self, forKey: .characters) ?? []
        lesson = try container.decodeIfPresent(Lesson.self, forKey: .lesson)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        animalType = try container.decodeIfPresent(CharacterSubtype.self, forKey: .animalType)
        animalName = try container.decodeIfPresent(String.self, forKey: .animalName)
        personType = try container.decodeIfPresent(CharacterSubtype.self, forKey: .personType)
        personName = try container.decodeIfPresent(String.self, forKey: .personName)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(dateCreated, forKey: .dateCreated)

        let childAgeString = childAge.map(\.ageRange) ?? ""
        try container.encodeIfPresent(childAgeString, forKey: .childAge)

        let storyTimeLengthString = storyTimeLength.map(\.apiValue) ?? ""
        try container.encodeIfPresent(storyTimeLengthString, forKey: .storyTimeLength)

        let charactersString  = characters.map { $0.rawValue }.joined(separator: ",")
        try container.encodeIfPresent(charactersString, forKey: .characters)

        try container.encodeIfPresent(place, forKey: .place)
        try container.encodeIfPresent(lesson, forKey: .lesson)
        try container.encodeIfPresent(language, forKey: .language)

        try container.encodeIfPresent(animalType, forKey: .animalType)
        try container.encodeIfPresent(animalName, forKey: .animalName)
        try container.encodeIfPresent(personType, forKey: .personType)
        try container.encodeIfPresent(personName, forKey: .personName)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
        var characterDescriptions: [String] = []

        if let animalType {
            let name = animalName ?? ""
            if name.isEmpty {
                characterDescriptions.append("\(animalType.englishArticle) \(animalType.englishName)")
            } else {
                characterDescriptions.append("\(animalType.englishArticle) \(animalType.englishName) called \(name)")
            }
        }

        if let personType {
            let name = personName ?? ""
            if name.isEmpty {
                characterDescriptions.append("\(personType.englishArticle) \(personType.englishName)")
            } else {
                characterDescriptions.append("\(personType.englishArticle) \(personType.englishName) called \(name)")
            }
        }

        if !characterDescriptions.isEmpty {
            try container.encode(characterDescriptions.joined(separator: ", "), forKey: .characterName)
        }
    }

    init(text: String?,
         dateCreated: Date,
         childAge: ChildAge,
         storyTimeLength: TimeLength,
         place: Place,
         characters: [Characters],
         lesson: Lesson,
         language: String,
         animalType: CharacterSubtype? = nil,
         animalName: String? = nil,
         personType: CharacterSubtype? = nil,
         personName: String? = nil,
         userId: String? = nil,
         countryCode: String? = nil
    ) {
        self.text = text
        self.dateCreated = dateCreated
        self.childAge = childAge
        self.storyTimeLength = storyTimeLength
        self.place = place
        self.characters = characters
        self.lesson = lesson
        self.language = language
        self.animalType = animalType
        self.animalName = animalName
        self.personType = personType
        self.personName = personName
        self.userId = userId
        self.countryCode = countryCode
    }

    init() {
        self.text = ""
        self.dateCreated = nil
        self.childAge = nil
        self.storyTimeLength = nil
        self.place = nil
        self.characters = []
        self.lesson = nil
        self.language = nil
        self.animalType = nil
        self.animalName = nil
        self.personType = nil
        self.personName = nil
        self.userId = nil
        self.countryCode = nil
    }
}
