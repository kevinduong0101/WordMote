import Foundation
import SwiftUI
import AppKit
import Combine

class UpdateManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    static let shared = UpdateManager()
    
    @Published var isUpdateAvailable: Bool = false
    @Published var latestVersion: String = ""
    @Published var releaseNotes: String = ""
    @Published var releaseURL: URL?
    @Published var downloadAssetURL: URL?
    @Published var isChecking: Bool = false
    @Published var statusMessage: String?
    
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Double = 0.0
    @Published var isInstalling: Bool = false
    @Published var updateError: String?
    
    // Phiên bản hiện tại của app (lấy từ Info.plist hoặc mặc định 1.0.0)
    var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private let apiURL = "https://api.github.com/repos/kevinduong0101/WordMote/releases/latest"
    private var downloadSession: URLSession?
    
    override init() {
        super.init()
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
                
                // Parse file WordMote.dmg từ assets
                if let assets = json["assets"] as? [[String: Any]] {
                    if let dmgAsset = assets.first(where: { ($0["name"] as? String)?.lowercased().hasSuffix(".dmg") == true }),
                       let dlStr = dmgAsset["browser_download_url"] as? String {
                        self.downloadAssetURL = URL(string: dlStr)
                    }
                }
                
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
    
    // Semantic Versioning comparison: so sánh từng số (ví dụ: 1.0.0 == 1.0)
    func isVersion(_ v1: String, greaterThan v2: String) -> Bool {
        let parse = { (v: String) -> [Int] in
            let clean = v.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespaces)
            return clean.split(separator: ".").compactMap { Int($0) }
        }
        let p1 = parse(v1)
        let p2 = parse(v2)
        let count = max(p1.count, p2.count)
        for i in 0..<count {
            let n1 = i < p1.count ? p1[i] : 0
            let n2 = i < p2.count ? p2[i] : 0
            if n1 > n2 { return true }
            if n1 < n2 { return false }
        }
        return false
    }
    
    // MARK: - 1-Click Auto Update
    
    func startAutoUpdate() {
        guard let downloadURL = downloadAssetURL else {
            openDownloadPage()
            return
        }
        
        isDownloading = true
        isInstalling = false
        downloadProgress = 0.0
        statusMessage = "Downloading update..."
        updateError = nil
        
        let config = URLSessionConfiguration.default
        downloadSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        let task = downloadSession?.downloadTask(with: downloadURL)
        task?.resume()
    }
    
    // URLSessionDownloadDelegate: Tiến trình tải
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.downloadProgress = progress
            self.statusMessage = "Downloading: \(Int(progress * 100))%"
        }
    }
    
    // URLSessionDownloadDelegate: Tải hoàn tất -> Cài đặt
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let tempDMG = FileManager.default.temporaryDirectory.appendingPathComponent("WordMote_Update_\(UUID().uuidString).dmg")
        do {
            try FileManager.default.moveItem(at: location, to: tempDMG)
            DispatchQueue.main.async {
                self.installUpdate(from: tempDMG)
            }
        } catch {
            DispatchQueue.main.async {
                self.isDownloading = false
                self.updateError = "Download move failed: \(error.localizedDescription)"
                self.statusMessage = self.updateError
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.isDownloading = false
                self.updateError = "Download error: \(error.localizedDescription)"
                self.statusMessage = self.updateError
            }
        }
    }
    
    // MARK: - Mount & Self-Replacement
    
    private func installUpdate(from dmgURL: URL) {
        isDownloading = false
        isInstalling = true
        statusMessage = "Installing update & relaunching..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let mountPoint = "/tmp/WordMoteMount_\(UUID().uuidString)"
            let fm = FileManager.default
            try? fm.createDirectory(atPath: mountPoint, withIntermediateDirectories: true)
            
            // Mount DMG ngầm
            let attachProcess = Process()
            attachProcess.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            attachProcess.arguments = ["attach", dmgURL.path, "-mountpoint", mountPoint, "-nobrowse", "-readonly", "-quiet"]
            
            do {
                try attachProcess.run()
                attachProcess.waitUntilExit()
            } catch {
                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.updateError = "Failed to mount DMG: \(error.localizedDescription)"
                    self.statusMessage = self.updateError
                }
                return
            }
            
            // Xác nhận có WordMote.app bên trong ổ đĩa ảo
            let sourceAppPath = (mountPoint as NSString).appendingPathComponent("WordMote.app")
            guard fm.fileExists(atPath: sourceAppPath) else {
                let detach = Process()
                detach.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
                detach.arguments = ["detach", mountPoint, "-force", "-quiet"]
                try? detach.run()
                
                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.updateError = "WordMote.app not found in update package."
                    self.statusMessage = self.updateError
                }
                return
            }
            
            // Xác định thư mục cài đích
            var targetAppPath = Bundle.main.bundlePath
            if targetAppPath.hasPrefix("/Volumes/") || !targetAppPath.hasSuffix(".app") {
                targetAppPath = "/Applications/WordMote.app"
            }
            
            // Tạo Helper script độc lập
            let scriptPath = "/tmp/wordmote_updater_\(UUID().uuidString).sh"
            let pid = ProcessInfo.processInfo.processIdentifier
            
            let scriptContent = """
            #!/bin/bash
            PID=\(pid)
            MOUNT_POINT="\(mountPoint)"
            TARGET_APP="\(targetAppPath)"
            DMG_PATH="\(dmgURL.path)"
            SCRIPT_PATH="\(scriptPath)"

            # Đợi app hiện tại kết thúc
            while kill -0 "$PID" 2>/dev/null; do
                sleep 0.2
            done

            # Cập nhật đè app mới vào đích
            if [ -d "$MOUNT_POINT/WordMote.app" ]; then
                rm -rf "$TARGET_APP"
                ditto "$MOUNT_POINT/WordMote.app" "$TARGET_APP"
            fi

            # Dọn dẹp mount và file DMG tạm
            hdiutil detach "$MOUNT_POINT" -force -quiet
            rm -rf "$MOUNT_POINT"
            rm -f "$DMG_PATH"

            # Xoá cờ quarantine của macOS
            xattr -dr com.apple.quarantine "$TARGET_APP" 2>/dev/null || true

            # Tự xoá script
            rm -f "$SCRIPT_PATH"

            # Khởi động lại ứng dụng mới
            open "$TARGET_APP"
            """
            
            do {
                try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
                
                let chmodProcess = Process()
                chmodProcess.executableURL = URL(fileURLWithPath: "/bin/chmod")
                chmodProcess.arguments = ["+x", scriptPath]
                try chmodProcess.run()
                chmodProcess.waitUntilExit()
                
                let runner = Process()
                runner.executableURL = URL(fileURLWithPath: "/bin/bash")
                runner.arguments = [scriptPath]
                try runner.run()
                
                // Thoát app hiện tại để script tiến hành swap và khởi động lại
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NSApp.terminate(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.updateError = "Failed to launch updater: \(error.localizedDescription)"
                    self.statusMessage = self.updateError
                }
            }
        }
    }
    
    func openDownloadPage() {
        if let url = releaseURL ?? URL(string: "https://github.com/kevinduong0101/WordMote/releases") {
            NSWorkspace.shared.open(url)
        }
    }
}
