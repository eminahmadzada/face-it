// Face It Mac app. Replace FaceItApp.swift with this file and delete ContentView.swift.
import SwiftUI

@main
struct FaceItApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Text("Face It").font(.system(size: 28, weight: .bold))
                Text("Widgets are installed.")
                Text("Right click your desktop, choose Edit Widgets, search Face It.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .frame(minWidth: 420)
        }
    }
}
