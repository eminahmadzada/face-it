// Face It for Mac.
// One line on your desktop, behind your windows, changing every 10 seconds.
// Menu bar icon: position, text size, quit.
import SwiftUI
import AppKit

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

let gratitude: [String] = [
    "If you are grateful, I will surely give you more.",
    "So remember Me, I will remember you. Be grateful to Me and do not deny Me.",
    "So which of the favours of your Lord would you deny?",
    "If you tried to count the blessings of Allah, you could never number them.",
    "Whoever is grateful, is grateful for the good of his own soul.",
    "My Lord, enable me to be grateful for the favour You have given me and my parents, and to do good that pleases You.",
    "Indeed, with hardship comes ease.",
    "A person will have nothing except what he strives for.",
    "Allah does not change the condition of a people until they change what is in themselves.",
    "Once you have decided, put your trust in Allah.",
    "Whoever puts his trust in Allah, He is enough for him.",
    "Allah does not burden a soul beyond what it can bear.",
    "We made you into nations and tribes so that you may know one another.",
    "And speak good words to people.",
    "Whoever does not thank people has not thanked Allah.",
    "How wonderful is the affair of the believer. If good comes to him, he is grateful, and that is good for him. If hardship comes, he is patient, and that is good for him.",
    "Look at those below you and not at those above you, so you do not belittle the blessings of Allah upon you.",
    "The strong believer is better and more beloved to Allah than the weak believer. Strive for what benefits you, seek help from Allah, and do not give up.",
    "Allah loves that when one of you does a job, he does it with excellence.",
    "The best of people are those most beneficial to people.",
    "Your smile in the face of your brother is charity.",
    "Tie your camel, then put your trust in Allah.",
    "Alhamdulillah ala kulli hal. Praise be to Allah in every situation."
]

let secondsPerLine: Double = 10

// MARK: App

@main
struct FaceItApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene { Settings { EmptyView() } }
}

enum Spot: String, CaseIterable {
    case topRight = "Top right", topLeft = "Top left", center = "Center",
         bottomRight = "Bottom right", bottomLeft = "Bottom left"
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    let w: CGFloat = 560, h: CGFloat = 240

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)   // no Dock icon

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: w, height: h),
                          styleMask: [.borderless], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.contentView = NSHostingView(rootView: QuoteView())
        place()
        window.orderFront(nil)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.title = "\u{201C}"
        buildMenu()

        NotificationCenter.default.addObserver(self, selector: #selector(place),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    var spot: Spot {
        get { Spot(rawValue: UserDefaults.standard.string(forKey: "spot") ?? "") ?? .topRight }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "spot"); place(); buildMenu() }
    }

    @objc func place() {
        guard let s = NSScreen.main?.visibleFrame else { return }
        let m: CGFloat = 40
        let x: CGFloat, y: CGFloat
        switch spot {
        case .topRight:    x = s.maxX - w - m; y = s.maxY - h - m
        case .topLeft:     x = s.minX + m;     y = s.maxY - h - m
        case .center:      x = s.midX - w / 2; y = s.midY - h / 2
        case .bottomRight: x = s.maxX - w - m; y = s.minY + m
        case .bottomLeft:  x = s.minX + m;     y = s.minY + m
        }
        window.setFrame(NSRect(x: x, y: y, width: w, height: h), display: true)
    }

    func buildMenu() {
        let menu = NSMenu()
        let posTitle = NSMenuItem(title: "Position", action: nil, keyEquivalent: "")
        posTitle.isEnabled = false
        menu.addItem(posTitle)
        for s in Spot.allCases {
            let item = NSMenuItem(title: s.rawValue, action: #selector(pickSpot(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = s.rawValue
            item.state = s == spot ? .on : .off
            menu.addItem(item)
        }
        menu.addItem(.separator())
        let sizeTitle = NSMenuItem(title: "Text size", action: nil, keyEquivalent: "")
        sizeTitle.isEnabled = false
        menu.addItem(sizeTitle)
        let current = UserDefaults.standard.object(forKey: "size") as? Double ?? 26
        for (name, value) in [("Small", 20.0), ("Medium", 26.0), ("Large", 34.0)] {
            let item = NSMenuItem(title: name, action: #selector(pickSize(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = value
            item.state = value == current ? .on : .off
            menu.addItem(item)
        }
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Face It", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func pickSpot(_ sender: NSMenuItem) {
        if let raw = sender.representedObject as? String, let s = Spot(rawValue: raw) { spot = s }
    }
    @objc func pickSize(_ sender: NSMenuItem) {
        if let v = sender.representedObject as? Double { UserDefaults.standard.set(v, forKey: "size"); buildMenu() }
    }
}

// MARK: View

struct QuoteView: View {
    @AppStorage("size") private var size: Double = 26
    @State private var lines: [String] = Self.mixed()
    @State private var i = 0
    private let timer = Timer.publish(every: secondsPerLine, on: .main, in: .common).autoconnect()

    // Shuffled, alternating affirmation and gratitude.
    static func mixed() -> [String] {
        let a = affirmations.shuffled(), g = gratitude.shuffled()
        var out: [String] = []
        for k in 0..<max(a.count, g.count) {
            if k < a.count { out.append(a[k]) }
            if k < g.count { out.append(g[k]) }
        }
        return out
    }

    var body: some View {
        ZStack {
            Text("\u{201C}\(lines[i])\u{201D}")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .shadow(color: .black.opacity(0.55), radius: 8, y: 2)
                .padding(20)
                .id(i)
                .transition(.opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 1.2)) {
                if i + 1 < lines.count { i += 1 } else { lines = Self.mixed(); i = 0 }
            }
        }
    }
}
