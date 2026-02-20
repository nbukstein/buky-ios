import Foundation

struct ReadingTip: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let subtitle: String

    static let all: [ReadingTip] = [
        ReadingTip(
            id: 0,
            icon: "🎭",
            title: String(localized: "Use different voices and emotions", comment: "Reading tip title about using character voices"),
            subtitle: String(localized: "Bring each character to life with a unique voice. If Luna the rabbit is scared, lower your tone; if Rayo the fox is running, speed up your pace. Children engage much more when they feel the story is coming alive.", comment: "Reading tip description encouraging parents to vary their voice for each character")
        ),
        ReadingTip(
            id: 1,
            icon: "⏸️",
            title: String(localized: "Make dramatic pauses", comment: "Reading tip title about pausing for suspense"),
            subtitle: String(localized: "Before revealing something exciting, pause for a few seconds. That silence builds anticipation and keeps the child's attention. \"And then... she opened the door and saw...\" — wait a moment before continuing.", comment: "Reading tip description explaining how pauses build suspense")
        ),
        ReadingTip(
            id: 2,
            icon: "❓",
            title: String(localized: "Involve them with questions", comment: "Reading tip title about asking the child questions"),
            subtitle: String(localized: "At key moments, ask things like \"What do you think is going to happen?\" or \"What would you do in their place?\". This activates their imagination and makes them feel like part of the story.", comment: "Reading tip description about engaging children with questions during the story")
        ),
        ReadingTip(
            id: 3,
            icon: "🖐️",
            title: String(localized: "Let them interact", comment: "Reading tip title about physical participation"),
            subtitle: String(localized: "Ask them to make the sound of the wind, roar like an animal, or point out colors in the illustrations. Physical participation reinforces learning and makes the experience more memorable.", comment: "Reading tip description encouraging physical interaction during reading")
        ),
        ReadingTip(
            id: 4,
            icon: "💡",
            title: String(localized: "Connect the story to their life", comment: "Reading tip title about relating the story to real life"),
            subtitle: String(localized: "When it's over, relate the moral to something real: \"Remember when you also helped your friend, just like Flora did?\". This makes the educational message truly land and stick with them.", comment: "Reading tip description about connecting the story's moral to the child's experiences")
        )
    ]
}
