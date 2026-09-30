import AppKit
import SwiftUI
import Combine

class QuizWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
}

class MenuBarManager: NSObject {
    var statusItem: NSStatusItem!
    var wordManager: WordManager
    
    var settingsWindow: NSWindow?
    var addWordWindow: NSWindow?
    var manageWordsWindow: NSWindow?
    var quizWindow: NSWindow?
    
    var popover: NSPopover!
    
    private var cancellables = Set<AnyCancellable>()
    
    init(wordManager: WordManager) {
        self.wordManager = wordManager
        super.init()
        setupMenuBar()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "brain.head.profile", accessibilityDescription: "WordMote")
            button.target = self
            button.action = #selector(togglePopover(_:))
            // Cho phép menu hiện lên khi click chuột
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        let menuView = MenuView(menuBarManager: self).environmentObject(wordManager)
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 250, height: 280)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: menuView)
        
        // Theo dõi sự thay đổi của từ vựng hiện tại để hiển thị lên thanh Status Bar
        wordManager.$currentWordToShow
            .receive(on: RunLoop.main)
            .sink { [weak self] newWord in
                if let word = newWord?.word {
                    self?.statusItem.button?.title = " \(word)"
                } else {
                    self?.statusItem.button?.title = ""
                }
            }
            .store(in: &cancellables)
            
        // Đón nhận tín hiệu hiển thị Quiz Popup
        wordManager.$showQuiz
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                if show {
                    self?.showQuizWindow()
                } else {
                    self?.quizWindow?.close()
                    self?.quizWindow = nil
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                // Giúp Popover tự đóng khi click ra ngoài
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    func closePopover() {
        popover.performClose(nil)
    }
    
    @objc func toggleWidget() {
        DesktopWidgetManager.shared.toggleWidget(wordManager: wordManager)
    }
    
    @objc func showAddWord() {
        if addWordWindow == nil {
            let contentView = AddWordView().environmentObject(wordManager)
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 350),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            win.center()
            win.title = "Add Word"
            win.level = .floating // Nổi lên trên tất cả các app khác
            win.isReleasedWhenClosed = false
            win.contentView = NSHostingView(rootView: contentView)
            addWordWindow = win
        }
        addWordWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func showManageWords() {
        if manageWordsWindow == nil {
            let contentView = ManageWordsView().environmentObject(wordManager)
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 450),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            win.center()
            win.title = "Manage Words"
            win.isReleasedWhenClosed = false
            win.contentView = NSHostingView(rootView: contentView)
            manageWordsWindow = win
        }
        manageWordsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func showSettings() {
        if settingsWindow == nil {
            let contentView = SettingsView().environmentObject(wordManager)
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 530),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            win.center()
            win.title = "Settings"
            win.isReleasedWhenClosed = false
            win.contentView = NSHostingView(rootView: contentView)
            settingsWindow = win
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func showQuizWindow() {
        if quizWindow == nil {
            let contentView = QuizView().environmentObject(wordManager)
            let win = QuizWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 650),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            win.level = .popUpMenu // Always on top heavily, unskippable
            win.center()
            win.isReleasedWhenClosed = false
            win.contentView = NSHostingView(rootView: contentView)
            win.backgroundColor = .clear
            win.isOpaque = false
            quizWindow = win
        }
        quizWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
