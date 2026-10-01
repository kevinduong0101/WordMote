import SwiftUI

@main
struct WordMoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    static let sharedWordManager = WordManager()
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // App acts as a menu bar app, hide standard dock icon
        NSApp.setActivationPolicy(.accessory)
        
        createSampleJSONIfNeeded()
        
        menuBarManager = MenuBarManager(wordManager: WordMoteApp.sharedWordManager)
    }
    
    func createSampleJSONIfNeeded() {
        let url = WordMoteApp.sharedWordManager.getWordsFileURL()
        if !FileManager.default.fileExists(atPath: url.path) {
            let now = Date()
            let sampleWords = [
                Word(id: UUID().uuidString, word: "Ephemeral", meaning: "Tồn tại trong thời gian ngắn", image_url: "ephemeral", mnemonic_story: "E-phem-er-al: E phèn mờ rảo - một cái gì đó phai mờ rất nhanh.", srs_level: 0, consecutive_remembered_days: 0, next_review_time: now),
                Word(id: UUID().uuidString, word: "Ubiquitous", meaning: "Có mặt ở khắp mọi nơi", image_url: "ubiquitous", mnemonic_story: "Ubi-quit-ous: Bạn không thể quit (từ bỏ) nó vì nó ở khắp nơi.", srs_level: 0, consecutive_remembered_days: 0, next_review_time: now.addingTimeInterval(3600)),
                Word(id: UUID().uuidString, word: "Serendipity", meaning: "Sự tình cờ may mắn", image_url: "serendipity", mnemonic_story: "Seren(dip)ity: Tình cờ dip (nhúng) miếng bánh vào cốc trà ngon.", srs_level: 0, consecutive_remembered_days: 0, next_review_time: now.addingTimeInterval(7200))
            ]
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            if let data = try? encoder.encode(sampleWords) {
                try? data.write(to: url)
            }
        }
    }
}
