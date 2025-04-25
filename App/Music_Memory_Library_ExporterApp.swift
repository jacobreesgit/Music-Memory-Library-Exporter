import SwiftUI

@main
struct Music_Memory_Library_ExporterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // App uses light mode for consistent gradient appearance
                .accentColor(Color(hex: "4776E6")) // Set app accent color
        }
    }
}
