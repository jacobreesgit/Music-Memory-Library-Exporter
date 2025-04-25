import Foundation
import MediaPlayer

enum MusicAuthorizationError: Error {
    case notAuthorized
    case unknownError
    case noSongsFound
    
    var localizedDescription: String {
        switch self {
        case .notAuthorized:
            return "Not authorized to access music library"
        case .unknownError:
            return "An unknown error occurred"
        case .noSongsFound:
            return "No songs found in music library"
        }
    }
}

class MediaQueryService: ObservableObject {
    @Published var musicLibrary = MusicLibrary()
    @Published var isLoading = false
    @Published var error: MusicAuthorizationError?
    
    var isAuthorized: Bool {
        MPMediaLibrary.authorizationStatus() == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            MPMediaLibrary.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func fetchSongs() async throws {
        guard isAuthorized else {
            throw MusicAuthorizationError.notAuthorized
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        let query = MPMediaQuery.songs()
        guard let items = query.items, !items.isEmpty else {
            DispatchQueue.main.async {
                self.error = .noSongsFound
            }
            throw MusicAuthorizationError.noSongsFound
        }
        
        var songsList: [Song] = []
        
        for item in items {
            let id = item.persistentID.description
            let title = item.title ?? "Unknown Title"
            let artist = item.artist ?? "Unknown Artist"
            let album = item.albumTitle ?? "Unknown Album"
            let playCount = item.playCount
            
            let song = Song(id: id, title: title, artist: artist, album: album, playCount: playCount)
            songsList.append(song)
        }
        
        DispatchQueue.main.async {
            self.musicLibrary.songs = songsList
        }
    }
    
    func exportData(format: ExportFormat = .json) -> (data: String, fileExtension: String)? {
        switch format {
        case .json:
            guard let jsonString = musicLibrary.exportToJSON() else { return nil }
            return (jsonString, "json")
        case .csv:
            guard let csvString = musicLibrary.exportToCSV() else { return nil }
            return (csvString, "csv")
        }
    }
}

enum ExportFormat {
    case json
    case csv
}
