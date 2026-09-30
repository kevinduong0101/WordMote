import SwiftUI

struct AddWordView: View {
    @EnvironmentObject var wordManager: WordManager
    @State private var wordText = ""
    @State private var meaning = ""
    @State private var imageUrl = ""
    
    @State private var showDuplicateError = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Add New Word")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            
            // Error Banner
            if showDuplicateError {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                    Text("This word already exists in your vocabulary!")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(12)
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Form Fields
            VStack(spacing: 16) {
                CustomTextField(title: "Word (e.g. Ephemeral)", text: $wordText)
                    .onChange(of: wordText) {
                        if showDuplicateError { showDuplicateError = false }
                    }
                
                CustomTextField(title: "Meaning (e.g. Tồn tại ngắn ngủi)", text: $meaning)
                CustomTextField(title: "Image URL or local filename", text: $imageUrl)
            }
            .padding(20)
            
            Spacer()
            
            // Footer
            HStack {
                Button("Cancel") {
                    NSApplication.shared.keyWindow?.close()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: saveWord) {
                    Text("Save Word")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(wordText.isEmpty || meaning.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(wordText.isEmpty || meaning.isEmpty)
            }
            .padding(20)
            .background(Color.secondary.opacity(0.05))
        }
        .frame(width: 450, height: 350)
        .background(VisualEffectView().ignoresSafeArea())
    }
    
    private func saveWord() {
        let cleanWord = wordText.trimmingCharacters(in: .whitespaces)
        
        // Kiểm tra từ trùng lặp
        if wordManager.words.contains(where: { $0.word.lowercased() == cleanWord.lowercased() }) {
            withAnimation(.spring()) {
                showDuplicateError = true
            }
            return
        }
        
        let newWord = Word(
            id: UUID().uuidString,
            word: cleanWord,
            meaning: meaning.trimmingCharacters(in: .whitespaces),
            image_url: imageUrl.trimmingCharacters(in: .whitespaces),
            mnemonic_story: "", // Đã bỏ theo yêu cầu
            srs_level: 0,
            consecutive_remembered_days: 0,
            next_review_time: Date()
        )
        
        wordManager.addWord(newWord)
        
        // Reset
        wordText = ""
        meaning = ""
        imageUrl = ""
        showDuplicateError = false
        
        NSApplication.shared.keyWindow?.close()
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}
