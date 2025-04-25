import Foundation
import SwiftUI

class MusicLibraryViewModel: ObservableObject {
    @Published var queryService: MediaQueryService
    @Published var isAuthorized = false
    @Published var alertMessage = ""
    @Published var showingAlert = false
    @Published var selectedExportFormat: ExportFormat = .json
    @Published var isExporting = false
    
    init(queryService: MediaQueryService = MediaQueryService()) {
        self.queryService = queryService
        // Check if already authorized
        isAuthorized = queryService.isAuthorized
    }
    
    // Request access to the music library
    func requestAuthorization() {
        Task {
            let granted = await queryService.requestAuthorization()
            await MainActor.run {
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
        Task {
            do {
                try await queryService.fetchSongs()
            } catch let error as MusicAuthorizationError {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "An unexpected error occurred"
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
        
        // Create document directory URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "music_play_counts_\(Date().timeIntervalSince1970).\(fileExtension)"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            // Write to the file
            try exportedData.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Share the file
            shareFile(at: fileURL)
        } catch {
            alertMessage = "Error exporting data: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    // Present a share sheet for the exported file
    private func shareFile(at fileURL: URL) {
        isExporting = true
        
        // Create a ShareLink programmatically
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
            
            rootViewController.present(activityVC, animated: true) {
                self.isExporting = false
            }
        }
    }
}
