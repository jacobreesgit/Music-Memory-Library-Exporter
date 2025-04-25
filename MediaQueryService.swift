import Foundation
import MediaPlayer

class MediaQueryService: ObservableObject {
    @Published var musicLibrary = MusicLibrary()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    func fetchSongs() {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            print("Not authorized to access media library")
            return
        }
        
        // Create a query with proper parameters
        let query = MPMediaQuery.songs()
        query.groupingType = .title // Ensure we get individual songs, not collections
        
        guard let items = query.items else {
            print("No songs found")
            return
        }
        
        print("Found \(items.count) songs in library") // Debug log
        
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
            self.objectWillChange.send() // Explicitly notify observers
            print("Updated musicLibrary with \(songsList.count) songs") // Debug log
        }
    }
}
