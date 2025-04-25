import Foundation

struct Song: Identifiable, Codable {
    var id: String
    var title: String
    var artist: String
    var album: String
    var playCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case album
        case playCount = "play_count"
    }
}

class MusicLibrary: ObservableObject {
    @Published var songs: [Song] = []
    
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
    
    func exportToJSONData() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            return try encoder.encode(songs)
        } catch {
            print("Failed to encode songs: \(error)")
            return nil
        }
    }
}
