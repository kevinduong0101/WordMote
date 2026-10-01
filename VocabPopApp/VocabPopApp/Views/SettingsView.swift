import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var wordManager: WordManager
    @ObservedObject var updateManager = UpdateManager.shared
    @AppStorage("autoAdvanceMinutes") var autoAdvanceMinutes: Int = 5
    @AppStorage("baseIntervalMinutes") var baseIntervalMinutes: Int = 15
    @AppStorage("quizIntervalMinutes") var quizIntervalMinutes: Int = 60
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
                Text("Preferences")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            
            VStack(spacing: 16) {
                // Card 1: Word Rotation
                SettingCard(
                    icon: "timer",
                    iconColor: .blue,
                    title: "Word Rotation Interval",
                    description: "How often the Menu Bar switches to a new vocabulary word.",
                    value: $autoAdvanceMinutes
                ) {
                    wordManager.resetTimer()
                }
                
                // Card 2: Memory System (SRS)
                SettingCard(
                    icon: "brain.head.profile",
                    iconColor: .green,
                    title: "Memory System",
                    description: "How soon to repeat words marked as 'Unfamiliar'.",
                    value: $baseIntervalMinutes
                ) {}
                
                // Card 3: Quiz Interval
                SettingCard(
                    icon: "questionmark.circle",
                    iconColor: .purple,
                    title: "Quiz Popup Interval",
                    description: "Frequency of quiz popups to test your knowledge.",
                    value: $quizIntervalMinutes
                ) {
                    wordManager.startQuizTimer()
                }
                
                // Card 4: Software Update
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: updateManager.isUpdateAvailable ? "sparkles" : "arrow.triangle.2.circlepath.circle")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(updateManager.isUpdateAvailable ? .yellow : .orange)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(updateManager.isUpdateAvailable ? "New Update Available!" : "Software Update")
                            .font(.headline)
                        Text(updateManager.statusMessage ?? "WordMote v\(updateManager.currentVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    if updateManager.isUpdateAvailable {
                        if updateManager.isDownloading {
                            VStack(spacing: 4) {
                                ProgressView(value: updateManager.downloadProgress, total: 1.0)
                                    .frame(width: 110)
                                Text("\(Int(updateManager.downloadProgress * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } else if updateManager.isInstalling {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Installing...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Button("Update Now") {
                                    updateManager.startAutoUpdate()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                                
                                Button {
                                    updateManager.openDownloadPage()
                                } label: {
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .buttonStyle(.borderless)
                                .help("Download DMG manually")
                            }
                        }
                    } else {
                        Button(action: {
                            updateManager.checkForUpdates(silent: false)
                        }) {
                            if updateManager.isChecking {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Text("Check Now")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(updateManager.isChecking)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(20)
            
            Spacer()
        }
        .frame(width: 480, height: 530)
        .background(VisualEffectView().ignoresSafeArea())
    }
}

struct SettingCard: View {
    var icon: String
    var iconColor: Color
    var title: String
    var description: String
    @Binding var value: Int
    var onChange: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            VStack(alignment: .center, spacing: 6) {
                HStack(spacing: 2) {
                    TextField("", value: $value, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 45)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .onChange(of: value) {
                            if value < 1 { value = 1 }
                            onChange?()
                        }
                    
                    Text("m")
                        .font(.subheadline)
                        .foregroundColor(iconColor)
                }
                .frame(width: 70)
                
                Stepper("", value: $value, in: 1...1440)
                    .labelsHidden()
                    .onChange(of: value) {
                        onChange?()
                    }
            }
            .padding(.leading, 10)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}
