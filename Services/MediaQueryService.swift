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
    @Published var artworkCache: [String: UIImage] = [:]
    
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
        
        // Add explicit options to the query to ensure we get all media
        let query = MPMediaQuery.songs()
        query.groupingType = .album
        
        // Remove any filters that might restrict results
        query.filterPredicates = nil
        
        // Add logging
        print("MPMediaLibrary authorization status: \(MPMediaLibrary.authorizationStatus().rawValue)")
        
        // Force reload the library
        MPMediaLibrary.default().beginGeneratingLibraryChangeNotifications()
        
        guard let items = query.items, !items.isEmpty else {
            print("Query returned no items")
            DispatchQueue.main.async {
                self.error = .noSongsFound
            }
            throw MusicAuthorizationError.noSongsFound
        }
        
        print("Query returned \(items.count) songs")
        
        var songsList: [Song] = []
        
        for item in items {
            let id = item.persistentID.description
            let title = item.title ?? "Unknown Title"
            let artist = item.artist ?? "Unknown Artist"
            let album = item.albumTitle ?? "Unknown Album"
            let playCount = item.playCount
            
            // Log some sample data
            if songsList.count < 5 {
                print("Song: \(title), Artist: \(artist), Play count: \(playCount)")
            }
            
            let song = Song(id: id, title: title, artist: artist, album: album, playCount: playCount)
            songsList.append(song)
            
            // Fetch artwork for songs with play counts
            if playCount > 0 {
                if let artwork = item.artwork?.image(at: CGSize(width: 100, height: 100)) {
                    DispatchQueue.main.async {
                        self.artworkCache[id] = artwork
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            print("Updating music library with \(songsList.count) songs")
            self.musicLibrary.songs = songsList
        }
    }
    
    func getArtwork(for songId: String) -> UIImage? {
        return artworkCache[songId]
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
