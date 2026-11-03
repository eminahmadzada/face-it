// Face It widgets for the Mac desktop.
// Replace every file in the widget extension folder with this one file.
import WidgetKit
import SwiftUI

// MARK: Words

let affirmations: [String] = [
    "I am very capable and clever. I learn fast and I solve hard problems.",
    "My mind is sharp. I see the answer others miss.",
    "I trust my judgement. I earned it through years of hard work.",
    "I can figure out anything I put my mind to.",
    "I bring real value to my colleagues and my employer every single day.",
    "I make my partner's life better. I am her calm, her strength and her safe place.",
    "My family is proud of me, and I make them prouder every year.",
    "People are better off after working with me.",
    "My work matters, and the people around me feel it.",
    "I walk into every room calm, confident and ready.",
    "Pressure makes me focused, not afraid.",
    "I do not need anyone's permission to be great.",
    "I am proud of who I am and who I am becoming.",
    "I speak clearly and with confidence. People listen when I talk.",
    "I make complex things simple. That is my gift.",
    "I listen deeply, and people feel understood around me.",
    "I say what I think, kindly and directly.",
    "I enjoy meeting new people, and they enjoy meeting me.",
    "I connect people and ideas. Doors open because of the bridges I build.",
    "I remember people, I follow up, and I keep my relationships warm.",
    "I give before I ask, and my network grows every week.",
    "I always achieve what I plan, because I work hard and I do not quit.",
    "When I decide, I deliver.",
    "Every small win today builds the big win I am working for.",
    "Hard work is my edge, and I never run out of it.",
    "Success is my normal. I build it one day at a time."
]

let gratitude: [(String, String)] = [
    ("If you are grateful, I will surely give you more.", "Quran 14:7"),
    ("So remember Me, I will remember you. Be grateful to Me and do not deny Me.", "Quran 2:152"),
    ("So which of the favours of your Lord would you deny?", "Quran 55:13"),
    ("If you tried to count the blessings of Allah, you could never number them.", "Quran 14:34"),
    ("Whoever is grateful, is grateful for the good of his own soul.", "Quran 31:12"),
    ("My Lord, enable me to be grateful for the favour You have given me and my parents, and to do good that pleases You.", "Quran 27:19"),
    ("Indeed, with hardship comes ease.", "Quran 94:6"),
    ("A person will have nothing except what he strives for.", "Quran 53:39"),
    ("Allah does not change the condition of a people until they change what is in themselves.", "Quran 13:11"),
    ("Once you have decided, put your trust in Allah.", "Quran 3:159"),
    ("Whoever puts his trust in Allah, He is enough for him.", "Quran 65:3"),
    ("Allah does not burden a soul beyond what it can bear.", "Quran 2:286"),
    ("We made you into nations and tribes so that you may know one another.", "Quran 49:13"),
    ("And speak good words to people.", "Quran 2:83"),
    ("Whoever does not thank people has not thanked Allah.", "Hadith, Abu Dawud and Tirmidhi"),
    ("How wonderful is the affair of the believer. If good comes to him, he is grateful, and that is good for him. If hardship comes, he is patient, and that is good for him.", "Hadith, Sahih Muslim"),
    ("Look at those below you and not at those above you, so you do not belittle the blessings of Allah upon you.", "Hadith, Sahih Muslim"),
    ("The strong believer is better and more beloved to Allah than the weak believer. Strive for what benefits you, seek help from Allah, and do not give up.", "Hadith, Sahih Muslim"),
    ("Allah loves that when one of you does a job, he does it with excellence.", "Hadith, al Bayhaqi"),
    ("The best of people are those most beneficial to people.", "Hadith, al Tabarani"),
    ("Your smile in the face of your brother is charity.", "Hadith, Tirmidhi"),
    ("Tie your camel, then put your trust in Allah.", "Hadith, Tirmidhi"),
    ("Alhamdulillah ala kulli hal. Praise be to Allah in every situation.", "Hadith, Ibn Majah")
]

// A new pair every 3 hours.
let slotSeconds: Double = 3 * 60 * 60
func slot(for date: Date) -> Int { Int(date.timeIntervalSince1970 / slotSeconds) }

// MARK: Timeline

struct WordsEntry: TimelineEntry {
    let date: Date
    let index: Int
    var affirmation: String { affirmations[index % affirmations.count] }
    var grat: (String, String) { gratitude[(index * 7 + 3) % gratitude.count] }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WordsEntry {
        WordsEntry(date: Date(), index: 0)
    }
    func getSnapshot(in context: Context, completion: @escaping (WordsEntry) -> Void) {
        completion(WordsEntry(date: Date(), index: slot(for: Date())))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WordsEntry>) -> Void) {
        let now = slot(for: Date())
        let entries = (0..<8).map { k in
            WordsEntry(date: Date(timeIntervalSince1970: Double(now + k) * slotSeconds), index: now + k)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: Style

let bg = Color(red: 0.043, green: 0.055, blue: 0.075)
let green = Color(red: 0.404, green: 0.875, blue: 0.439)
let soft = Color(red: 0.902, green: 0.910, blue: 0.929)
let muted = Color(red: 0.545, green: 0.580, blue: 0.620)

struct Tag: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(1)
            .foregroundStyle(color)
    }
}

struct AffirmationBlock: View {
    let entry: WordsEntry
    var size: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Tag(text: "I am", color: green)
            Text(entry.affirmation)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(soft)
                .minimumScaleFactor(0.5)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GratitudeBlock: View {
    let entry: WordsEntry
    var size: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Tag(text: "Alhamdulillah", color: muted)
            Text(entry.grat.0)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(soft)
                .minimumScaleFactor(0.5)
            Text(entry.grat.1)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(green)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: Widgets

struct AffirmationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FaceItAffirmation", provider: Provider()) { entry in
            AffirmationBlock(entry: entry, size: 17)
                .containerBackground(bg, for: .widget)
        }
        .configurationDisplayName("Affirmation")
        .description("A new affirmation every 3 hours.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct GratitudeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FaceItGratitude", provider: Provider()) { entry in
            GratitudeBlock(entry: entry, size: 15)
                .containerBackground(bg, for: .widget)
        }
        .configurationDisplayName("Gratitude")
        .description("Quran and hadith on gratitude, every 3 hours.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct BothWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FaceItBoth", provider: Provider()) { entry in
            VStack(alignment: .leading, spacing: 14) {
                AffirmationBlock(entry: entry, size: 19)
                Divider().overlay(muted.opacity(0.3))
                GratitudeBlock(entry: entry, size: 16)
            }
            .containerBackground(bg, for: .widget)
        }
        .configurationDisplayName("Face It")
        .description("Affirmation and gratitude together.")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct FaceItWidgets: WidgetBundle {
    var body: some Widget {
        BothWidget()
        AffirmationWidget()
        GratitudeWidget()
    }
}
