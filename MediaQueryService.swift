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
        
        let query = MPMediaQuery.songs()
        guard let items = query.items else {
            print("No songs found")
            return
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
}
