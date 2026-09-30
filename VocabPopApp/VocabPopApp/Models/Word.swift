import Foundation

struct Word: Codable, Identifiable {
    var id: String
    var word: String
    var meaning: String
    var image_url: String
    var mnemonic_story: String
    var srs_level: Int
    var consecutive_remembered_days: Int
    var next_review_time: Date
}
