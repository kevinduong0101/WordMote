import SwiftUI

struct MenuView: View {
    @EnvironmentObject var wordManager: WordManager
    @ObservedObject var updateManager = UpdateManager.shared
    var menuBarManager: MenuBarManager
    
    var body: some View {
        VStack(spacing: 6) {
            if updateManager.isUpdateAvailable {
                Button(action: {
                    if !updateManager.isDownloading && !updateManager.isInstalling {
                        updateManager.startAutoUpdate()
                    }
                }) {
                    HStack(spacing: 8) {
                        if updateManager.isDownloading {
                            ProgressView()
                                .scaleEffect(0.65)
                                .colorInvert()
                            Text("Downloading: \(Int(updateManager.downloadProgress * 100))%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        } else if updateManager.isInstalling {
                            ProgressView()
                                .scaleEffect(0.65)
                                .colorInvert()
                            Text("Installing & relaunching...")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("New Update: v\(updateManager.latestVersion)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Update")
                                .font(.system(size: 10, weight: .heavy))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.25))
                                .cornerRadius(5)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(updateManager.isDownloading || updateManager.isInstalling)
                
                Divider()
                    .padding(.vertical, 2)
            }
            
            MenuButton(icon: "plus.circle", title: "Add New Word") {
                menuBarManager.showAddWord()
                menuBarManager.closePopover()
            }
            
            MenuButton(icon: "square.grid.2x2", title: "Manage Words") {
                menuBarManager.showManageWords()
                menuBarManager.closePopover()
            }
            
            MenuButton(icon: "brain", title: "Test Quiz Now", color: .purple) {
                menuBarManager.closePopover()
                wordManager.triggerQuiz()
            }
            
            MenuButton(icon: "gearshape", title: "Settings") {
                menuBarManager.showSettings()
                menuBarManager.closePopover()
            }
            
            Divider()
                .padding(.vertical, 4)
            
            MenuButton(icon: "power", title: "Quit App", color: .red) {
                menuBarManager.quitApp()
            }
        }
        .padding(16)
        .frame(width: 250)
        // Hiệu ứng kính mờ cho Menu
        .background(VisualEffectView().ignoresSafeArea())
    }
}

struct MenuButton: View {
    var icon: String
    var title: String
    var color: Color = .primary
    var action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isHovered ? .white : color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isHovered ? .white : color)
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isHovered ? Color.blue.opacity(0.9) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}
