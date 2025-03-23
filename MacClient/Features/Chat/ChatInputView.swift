import SwiftUI

struct ChatInputView: View {
    @Binding var inputText: String
    var onSend: () -> Void
    
    @FocusState private var isInputFocused: Bool
    @State private var inputHeight: CGFloat = 40
    
    var body: some View {
        HStack(alignment: .bottom) {
            TextEditor(text: $inputText)
                .padding(8)
                .background(Color(.textBackgroundColor))
                .cornerRadius(8)
                .frame(height: max(40, min(120, inputHeight)))
                .focused($isInputFocused)
                .onChange(of: inputText) { _ in
                    // Calculate height based on text content
                    let size = CGSize(width: UIScreen.main.bounds.width - 120, height: .infinity)
                    let estimatedHeight = inputText.boundingRect(
                        with: size,
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: [.font: NSFont.systemFont(ofSize: 14)],
                        context: nil
                    ).height
                    
                    inputHeight = estimatedHeight + 24
                }
            
            Button(action: {
                onSend()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .keyboardShortcut(.return, modifiers: [.command])
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .onAppear {
            isInputFocused = true
        }
    }
}

#Preview {
    ChatInputView(inputText: .constant("Hello world"), onSend: {})
}