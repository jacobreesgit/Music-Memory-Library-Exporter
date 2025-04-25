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
        
        // Clean up old exports in the background
        DispatchQueue.global(qos: .background).async {
            ExportManager.shared.cleanupOldExports()
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
        // Get export data from service
        guard let (exportData, _) = queryService.exportData(format: selectedExportFormat) else {
            alertMessage = "No data to export"
            showingAlert = true
            return
        }
        
        // Use export manager to handle the export process
        ExportManager.shared.exportData(exportData, format: selectedExportFormat) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let fileURL):
                    print("File exported successfully: \(fileURL.path)")
                    self.exportedFileURL = fileURL
                    self.isExporting = true
                    
                case .failure(let error):
                    print("Export failed: \(error.localizedDescription)")
                    self.alertMessage = "Export failed: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
}
