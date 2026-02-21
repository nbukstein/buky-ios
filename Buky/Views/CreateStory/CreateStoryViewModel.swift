//
//  CreateStoryViewModel.swift
//  Buky
//
//  Created by Nicolas Bukstein on 5/2/26.
//

import SwiftUI

@MainActor
final class CreateStoryViewModel: ObservableObject {
    @Published var childAgeIndex: Int?
    @Published var storyLengthIndex: Int?
    @Published var placeIndex: Int?
    @Published var mainCharacterIndexes: [Int] = []
    @Published var lessonIndex: Int?
    @Published var providerIndex: Int?

    @Published var animalTypeIndex: Int?
    @Published var animalName: String = ""
    @Published var personTypeIndex: Int?
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
        lessonIndex != nil &&
        providerIndex != nil
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
              let lessonIndex,
              let providerIndex else {
            fatalError("Story is not fully initialized")
        }

        story.childAge = Story.ChildAge.allCases[childAgeIndex]
        story.storyTimeLength = Story.TimeLength.allCases[storyLengthIndex]
        story.place = Story.Place.allCases[placeIndex]
        story.lesson = Story.Lesson.allCases[lessonIndex]
        story.provider = Story.AIProvider.allCases[providerIndex]
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
        return story
    }
}
