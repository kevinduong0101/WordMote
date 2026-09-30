import SwiftUI

struct EditWordView: View {
    @EnvironmentObject var wordManager: WordManager
    var wordToEdit: Word
    
    @State private var wordText: String
    @State private var meaning: String
    @State private var imageUrl: String
    @State private var srsLevel: Int
    @Environment(\.presentationMode) var presentationMode
    
    init(wordToEdit: Word) {
        self.wordToEdit = wordToEdit
        _wordText = State(initialValue: wordToEdit.word)
        _meaning = State(initialValue: wordToEdit.meaning)
        _imageUrl = State(initialValue: wordToEdit.image_url)
        _srsLevel = State(initialValue: wordToEdit.srs_level)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Edit Word")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            
            // Form Fields
            VStack(spacing: 16) {
                CustomTextField(title: "Word", text: $wordText)
                CustomTextField(title: "Meaning", text: $meaning)
                CustomTextField(title: "Image URL or local filename", text: $imageUrl)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Memory Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $srsLevel) {
                        Text("0 - Unfamiliar").tag(0)
                        Text("1 - Familiar").tag(1)
                        Text("2 - Remembered").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding(20)
            
            Spacer()
            
            // Footer
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(wordText.isEmpty || meaning.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(wordText.isEmpty || meaning.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
            .padding(20)
            .background(Color.secondary.opacity(0.05))
        }
        .frame(width: 450, height: 420)
        .background(VisualEffectView().ignoresSafeArea())
    }
    
    private func saveChanges() {
        var updatedWord = wordToEdit
        updatedWord.word = wordText.trimmingCharacters(in: .whitespaces)
        updatedWord.meaning = meaning.trimmingCharacters(in: .whitespaces)
        updatedWord.image_url = imageUrl.trimmingCharacters(in: .whitespaces)
        updatedWord.mnemonic_story = "" // Bỏ trống
        updatedWord.srs_level = srsLevel
        
        wordManager.updateWord(updatedWord)
        presentationMode.wrappedValue.dismiss()
    }
}
