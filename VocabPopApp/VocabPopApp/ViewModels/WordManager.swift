import Foundation
import Combine
import SwiftUI
import AVFoundation
import CoreGraphics
import Combine
import SwiftUI

class WordManager: ObservableObject {
    @Published var words: [Word] = []
    @Published var currentWordToShow: Word?
    
    // Chỉ số duyệt từ theo thứ tự
    @Published var currentIndex: Int = 0
    
    // Cài đặt thời gian tự động chuyển từ
    @AppStorage("autoAdvanceMinutes") var autoAdvanceMinutes: Int = 5
    
    // Cài đặt khoảng thời gian nhắc lại cơ bản (SRS)
    @AppStorage("baseIntervalMinutes") var baseIntervalMinutes: Int = 15
    
    // Cài đặt thời gian Pop-up Quiz
    @AppStorage("quizIntervalMinutes") var quizIntervalMinutes: Int = 60
    
    @Published var showQuiz: Bool = false
    
    private let fileManager = FileManager.default
    private var timer: Timer?
    private var quizTimer: Timer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    init() {
        loadWords()
        startTimer()
        startQuizTimer()
    }
    
    func getDocumentsDirectory() -> URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("WordMote")
        if !fileManager.fileExists(atPath: appSupport.path) {
            try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }
        
        let targetURL = appSupport.appendingPathComponent("words.json")
        if !fileManager.fileExists(atPath: targetURL.path) {
            // Migrate from Sandbox container if available
            let containerURL = fileManager.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Containers/com.kev.WordMote/Data/Documents/words.json")
            if fileManager.fileExists(atPath: containerURL.path) {
                try? fileManager.copyItem(at: containerURL, to: targetURL)
            } else {
                // Check legacy documents directory
                let legacyDoc = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("words.json")
                if fileManager.fileExists(atPath: legacyDoc.path) {
                    try? fileManager.copyItem(at: legacyDoc, to: targetURL)
                }
            }
        }
        return appSupport
    }
    
    func getWordsFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("words.json")
    }
    
    func loadWords() {
        let url = getWordsFileURL()
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedWords = try? decoder.decode([Word].self, from: data) {
                DispatchQueue.main.async {
                    self.words = decodedWords
                    if self.currentWordToShow == nil && !self.words.isEmpty {
                        self.currentIndex = Int.random(in: 0..<self.words.count) // Random từ bắt đầu
                        self.showWord(at: self.currentIndex)
                    }
                }
            }
        }
    }
    
    func saveWords() {
        let url = getWordsFileURL()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(words) {
            try? data.write(to: url)
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        let interval = TimeInterval(max(1, autoAdvanceMinutes) * 60)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.nextWord()
            }
        }
        
        if currentWordToShow == nil && !words.isEmpty {
            showWord(at: currentIndex)
        }
    }
    
    func resetTimer() {
        startTimer()
    }
    
    func startQuizTimer(customInterval: TimeInterval? = nil) {
        quizTimer?.invalidate()
        let interval = customInterval ?? TimeInterval(max(1, quizIntervalMinutes) * 60)
        
        quizTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.triggerQuiz()
            }
        }
    }
    
    func triggerQuiz() {
        if isFullScreenAppActive() {
            // Đang xem phim full screen -> Tự động snooze 10 phút
            snoozeQuiz(minutes: 10)
        } else {
            showQuiz = true
        }
    }
    
    func snoozeQuiz(minutes: Int) {
        showQuiz = false
        startQuizTimer(customInterval: TimeInterval(minutes * 60))
    }
    
    func isFullScreenAppActive() -> Bool {
        let screenBounds = NSScreen.main?.frame ?? .zero
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        guard let windowInfoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else { return false }
        
        for info in windowInfoList {
            guard let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
                  let windowLayer = info[kCGWindowLayer as String] as? Int,
                  let ownerName = info[kCGWindowOwnerName as String] as? String else { continue }
            
            // Bỏ qua các app hệ thống ẩn và chính app WordMote / VocabPopApp
            if windowLayer < 0 || ownerName == "WordMote" || ownerName == "VocabPopApp" || ownerName == "Window Server" { continue }
            
            var rect = CGRect.zero
            if let x = boundsDict["X"] as? CGFloat,
               let y = boundsDict["Y"] as? CGFloat,
               let w = boundsDict["Width"] as? CGFloat,
               let h = boundsDict["Height"] as? CGFloat {
                rect = CGRect(x: x, y: y, width: w, height: h)
            }
            
            // Nếu có 1 cửa sổ có kích thước xấp xỉ màn hình, coi như là Fullscreen (Netflix, Youtube...)
            if rect.width >= screenBounds.width - 20 && rect.height >= screenBounds.height - 20 {
                return true
            }
        }
        return false
    }
    
    func showWord(at index: Int) {
        guard !words.isEmpty else {
            currentWordToShow = nil
            return
        }
        
        if index >= words.count {
            currentIndex = 0 // Quay lại từ đầu
        } else if index < 0 {
            currentIndex = words.count - 1 // Vòng xuống cuối
        } else {
            currentIndex = index
        }
        
        currentWordToShow = words[currentIndex]
        resetTimer()
    }
    
    func previousWord() {
        showWord(at: currentIndex - 1)
    }
    
    func nextWord() {
        guard !words.isEmpty else { return }
        
        let now = Date()
        // Ưu tiên hiển thị các từ đã đến hạn ôn tập
        let dueWords = words.filter { $0.next_review_time <= now }
        
        if !dueWords.isEmpty, let chosen = dueWords.randomElement(),
           let index = words.firstIndex(where: { $0.id == chosen.id }) {
            showWord(at: index)
        } else {
            // Nếu không có từ nào đến hạn, tiếp tục lặp theo thứ tự
            showWord(at: currentIndex + 1)
        }
    }
    
    func handleAssessment(for word: Word, action: AssessmentAction, updatedStory: String) {
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        
        var updatedWord = word
        updatedWord.mnemonic_story = updatedStory
        
        let now = Date()
        
        switch action {
        case .unfamiliar:
            updatedWord.consecutive_remembered_days = 0
            updatedWord.srs_level = 0
            updatedWord.next_review_time = now.addingTimeInterval(TimeInterval(baseIntervalMinutes * 60))
        case .familiar:
            updatedWord.srs_level = 1
            updatedWord.next_review_time = now.addingTimeInterval(4 * 3600) // 4 hours
        case .remembered:
            updatedWord.consecutive_remembered_days += 1
            updatedWord.srs_level = 2
            
            let count = updatedWord.consecutive_remembered_days
            var delayDays = 1 // 1, 2 lần đầu -> 1 ngày
            
            if count == 3 || count == 4 {
                delayDays = 3 // 3, 4 lần -> 3 ngày
            } else if count == 5 {
                delayDays = 5 // 5 lần -> 5 ngày
            } else if count > 5 {
                delayDays = (count - 4) * 5 // 6 lần -> 10 ngày, 7 lần -> 15 ngày, ...
            }
            
            updatedWord.next_review_time = now.addingTimeInterval(TimeInterval(delayDays * 24 * 3600))
        }
        
        words[index] = updatedWord
        
        saveWords()
        nextWord() // Chuyển sang từ kế tiếp tự động sau khi đánh giá
    }
    
    func addWord(_ newWord: Word) {
        words.append(newWord)
        saveWords()
        if currentWordToShow == nil {
            showWord(at: 0)
        }
    }
    
    func deleteWords(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
        saveWords()
        if currentWordToShow == nil || !words.contains(where: { $0.id == currentWordToShow?.id }) {
            showWord(at: 0)
        }
    }
    
    func updateWord(_ updatedWord: Word) {
        if let index = words.firstIndex(where: { $0.id == updatedWord.id }) {
            words[index] = updatedWord
            saveWords()
            if currentWordToShow?.id == updatedWord.id {
                currentWordToShow = updatedWord
            }
        }
    }
    
    func speak(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
}

enum AssessmentAction {
    case unfamiliar
    case familiar
    case remembered
}
