// Face It for Mac.
// One quote on your desktop, behind your windows, changing every 10 seconds.
// Drag it anywhere. Click it for the next quote. Menu bar icon: font, size, quit.
import SwiftUI
import AppKit
import CoreText

// MARK: Words

let affirmations: [String] = [
    "I am worthy of success and happiness.",
    "I am capable of achieving my goals.",
    "I am grateful for the abundance in my life.",
    "I embrace challenges as opportunities to grow.",
    "I am in control of my destiny.",
    "I believe in myself.",
    "I attract success and prosperity.",
    "I am confident in my abilities and decisions.",
    "I am open to new possibilities and opportunities.",
    "I am resilient and can overcome any obstacle.",
    "Every effort I make moves me closer to my goals.",
    "I confidently take risks that lead to success.",
    "When I feel fear, I face it and fight it to win.",
    "Every challenge I overcome strengthens my path to success.",
    "I am enough, and my worth is not tied to external achievements."
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

// MARK: Fonts

enum Face: String, CaseIterable {
    case bebas = "Bebas Neue", playfair = "Playfair Display", cormorant = "Cormorant Garamond", system = "SF Pro"
    func font(_ scale: Double) -> Font {
        switch self {
        case .bebas:     return .custom("BebasNeue-Regular", size: 52 * scale)
        case .playfair:  return .custom("PlayfairDisplay-Italic", size: 34 * scale)
        case .cormorant: return .custom("Cormorant Garamond", size: 40 * scale).italic().weight(.medium)
        case .system:    return .system(size: 30 * scale, weight: .semibold, design: .default)
        }
    }
    var tracking: CGFloat { self == .bebas ? 1.5 : 0 }
    var lineSpacing: CGFloat { self == .bebas ? -2 : 4 }
}

func registerFonts() {
    guard let dir = Bundle.main.resourceURL,
          let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }
    for url in files where url.pathExtension.lowercased() == "ttf" {
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}

// MARK: App

@main
struct FaceItApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene { Settings { EmptyView() } }
}

extension Notification.Name { static let nextQuote = Notification.Name("FaceItNextQuote") }

// Transparent layer on top: drag moves the window, a plain click shows the next quote.
final class DragView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { frame.contains(point) ? self : nil }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseDown(with event: NSEvent) {
        guard let w = window else { return }
        let before = w.frame.origin
        w.performDrag(with: event)
        let after = w.frame.origin
        if abs(after.x - before.x) < 2 && abs(after.y - before.y) < 2 {
            NotificationCenter.default.post(name: .nextQuote, object: nil)
        } else {
            UserDefaults.standard.set(NSStringFromPoint(after), forKey: "origin")
        }
    }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .openHand) }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    let w: CGFloat = 640, h: CGFloat = 280

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        registerFonts()

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: w, height: h),
                          styleMask: [.borderless], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let root = NSView(frame: NSRect(x: 0, y: 0, width: w, height: h))
        let host = NSHostingView(rootView: QuoteView())
        host.frame = root.bounds
        host.autoresizingMask = [.width, .height]
        let drag = DragView(frame: root.bounds)
        drag.autoresizingMask = [.width, .height]
        root.addSubview(host)
        root.addSubview(drag)
        window.contentView = root
        place()
        window.orderFront(nil)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.title = "\u{201C}"
        buildMenu()
    }

    func place() {
        if let s = UserDefaults.standard.string(forKey: "origin") {
            let p = NSPointFromString(s)
            if NSScreen.screens.contains(where: { $0.frame.contains(NSPoint(x: p.x + 20, y: p.y + 20)) }) {
                window.setFrameOrigin(p); return
            }
        }
        guard let v = NSScreen.main?.visibleFrame else { return }
        window.setFrameOrigin(NSPoint(x: v.maxX - w - 40, y: v.maxY - h - 40))
    }

    func header(_ t: String, _ m: NSMenu) {
        let i = NSMenuItem(title: t, action: nil, keyEquivalent: ""); i.isEnabled = false; m.addItem(i)
    }

    func buildMenu() {
        let d = UserDefaults.standard
        let menu = NSMenu()
        let next = NSMenuItem(title: "Next quote", action: #selector(nextQuote), keyEquivalent: "n")
        next.target = self; menu.addItem(next)
        menu.addItem(.separator())
        header("Font", menu)
        let face = d.string(forKey: "face") ?? Face.bebas.rawValue
        for f in Face.allCases {
            let i = NSMenuItem(title: f.rawValue, action: #selector(pickFace(_:)), keyEquivalent: "")
            i.target = self; i.representedObject = f.rawValue; i.state = f.rawValue == face ? .on : .off
            menu.addItem(i)
        }
        menu.addItem(.separator())
        header("Size", menu)
        let cur = d.object(forKey: "scale") as? Double ?? 1.0
        for (n, v) in [("Small", 0.75), ("Medium", 1.0), ("Large", 1.3)] {
            let i = NSMenuItem(title: n, action: #selector(pickScale(_:)), keyEquivalent: "")
            i.target = self; i.representedObject = v; i.state = v == cur ? .on : .off
            menu.addItem(i)
        }
        menu.addItem(.separator())
        let reset = NSMenuItem(title: "Reset position", action: #selector(resetPosition), keyEquivalent: "")
        reset.target = self; menu.addItem(reset)
        menu.addItem(NSMenuItem(title: "Quit Face It", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func nextQuote() { NotificationCenter.default.post(name: .nextQuote, object: nil) }
    @objc func pickFace(_ s: NSMenuItem) { UserDefaults.standard.set(s.representedObject as? String, forKey: "face"); buildMenu() }
    @objc func pickScale(_ s: NSMenuItem) { if let v = s.representedObject as? Double { UserDefaults.standard.set(v, forKey: "scale"); buildMenu() } }
    @objc func resetPosition() { UserDefaults.standard.removeObject(forKey: "origin"); place() }
}

// MARK: View

struct QuoteView: View {
    @AppStorage("face") private var faceRaw: String = Face.bebas.rawValue
    @AppStorage("scale") private var scale: Double = 1.0
    @State private var lines: [String] = Self.mixed()
    @State private var i = 0
    @State private var tick = 0
    private let timer = Timer.publish(every: secondsPerLine, on: .main, in: .common).autoconnect()

    static func mixed() -> [String] {
        let a = affirmations.shuffled(), g = gratitude.shuffled()
        var out: [String] = []
        for k in 0..<max(a.count, g.count) {
            if k < a.count { out.append(a[k]) }
            if k < g.count { out.append(g[k]) }
        }
        return out
    }

    func advance() {
        withAnimation(.easeInOut(duration: 1.1)) {
            if i + 1 < lines.count { i += 1 } else { lines = Self.mixed(); i = 0 }
        }
    }

    var body: some View {
        let face = Face(rawValue: faceRaw) ?? .bebas
        ZStack {
            Text("\u{201C}\(lines[i])\u{201D}")
                .font(face.font(scale))
                .tracking(face.tracking)
                .lineSpacing(face.lineSpacing)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.4)
                .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
                .shadow(color: .black.opacity(0.45), radius: 18, y: 4)
                .padding(24)
                .id(i)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 8)).combined(with: .scale(scale: 0.98)),
                    removal: .opacity.combined(with: .offset(y: -8))))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(timer) { _ in advance() }
        .onReceive(NotificationCenter.default.publisher(for: .nextQuote)) { _ in advance() }
    }
}
