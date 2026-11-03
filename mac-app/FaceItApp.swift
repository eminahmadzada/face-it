// Face It for Mac.
// One quote on your desktop, behind your windows, changing every 10 seconds.
// Drag the middle to move it. Drag an edge or corner to resize it (the text grows with it).
// Click it for the next quote. Menu bar icon: font, quote marks, reset, quit.
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

let secondsPerLine: Double = 10

// MARK: Fonts

enum Face: String, CaseIterable {
    case bebas = "Bebas Neue", montserrat = "Montserrat", arial = "Arial", helvetica = "Helvetica Neue", system = "SF Pro"
    func font(_ size: CGFloat) -> Font {
        switch self {
        case .bebas:      return .custom("BebasNeue-Regular", size: size)
        case .montserrat: return .custom("Montserrat-SemiBold", size: size)
        case .arial:      return .custom("Arial-BoldMT", size: size)
        case .helvetica:  return .custom("HelveticaNeue-Bold", size: size)
        case .system:     return .system(size: size, weight: .bold)
        }
    }
    // How big the letters can be for a given area: narrow fonts fit more.
    var fill: CGFloat { self == .bebas ? 1.35 : 0.98 }
    var tracking: CGFloat { self == .bebas ? 1.2 : 0 }
    var lineSpacing: CGFloat { self == .bebas ? -2 : 2 }
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

let minW: CGFloat = 200, minH: CGFloat = 90

// Transparent layer on top of the text.
// Middle: drag to move, click for next quote. Edges and corners: drag to resize.
final class DragView: NSView {
    let edge: CGFloat = 14
    var hovering = false { didSet { needsDisplay = true } }
    var tracking: NSTrackingArea?

    override func hitTest(_ point: NSPoint) -> NSView? { frame.contains(point) ? self : nil }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func updateTrackingAreas() {
        if let t = tracking { removeTrackingArea(t) }
        let t = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(t); tracking = t
        super.updateTrackingAreas()
    }
    override func mouseEntered(with event: NSEvent) { hovering = true }
    override func mouseExited(with event: NSEvent) { hovering = false; NSCursor.arrow.set() }
    override func mouseMoved(with event: NSEvent) {
        let e = edges(at: convert(event.locationInWindow, from: nil))
        if (e.l || e.r) && !(e.t || e.b) { NSCursor.resizeLeftRight.set() }
        else if (e.t || e.b) && !(e.l || e.r) { NSCursor.resizeUpDown.set() }
        else if e.any { NSCursor.crosshair.set() }
        else { NSCursor.openHand.set() }
    }

    struct Edges { var l = false, r = false, t = false, b = false; var any: Bool { l || r || t || b } }
    func edges(at p: NSPoint) -> Edges {
        Edges(l: p.x < edge, r: p.x > bounds.width - edge, t: p.y > bounds.height - edge, b: p.y < edge)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard hovering else { return }
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), xRadius: 14, yRadius: 14)
        path.lineWidth = 1.5
        path.setLineDash([6, 5], count: 2, phase: 0)
        NSColor.white.withAlphaComponent(0.35).setStroke()
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        guard let w = window else { return }
        let e = edges(at: convert(event.locationInWindow, from: nil))
        if e.any { resize(w, e); return }
        let before = w.frame.origin
        NSCursor.closedHand.set()
        w.performDrag(with: event)
        NSCursor.openHand.set()
        let after = w.frame.origin
        if abs(after.x - before.x) < 2 && abs(after.y - before.y) < 2 {
            NotificationCenter.default.post(name: .nextQuote, object: nil)
        } else { save(w) }
    }

    func resize(_ w: NSWindow, _ e: Edges) {
        let start = w.frame, m0 = NSEvent.mouseLocation
        while let ev = w.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) {
            if ev.type == .leftMouseUp { break }
            let m = NSEvent.mouseLocation, dx = m.x - m0.x, dy = m.y - m0.y
            var f = start
            if e.r { f.size.width = max(minW, start.width + dx) }
            if e.l { let nw = max(minW, start.width - dx); f.origin.x = start.maxX - nw; f.size.width = nw }
            if e.t { f.size.height = max(minH, start.height + dy) }
            if e.b { let nh = max(minH, start.height - dy); f.origin.y = start.maxY - nh; f.size.height = nh }
            w.setFrame(f, display: true)
        }
        save(w)
    }

    func save(_ w: NSWindow) { UserDefaults.standard.set(NSStringFromRect(w.frame), forKey: "frame") }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        registerFonts()

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 620, height: 260),
                          styleMask: [.borderless], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.acceptsMouseMovedEvents = true

        let root = NSView(frame: NSRect(x: 0, y: 0, width: 620, height: 260))
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
        statusItem.button?.title = "F"
        statusItem.button?.font = NSFont(name: "BebasNeue-Regular", size: 17) ?? .boldSystemFont(ofSize: 13)
        buildMenu()
    }

    func place() {
        if let s = UserDefaults.standard.string(forKey: "frame") {
            let f = NSRectFromString(s)
            if f.width >= minW, NSScreen.screens.contains(where: { $0.frame.intersects(f) }) {
                window.setFrame(f, display: true); return
            }
        }
        guard let v = NSScreen.main?.visibleFrame else { return }
        window.setFrame(NSRect(x: v.maxX - 660, y: v.maxY - 300, width: 620, height: 260), display: true)
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
        let face = d.string(forKey: "face2") ?? Face.bebas.rawValue
        for f in Face.allCases {
            let i = NSMenuItem(title: f.rawValue, action: #selector(pickFace(_:)), keyEquivalent: "")
            i.target = self; i.representedObject = f.rawValue; i.state = f.rawValue == face ? .on : .off
            menu.addItem(i)
        }
        menu.addItem(.separator())
        let q = NSMenuItem(title: "Show quote marks", action: #selector(toggleQuotes), keyEquivalent: "")
        q.target = self; q.state = d.bool(forKey: "quotes") ? .on : .off
        menu.addItem(q)
        let reset = NSMenuItem(title: "Reset position and size", action: #selector(resetFrame), keyEquivalent: "")
        reset.target = self; menu.addItem(reset)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Face It", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func nextQuote() { NotificationCenter.default.post(name: .nextQuote, object: nil) }
    @objc func pickFace(_ s: NSMenuItem) { UserDefaults.standard.set(s.representedObject as? String, forKey: "face2"); buildMenu() }
    @objc func toggleQuotes() { let d = UserDefaults.standard; d.set(!d.bool(forKey: "quotes"), forKey: "quotes"); buildMenu() }
    @objc func resetFrame() { UserDefaults.standard.removeObject(forKey: "frame"); place() }
}

// MARK: View

struct Quote { let text: String; let source: String? }

struct QuoteView: View {
    @AppStorage("face2") private var faceRaw: String = Face.bebas.rawValue
    @AppStorage("quotes") private var quotes: Bool = false
    @State private var lines: [Quote] = Self.mixed()
    @State private var i = 0
    private let timer = Timer.publish(every: secondsPerLine, on: .main, in: .common).autoconnect()
    private let green = Color(red: 0.404, green: 0.875, blue: 0.439)

    static func mixed() -> [Quote] {
        let a = affirmations.shuffled().map { Quote(text: $0, source: nil) }
        let g = gratitude.shuffled().map { Quote(text: $0.0, source: $0.1) }
        var out: [Quote] = []
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
        let q = lines[i]
        let text = quotes ? "\"\(q.text)\"" : q.text
        GeometryReader { geo in
            let pad: CGFloat = 18
            let textH = geo.size.height - pad * 2 - (q.source == nil ? 0 : geo.size.height * 0.16)
            let area = max(1, (geo.size.width - pad * 2) * max(1, textH))
            let size = min(textH * 0.5, face.fill * sqrt(area / CGFloat(max(12, text.count))))
            let srcSize = max(12, min(size * 0.38, geo.size.height * 0.1))
            ZStack {
                VStack(spacing: max(6, size * 0.22)) {
                    Text(text)
                        .font(face.font(size))
                        .tracking(face.tracking)
                        .lineSpacing(face.lineSpacing)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.3)
                    if let src = q.source {
                        Text(src)
                            .font(face.font(srcSize))
                            .tracking(face.tracking + 0.5)
                            .foregroundStyle(green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
                .shadow(color: .black.opacity(0.45), radius: 18, y: 4)
                .padding(pad)
                .id(i)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 8)),
                    removal: .opacity.combined(with: .offset(y: -8))))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onReceive(timer) { _ in advance() }
        .onReceive(NotificationCenter.default.publisher(for: .nextQuote)) { _ in advance() }
    }
}
