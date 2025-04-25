import Foundation
import UIKit
import UniformTypeIdentifiers

// Extension to add document directory support to the app
extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getTemporaryDirectory() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    static func isSharingAvailable(for url: URL) -> Bool {
        // Check if the file exists first
        if FileManager.default.fileExists(atPath: url.path) {
            // Test permissions and accessibility
            return FileManager.default.isReadableFile(atPath: url.path)
        }
        return false
    }
}

// Enhanced document sharing utility
class DocumentSharingManager {
    static let shared = DocumentSharingManager()
    
    // Create a properly configured activity view controller for sharing files
    func shareFile(at url: URL, from viewController: UIViewController, completion: @escaping () -> Void) {
        // First, ensure the file exists and is accessible
        guard FileManager.isSharingAvailable(for: url) else {
            print("File is not available for sharing: \(url.path)")
            completion()
            return
        }
        
        // Create an activity view controller with the file URL
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // Set a completion handler to clean up
        activityVC.completionWithItemsHandler = { (_, _, _, _) in
            completion()
        }
        
        // On iPad, set the popover presentation controller
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Present the activity view controller
        viewController.present(activityVC, animated: true)
    }
    
    // Save a file to the documents directory for sharing
    func saveForSharing(data: Data, withName fileName: String, fileExtension: String) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = FileManager.getDocumentsDirectory()
        let fileURL = documentsURL.appendingPathComponent("\(fileName).\(fileExtension)")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file for sharing: \(error)")
            return nil
        }
    }
    
    // Save a string to the documents directory for sharing
    func saveForSharing(string: String, withName fileName: String, fileExtension: String) -> URL? {
        guard let data = string.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        
        return saveForSharing(data: data, withName: fileName, fileExtension: fileExtension)
    }
}
