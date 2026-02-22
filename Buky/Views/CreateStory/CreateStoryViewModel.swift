//
//  CreateStoryViewModel.swift
//  Buky
//
//  Created by Nicolas Bukstein on 5/2/26.
//

import SwiftUI

@MainActor
final class CreateStoryViewModel: ObservableObject {
    @Published var childAgeIndex: Int? {
        didSet {
            if let index = childAgeIndex {
                let age = Story.ChildAge.allCases[index]
                AnalyticsManager.shared.trackStoryConfigurationSelected(
                    configurationType: "child_age",
                    value: age.ageRange
                )
            }
        }
    }

    @Published var storyLengthIndex: Int? {
        didSet {
            if let index = storyLengthIndex {
                let length = Story.TimeLength.allCases[index]
                AnalyticsManager.shared.trackStoryConfigurationSelected(
                    configurationType: "story_length",
                    value: length.apiValue
                )
            }
        }
    }

    @Published var placeIndex: Int? {
        didSet {
            if let index = placeIndex {
                let place = Story.Place.allCases[index]
                AnalyticsManager.shared.trackStoryConfigurationSelected(
                    configurationType: "place",
                    value: place.rawValue
                )
            }
        }
    }

    @Published var mainCharacterIndexes: [Int] = [] {
        didSet {
            if !mainCharacterIndexes.isEmpty {
                let characters = mainCharacterIndexes.map { Story.Characters.allCases[$0].rawValue }
                AnalyticsManager.shared.trackStoryConfigurationSelected(
                    configurationType: "characters",
                    value: characters.joined(separator: ", ")
                )
            }
        }
    }

    @Published var lessonIndex: Int? {
        didSet {
            if let index = lessonIndex {
                let lesson = Story.Lesson.allCases[index]
                AnalyticsManager.shared.trackStoryConfigurationSelected(
                    configurationType: "lesson",
                    value: lesson.rawValue
                )
            }
        }
    }

    @Published var animalTypeIndex: Int? {
        didSet {
            if let index = animalTypeIndex {
                let animalCases = Story.Characters.animals.subtypes
                if index < animalCases.count {
                    let animalType = animalCases[index]
                    AnalyticsManager.shared.trackStoryConfigurationSelected(
                        configurationType: "animal_type",
                        value: animalType.rawValue
                    )
                }
            }
        }
    }

    @Published var animalName: String = ""

    @Published var personTypeIndex: Int? {
        didSet {
            if let index = personTypeIndex {
                let peopleCases = Story.Characters.people.subtypes
                if index < peopleCases.count {
                    let personType = peopleCases[index]
                    AnalyticsManager.shared.trackStoryConfigurationSelected(
                        configurationType: "person_type",
                        value: personType.rawValue
                    )
                }
            }
        }
    }

    @Published var personName: String = ""

    private let storyLimitManager = StoryLimitManager.shared

    var canCreateStory: Bool { storyLimitManager.canCreateStory }
    var storiesRemaining: Int { storyLimitManager.storiesRemaining }

    func recordStoryCreation() { storyLimitManager.recordStoryCreation() }

    var isCreateStoryEnabled: Bool {
        return childAgeIndex != nil &&
        storyLengthIndex != nil &&
        placeIndex != nil &&
        mainCharacterIndexes.count > 0 &&
        lessonIndex != nil
    }

    private var selectedCharacters: [Story.Characters] {
        mainCharacterIndexes.map { Story.Characters.allCases[$0] }
    }

    var showAnimalSection: Bool { selectedCharacters.contains(.animals) }
    var showPeopleSection: Bool { selectedCharacters.contains(.people) }

    func onProtagonistsChanged() {
        if !showAnimalSection {
            animalTypeIndex = nil
            animalName = ""
        }
        if !showPeopleSection {
            personTypeIndex = nil
            personName = ""
        }
    }

    func createStory() -> Story {
        let story = Story()
        guard let childAgeIndex,
              let storyLengthIndex,
              let placeIndex,
              let lessonIndex else {
            fatalError("Story is not fully initialized")
        }

        story.childAge = Story.ChildAge.allCases[childAgeIndex]
        story.storyTimeLength = Story.TimeLength.allCases[storyLengthIndex]
        story.place = Story.Place.allCases[placeIndex]
        story.lesson = Story.Lesson.allCases[lessonIndex]
        for mainCharacterIndex in mainCharacterIndexes {
            story.characters.append(Story.Characters.allCases[mainCharacterIndex])
        }

        let animalCases = Story.Characters.animals.subtypes
        if let animalTypeIndex, animalTypeIndex < animalCases.count {
            story.animalType = animalCases[animalTypeIndex]
        }
        if !animalName.isEmpty {
            story.animalName = animalName
        }

        let peopleCases = Story.Characters.people.subtypes
        if let personTypeIndex, personTypeIndex < peopleCases.count {
            story.personType = peopleCases[personTypeIndex]
        }
        if !personName.isEmpty {
            story.personName = personName
        }

        if let languageCode = Locale.preferredLanguages.first {
            let locale = Locale(identifier: "en")
            let languageName = locale.localizedString(forLanguageCode: languageCode)
            story.language = languageName
        } else {
            story.language = "English"
        }
        story.dateCreated = Date()
        story.userId = UserStorageManager.shared.userID
        story.countryCode = Locale.current.region?.identifier
        return story
    }
}
