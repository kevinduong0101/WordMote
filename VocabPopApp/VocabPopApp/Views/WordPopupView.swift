import SwiftUI

struct WordPopupView: View {
    @EnvironmentObject var wordManager: WordManager
    @State private var editedStory: String = ""
    
    var body: some View {
        if let word = wordManager.currentWordToShow {
            VStack(spacing: 24) {
                Text(word.word)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                GifImageView(imageName: word.image_url)
                    .frame(width: 320, height: 220)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Text(word.meaning)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("Mnemonic Story", text: $editedStory)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .padding(.horizontal, 10)
                    .onAppear {
                        editedStory = word.mnemonic_story
                    }
                
                HStack(spacing: 16) {
                    AssessmentButton(title: "Unfamiliar", color: .red) {
                        wordManager.handleAssessment(for: word, action: .unfamiliar, updatedStory: editedStory)
                    }
                    
                    AssessmentButton(title: "Familiar", color: .yellow, textColor: .black) {
                        wordManager.handleAssessment(for: word, action: .familiar, updatedStory: editedStory)
                    }
                    
                    AssessmentButton(title: "Remembered", color: .green) {
                        wordManager.handleAssessment(for: word, action: .remembered, updatedStory: editedStory)
                    }
                }
                .padding(.top, 10)
            }
            .padding(40)
            .background(VisualEffectView().ignoresSafeArea())
        } else {
            Text("No words to review.")
                .padding()
        }
    }
}

struct AssessmentButton: View {
    let title: String
    let color: Color
    var textColor: Color = .white
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color.opacity(isHovered ? 1.0 : 0.8))
                .foregroundColor(textColor)
                .cornerRadius(12)
                .shadow(color: color.opacity(0.3), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 2)
                .scaleEffect(isHovered ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow // Gives a nice dark translucent look or adapts to mode
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
