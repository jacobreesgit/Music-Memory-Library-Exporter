import Foundation
import SwiftUI
import UniformTypeIdentifiers

class MusicLibraryViewModel: ObservableObject {
    @Published var queryService: MediaQueryService
    @Published var isAuthorized = false
    @Published var alertMessage = ""
    @Published var showingAlert = false
    @Published var selectedExportFormat: ExportFormat = .json
    @Published var isExporting = false
    @Published var exportedFileURL: URL?
    
    init(queryService: MediaQueryService = MediaQueryService()) {
        self.queryService = queryService
        // Check if already authorized
        isAuthorized = queryService.isAuthorized
        
        // Add this to fetch songs if already authorized
        if isAuthorized {
            print("Already authorized, fetching songs in init")
            fetchSongs()
        } else {
            print("Not authorized yet, will request permission")
        }
    }
    
    // Request access to the music library
    func requestAuthorization() {
        print("Requesting authorization")
        Task {
            let granted = await queryService.requestAuthorization()
            await MainActor.run {
                print("Authorization result: \(granted)")
                isAuthorized = granted
                if granted {
                    fetchSongs()
                } else {
                    alertMessage = "Music library access denied. Please enable in Settings."
                    showingAlert = true
                }
            }
        }
    }
    
    // Fetch songs from the music library
    func fetchSongs() {
        print("Attempting to fetch songs, authorization status: \(queryService.isAuthorized)")
        
        Task {
            do {
                try await queryService.fetchSongs()
                
                // Add this to verify data was loaded
                await MainActor.run {
                    print("Songs fetched successfully. Total count: \(queryService.musicLibrary.totalSongs)")
                    
                    // Force UI update if needed
                    self.objectWillChange.send()
                }
            } catch let error as MusicAuthorizationError {
                await MainActor.run {
                    print("Error fetching songs: \(error.localizedDescription)")
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    print("Unexpected error: \(error)")
                    alertMessage = "An unexpected error occurred: \(error)"
                    showingAlert = true
                }
            }
        }
    }
    
    // Export data in the selected format
    func exportData() {
        guard let (exportedData, fileExtension) = queryService.exportData(format: selectedExportFormat) else {
            alertMessage = "No data to export"
            showingAlert = true
            return
        }
        
        // Determine content type
        let contentType: UTType
        switch selectedExportFormat {
        case .json:
            contentType = .json
        case .csv:
            contentType = .commaSeparatedText
        }
        
        // Create temporary file URL in the cache directory
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = "music_play_counts_\(Date().timeIntervalSince1970).\(fileExtension)"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        do {
            // Write to the temporary file
            try exportedData.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Save the URL for sharing
            DispatchQueue.main.async {
                self.exportedFileURL = fileURL
                self.isExporting = true
            }
        } catch {
            alertMessage = "Error exporting data: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
