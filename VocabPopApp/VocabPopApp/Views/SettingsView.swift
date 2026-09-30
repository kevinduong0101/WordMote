import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var wordManager: WordManager
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
            
            VStack(spacing: 20) {
                // Card 1: Auto-Play
                SettingCard(
                    icon: "timer",
                    iconColor: .blue,
                    title: "Auto-Play Speed",
                    description: "How often the widget automatically switches to a new word.",
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
            }
            .padding(20)
            
            Spacer()
        }
        .frame(width: 450, height: 450)
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
