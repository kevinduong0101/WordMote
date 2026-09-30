import SwiftUI

struct ManageWordsView: View {
    @EnvironmentObject var wordManager: WordManager
    @State private var wordToEdit: Word?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "books.vertical.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text("Library")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("\(wordManager.words.count) words")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            
            if wordManager.words.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No words saved yet.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(wordManager.words) { word in
                            WordCardView(word: word, wordToEdit: $wordToEdit)
                                .environmentObject(wordManager)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 500, height: 450)
        .background(VisualEffectView().ignoresSafeArea())
        .sheet(item: $wordToEdit) { word in
            EditWordView(wordToEdit: word)
                .environmentObject(wordManager)
        }
    }
}

struct WordCardView: View {
    let word: Word
    @Binding var wordToEdit: Word?
    @EnvironmentObject var wordManager: WordManager
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(word.word)
                        .font(.title3.bold())
                    
                    Text(levelText(for: word.srs_level))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(levelColor(for: word.srs_level).opacity(0.2))
                        .foregroundColor(levelColor(for: word.srs_level))
                        .cornerRadius(4)
                }
                
                Text(word.meaning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: { wordToEdit = word }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        withAnimation {
                            if let index = wordManager.words.firstIndex(where: { $0.id == word.id }) {
                                wordManager.deleteWords(at: IndexSet(integer: index))
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.opacity)
            }
        }
        .padding(16)
        .background(Color.white.opacity(isHovered ? 0.15 : 0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
    
    func levelColor(for level: Int) -> Color {
        switch level {
        case 0: return .red
        case 1: return .orange
        case 2: return .green
        default: return .gray
        }
    }
    
    func levelText(for level: Int) -> String {
        switch level {
        case 0: return "UNFAMILIAR"
        case 1: return "FAMILIAR"
        case 2: return "REMEMBERED"
        default: return "UNKNOWN"
        }
    }
}
