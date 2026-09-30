import AppKit
import SwiftUI

class DesktopWidgetManager {
    static let shared = DesktopWidgetManager()
    
    var window: NSWindow?
    
    private init() {}
    
    func showWidget(wordManager: WordManager) {
        if window == nil {
            let contentView = WidgetView().environmentObject(wordManager)
            
            // Lấy kích thước màn hình
            guard let screen = NSScreen.main else { return }
            let widgetWidth: CGFloat = 320
            let widgetHeight: CGFloat = 380
            
            // Mặc định góc dưới bên phải màn hình
            let xPos = screen.visibleFrame.maxX - widgetWidth - 20
            let yPos = screen.visibleFrame.minY + 20
            
            let win = CustomWidgetWindow(
                contentRect: NSRect(x: xPos, y: yPos, width: widgetWidth, height: widgetHeight),
                styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            win.isOpaque = false
            win.backgroundColor = .clear
            win.hasShadow = false
            win.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)))
            win.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenNone]
            win.isMovableByWindowBackground = true
            win.ignoresMouseEvents = false // Đảm bảo nhận click
            
            // Dùng WidgetHostingView thay vì NSHostingView mặc định
            let host = WidgetHostingView(rootView: contentView)
            win.contentView = host
            
            self.window = win
        }
        window?.makeKeyAndOrderFront(nil)
    }
    
    func closeWidget() {
        window?.orderOut(nil)
        window = nil
    }
    
    func toggleWidget(wordManager: WordManager) {
        if window != nil {
            closeWidget()
        } else {
            showWidget(wordManager: wordManager)
        }
    }
}

class CustomWidgetWindow: NSPanel { // Dùng NSPanel thay vì NSWindow cho các widget nổi
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

// CỰC KỲ QUAN TRỌNG: Cho phép SwiftUI nhận click NGAY LẬP TỨC
// kể cả khi app đang chạy ngầm hoặc khi bạn dùng tính năng "Show Desktop"
class WidgetHostingView<Content: SwiftUI.View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
