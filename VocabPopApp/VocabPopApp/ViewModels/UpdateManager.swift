import Foundation
import SwiftUI
import AppKit
import Combine

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    @Published var isUpdateAvailable: Bool = false
    @Published var latestVersion: String = ""
    @Published var releaseNotes: String = ""
    @Published var releaseURL: URL?
    @Published var isChecking: Bool = false
    @Published var statusMessage: String?
    
    // Phiên bản hiện tại của app (lấy từ Info.plist hoặc mặc định 1.0.0)
    var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private let apiURL = "https://api.github.com/repos/kevinduong0101/WordMote/releases/latest"
    
    init() {
        // Tự động kiểm tra bản cập nhật ngầm khi khởi động app
        checkForUpdates(silent: true)
    }
    
    func checkForUpdates(silent: Bool = false) {
        guard let url = URL(string: apiURL) else { return }
        
        if !silent {
            isChecking = true
            statusMessage = "Checking for updates..."
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("WordMote-macOS", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isChecking = false
                
                if let error = error {
                    if !silent { self.statusMessage = "Network error: \(error.localizedDescription)" }
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let rawTag = json["tag_name"] as? String,
                      let htmlUrlString = json["html_url"] as? String else {
                    if !silent { self.statusMessage = "Could not check updates at this time." }
                    return
                }
                
                let cleanTag = rawTag.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespaces)
                let body = json["body"] as? String ?? ""
                let releasePageURL = URL(string: htmlUrlString)
                
                if self.isVersion(cleanTag, greaterThan: self.currentVersion) {
                    self.isUpdateAvailable = true
                    self.latestVersion = cleanTag
                    self.releaseNotes = body
                    self.releaseURL = releasePageURL
                    self.statusMessage = "New update available: v\(cleanTag)"
                } else {
                    self.isUpdateAvailable = false
                    if !silent {
                        self.statusMessage = "WordMote is up to date (v\(self.currentVersion))."
                    }
                }
            }
        }.resume()
    }
    
    private func isVersion(_ v1: String, greaterThan v2: String) -> Bool {
        return v1.compare(v2, options: .numeric) == .orderedDescending
    }
    
    func openDownloadPage() {
        if let url = releaseURL ?? URL(string: "https://github.com/kevinduong0101/WordMote/releases") {
            NSWorkspace.shared.open(url)
        }
    }
}
