import SwiftUI

struct WidgetView: View {
    @EnvironmentObject var wordManager: WordManager
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 16) {
            if let word = wordManager.currentWordToShow {
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Text(word.word)
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        wordManager.speak(word: word.word)
                    }
                    
                    if showDetails {
                        Text(word.meaning)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    } else {
                        Text("Tap image to reveal")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
                ZStack {
                    GifImageView(imageName: word.image_url)
                        .allowsHitTesting(false) // CHẶN WKWebView cướp chuột làm kẹt widget
                    
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) { showDetails.toggle() }
                        }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                if showDetails {
                    HStack(spacing: 12) {
                        WidgetActionButton(icon: "xmark.circle.fill", color: .red) {
                            wordManager.handleAssessment(for: word, action: .unfamiliar, updatedStory: word.mnemonic_story)
                            showDetails = false
                        }
                        WidgetActionButton(icon: "minus.circle.fill", color: .orange) {
                            wordManager.handleAssessment(for: word, action: .familiar, updatedStory: word.mnemonic_story)
                            showDetails = false
                        }
                        WidgetActionButton(icon: "checkmark.circle.fill", color: .green) {
                            wordManager.handleAssessment(for: word, action: .remembered, updatedStory: word.mnemonic_story)
                            showDetails = false
                        }
                    }
                    .padding(.top, 4)
                }
                
                HStack(spacing: 24) {
                    Button(action: {
                        withAnimation {
                            wordManager.previousWord()
                            showDetails = false
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        withAnimation {
                            wordManager.nextWord()
                            showDetails = false
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, showDetails ? 4 : 12)
                
            } else {
                Text("No words available!")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .frame(width: 340, height: 420)
        .background(VisualEffectView().ignoresSafeArea().clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .onChange(of: wordManager.currentWordToShow?.id) {
            withAnimation {
                showDetails = false
            }
        }
    }
}

struct WidgetActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .foregroundColor(color)
                .background(Circle().fill(Color.white.opacity(isHovered ? 0.2 : 0.05)).frame(width: 44, height: 44))
                .frame(width: 44, height: 44)
                .scaleEffect(isHovered ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { h in isHovered = h }
    }
}
