import SwiftUI
import MediaPlayer
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var queryService = MediaQueryService()
    @State private var isAuthorized = false
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !isAuthorized {
                    Text("This app needs permission to access your music library.")
                        .padding()
                    
                    Button("Request Permission") {
                        queryService.requestAuthorization { granted in
                            isAuthorized = granted
                            if granted {
                                queryService.fetchSongs()
                            } else {
                                alertMessage = "Music library access denied. Please enable in Settings."
                                showingAlert = true
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    List {
                        Section(header: Text("Library Stats")) {
                            Text("Total songs: \(queryService.musicLibrary.songs.count)")
                            Text("Songs with play count: \(queryService.musicLibrary.songs.filter { $0.playCount > 0 }.count)")
                        }
                        
                        Section {
                            Button("Export Play Counts") {
                                exportData()
                            }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Section(header: Text("Sample Data (10 items)")) {
                            ForEach(queryService.musicLibrary.songs.prefix(10)) { song in
                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .font(.headline)
                                    Text("\(song.artist) - \(song.album)")
                                        .font(.subheadline)
                                    Text("Play count: \(song.playCount)")
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .refreshable {
                        queryService.fetchSongs()
                    }
                }
            }
            .navigationTitle("Music Exporter")
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
            .onAppear {
                // Check if already authorized on appear and fetch songs if needed
                if MPMediaLibrary.authorizationStatus() == .authorized {
                    isAuthorized = true
                    queryService.fetchSongs()
                }
            }
        }
    }
    
    private func exportData() {
        if let jsonString = queryService.musicLibrary.exportToJSON() {
            // Create document directory URL
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "music_play_counts_\(Date().timeIntervalSince1970).json"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                // Write to the file
                try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                
                // Share the file
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                
                // Present the view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    // On iPad, set the popover presentation controller
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = rootViewController.view
                        popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    rootViewController.present(activityVC, animated: true)
                }
            } catch {
                alertMessage = "Error exporting data: \(error.localizedDescription)"
                showingAlert = true
            }
        } else {
            alertMessage = "No data to export"
            showingAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
