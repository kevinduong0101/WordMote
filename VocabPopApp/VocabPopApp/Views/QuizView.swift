import SwiftUI

enum QuizMode {
    case multipleChoice
    case typing
}

struct QuizView: View {
    @EnvironmentObject var wordManager: WordManager
    @State private var options: [String] = []
    @State private var shakeOffset: CGFloat = 0
    @State private var selectedWrongIndex: Int? = nil
    @State private var showSuccess = false
    
    @State private var quizMode: QuizMode = .multipleChoice
    @State private var typedAnswer: String = ""
    @State private var typingError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let word = wordManager.currentWordToShow {
                Text("Time for a quick check!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 24)
                
                if quizMode == .multipleChoice {
                    HStack(spacing: 8) {
                        Text(word.word)
                            .font(.system(size: 40, weight: .bold))
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        wordManager.speak(word: word.word)
                    }
                    .multilineTextAlignment(.center)
                } else {
                    Text("What is the English word for:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(word.meaning)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if !word.image_url.isEmpty {
                    ZStack {
                        GifImageView(imageName: word.image_url)
                            .allowsHitTesting(false)
                        Color.clear.contentShape(Rectangle())
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if quizMode == .multipleChoice {
                    VStack(spacing: 12) {
                        ForEach(0..<options.count, id: \.self) { index in
                            Button(action: {
                                checkAnswer(index: index, correctMeaning: word.meaning)
                            }) {
                                Text(options[index])
                                    .font(.system(size: 16))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                    .background(buttonColor(for: index))
                                    .foregroundColor(selectedWrongIndex == index || (showSuccess && options[index] == word.meaning) ? .white : .primary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .offset(x: selectedWrongIndex == index ? shakeOffset : 0)
                        }
                    }
                    .padding(.horizontal, 30)
                } else {
                    VStack(spacing: 16) {
                        TextField("Type the word here...", text: $typedAnswer)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 24, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(typingError ? Color.red.opacity(0.1) : Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(typingError ? Color.red.opacity(0.5) : (showSuccess ? Color.green.opacity(0.5) : Color.gray.opacity(0.2)), lineWidth: 1)
                            )
                            .offset(x: shakeOffset)
                            .onSubmit {
                                checkTypingAnswer(correctWord: word.word)
                            }
                        
                        Button(action: {
                            checkTypingAnswer(correctWord: word.word)
                        }) {
                            Text("Submit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(showSuccess ? Color.green : Color.blue)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(typedAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 30)
                }
                
                if showSuccess {
                    Text("Excellent! See you next time.")
                        .foregroundColor(.green)
                        .font(.headline)
                        .transition(.opacity)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button("Snooze 30 mins") {
                        wordManager.snoozeQuiz(minutes: 30)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Snooze 1 hour") {
                        wordManager.snoozeQuiz(minutes: 60)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 24)
                
            } else {
                Text("No words available for quiz.")
                    .onAppear {
                        wordManager.snoozeQuiz(minutes: 60)
                    }
            }
        }
        .frame(width: 400, height: 650)
        .background(VisualEffectView().ignoresSafeArea().clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)))
        .onAppear {
            setupQuiz()
        }
        .onReceive(wordManager.$showQuiz) { show in
            if show {
                setupQuiz()
            }
        }
        .onChange(of: wordManager.currentWordToShow?.id) {
            setupQuiz()
        }
    }
    
    func setupQuiz() {
        quizMode = Bool.random() ? .multipleChoice : .typing
        typedAnswer = ""
        typingError = false
        showSuccess = false
        generateOptions()
    }
    
    func generateOptions() {
        guard let current = wordManager.currentWordToShow else { return }
        var distractors = wordManager.words.filter { $0.id != current.id }.map { $0.meaning }
        
        // Trộn và lấy tối đa 3 đáp án sai
        distractors.shuffle()
        let selectedDistractors = Array(distractors.prefix(3))
        
        var finalOptions = selectedDistractors
        finalOptions.append(current.meaning)
        
        // Nếu không đủ 4 đáp án (do chưa add đủ từ), thêm đáp án giả
        while finalOptions.count < 4 {
            finalOptions.append("Unknown Meaning \(finalOptions.count)")
        }
        
        options = finalOptions.shuffled()
    }
    
    func buttonColor(for index: Int) -> Color {
        if selectedWrongIndex == index {
            return Color.red
        }
        if showSuccess && options[index] == wordManager.currentWordToShow?.meaning {
            return Color.green.opacity(0.8)
        }
        return Color.white.opacity(0.1)
    }
    
    func checkTypingAnswer(correctWord: String) {
        let normalizedTyped = typedAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedCorrect = correctWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if normalizedTyped == normalizedCorrect {
            // Đúng
            typingError = false
            withAnimation {
                showSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let word = wordManager.currentWordToShow {
                    wordManager.handleAssessment(for: word, action: .remembered, updatedStory: "")
                }
                wordManager.snoozeQuiz(minutes: wordManager.quizIntervalMinutes)
                showSuccess = false
            }
        } else {
            // Sai
            typingError = true
            shake()
        }
    }
    
    func checkAnswer(index: Int, correctMeaning: String) {
        if options[index] == correctMeaning {
            // Đúng
            withAnimation {
                showSuccess = true
            }
            // Cộng điểm SRS và đóng quiz sau 1 giây
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let word = wordManager.currentWordToShow {
                    wordManager.handleAssessment(for: word, action: .remembered, updatedStory: "")
                }
                wordManager.snoozeQuiz(minutes: wordManager.quizIntervalMinutes)
                showSuccess = false
            }
        } else {
            // Sai -> Rung lắc
            selectedWrongIndex = index
            shake()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                selectedWrongIndex = nil
            }
        }
    }
    
    func shake() {
        let duration = 0.05
        let move: CGFloat = 10
        withAnimation(.linear(duration: duration)) { shakeOffset = move }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.linear(duration: duration)) { shakeOffset = -move }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.linear(duration: duration)) { shakeOffset = move }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(.linear(duration: duration)) { shakeOffset = 0 }
                }
            }
        }
    }
}
