import Foundation

struct Song: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let playCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case album
        case playCount = "play_count"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
}

class MusicLibrary: ObservableObject {
    @Published var songs: [Song] = []
    
    var totalSongs: Int {
        songs.count
    }
    
    var songsWithPlayCount: Int {
        songs.filter { $0.playCount > 0 }.count
    }
    
    var topSongs: [Song] {
        songs.sorted(by: { $0.playCount > $1.playCount }).prefix(10).filter { $0.playCount > 0 }
    }
    
    func exportToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(songs)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to encode songs: \(error)")
            return nil
        }
    }
    
    func exportToCSV() -> String? {
        var csvString = "id,title,artist,album,play_count\n"
        
        for song in songs {
            // Properly escape fields for CSV
            let escapedTitle = escapeCSVField(song.title)
            let escapedArtist = escapeCSVField(song.artist)
            let escapedAlbum = escapeCSVField(song.album)
            
            csvString += "\(song.id),\(escapedTitle),\(escapedArtist),\(escapedAlbum),\(song.playCount)\n"
        }
        
        return csvString
    }
    
    private func escapeCSVField(_ field: String) -> String {
        // If the field contains commas, quotes, or newlines, wrap it in quotes and escape any quotes
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
}
