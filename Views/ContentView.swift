import SwiftUI
import MediaPlayer

struct ContentView: View {
    @StateObject private var viewModel = MusicLibraryViewModel()
    @State private var showExportOptions = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "F8F9FD")
                    .ignoresSafeArea()
                
                // Main content
                if !viewModel.isAuthorized {
                    NoPermissionView(requestPermission: viewModel.requestAuthorization)
                } else {
                    libraryContentView
                }
                
                // Loading overlay
                if viewModel.queryService.isLoading {
                    LoadingView()
                        .transition(.opacity)
                }
            }
            .navigationBarHidden(true)
            .alert(viewModel.alertMessage, isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) {}
            }
            .sheet(isPresented: $showExportOptions) {
                ExportOptionsSheet(
                    selectedFormat: $viewModel.selectedExportFormat,
                    exportAction: viewModel.exportData
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .environmentObject(viewModel.queryService) // Pass queryService to enable artwork access
        }
    }
    
    private var libraryContentView: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                GradientHeaderView(
                    title: "Music Memory",
                    subtitle: "Export your play counts and stats"
                )
                .frame(height: 230)
                
                // Content sections with negative offset to overlap with header
                VStack(spacing: 20) {
                    // Stats card
                    CardView {
                        VStack(spacing: 20) {
                            HStack {
                                Text("Library Statistics")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(Color(hex: "4776E6"))
                            }
                            
                            Divider()
                            
                            StatItem(
                                title: "Total Songs",
                                value: "\(viewModel.queryService.musicLibrary.totalSongs)",
                                icon: "music.note.list",
                                color: Color(hex: "4776E6")
                            )
                            
                            StatItem(
                                title: "Songs With Play Count",
                                value: "\(viewModel.queryService.musicLibrary.songsWithPlayCount)",
                                icon: "play.circle.fill",
                                color: Color(hex: "8E54E9")
                            )
                            
                            // Top songs by play count - shown if we have songs with play counts
                            if !viewModel.queryService.musicLibrary.topSongs.isEmpty {
                                Divider()
                                
                                HStack {
                                    Text("Top Played Songs")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                
                                // List of top songs
                                ForEach(Array(viewModel.queryService.musicLibrary.topSongs)) { song in
                                    SongListItem(song: song)
                                }
                            }
                        }
                    }
                    .padding(.top, -60)
                    
                    // Export button
                    Button {
                        showExportOptions = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Library")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isWide: true))
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
