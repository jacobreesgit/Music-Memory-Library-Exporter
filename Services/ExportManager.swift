import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Manager class for handling export operations
class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - Export Methods
    
    /// Export data with the specified format
    /// - Parameters:
    ///   - data: String data to export
    ///   - format: Export format (json or csv)
    ///   - completion: Completion handler with URL if successful
    func exportData(_ data: String, format: ExportFormat, completion: @escaping (Result<URL, Error>) -> Void) {
        // Generate a unique filename with timestamp
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "music_play_counts_\(timestamp)"
        let fileExtension = format == .json ? "json" : "csv"
        
        // Get document directory URL
        guard let documentDirectory = getDocumentDirectory() else {
            completion(.failure(ExportError.directoryNotFound))
            return
        }
        
        // Create file URL
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).\(fileExtension)")
        
        do {
            // Write data to file
            try data.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Verify file was created
            if FileManager.default.fileExists(atPath: fileURL.path) {
                completion(.success(fileURL))
            } else {
                completion(.failure(ExportError.fileNotCreated))
            }
        } catch {
            print("Error exporting data: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get document directory URL
    private func getDocumentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// Get UTType for the given export format
    func getUTType(for format: ExportFormat) -> UTType {
        switch format {
        case .json:
            return .json
        case .csv:
            return .commaSeparatedText
        }
    }
    
    /// Clean up old export files
    func cleanupOldExports() {
        guard let documentDirectory = getDocumentDirectory() else { return }
        
        do {
            // Get contents of documents directory
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            // Find export files older than 3 days
            let threeDaysAgo = Date().addingTimeInterval(-259200) // 3 days in seconds
            
            for fileURL in fileURLs {
                if fileURL.lastPathComponent.starts(with: "music_play_counts_") {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.creationDateKey])
                    if let creationDate = resourceValues.creationDate, creationDate < threeDaysAgo {
                        try FileManager.default.removeItem(at: fileURL)
                        print("Removed old export file: \(fileURL.lastPathComponent)")
                    }
                }
            }
        } catch {
            print("Error cleaning up old exports: \(error.localizedDescription)")
        }
    }
}

// MARK: - Error Types

/// Export-related errors
enum ExportError: Error {
    case directoryNotFound
    case fileNotCreated
    case dataConversionFailed
    case sharingFailed
    
    var localizedDescription: String {
        switch self {
        case .directoryNotFound:
            return "Could not access document directory"
        case .fileNotCreated:
            return "Failed to create export file"
        case .dataConversionFailed:
            return "Failed to convert data for export"
        case .sharingFailed:
            return "Failed to share the export file"
        }
    }
}

// MARK: - SwiftUI Share Sheet Component

/// SwiftUI component for sharing files
struct ExportShareSheet: UIViewControllerRepresentable {
    let url: URL
    let onCompletion: () -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Use application cache directory URL to ensure compatibility with UIActivityViewController
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = "share_\(Int(Date().timeIntervalSince1970))_\(url.lastPathComponent)"
        let tempFileURL = tempDirectory.appendingPathComponent(tempFileName)
        
        do {
            // Copy file to temporary location for sharing
            let data = try Data(contentsOf: url)
            try data.write(to: tempFileURL)
            
            // Create share controller with temporary file
            let controller = UIActivityViewController(
                activityItems: [tempFileURL],
                applicationActivities: nil
            )
            
            // Set completion handler
            controller.completionWithItemsHandler = { _, _, _, _ in
                // Clean up temporary file
                try? FileManager.default.removeItem(at: tempFileURL)
                
                // Call completion handler
                self.onCompletion()
            }
            
            return controller
        } catch {
            // If copying fails, try to share original file directly
            print("Warning: Couldn't create temp file for sharing, using original: \(error.localizedDescription)")
            
            let controller = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            
            controller.completionWithItemsHandler = { _, _, _, _ in
                self.onCompletion()
            }
            
            return controller
        }
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
