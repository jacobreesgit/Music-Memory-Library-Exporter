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
        }
    }
    
    private func exportData() {
        // Get JSON as string
        if let jsonString = queryService.musicLibrary.exportToJSON() {
            // Share text directly
            let activityVC = UIActivityViewController(
                activityItems: [jsonString],
                applicationActivities: nil
            )
            
            // Present the activity view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                // On iPad, set the popover presentation controller
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = rootViewController.view
                    popover.sourceRect = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                rootViewController.present(activityVC, animated: true)
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
