import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    
    var body: some View {
        VStack {
            if let conversation = appState.currentConversation {
                ScrollViewReader { scrollView in
                    ScrollView {
                        LazyVStack {
                            ForEach(conversation.messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                            
                            if isTyping {
                                ChatMessageView(message: Message(
                                    id: "typing",
                                    content: "",
                                    sender: .agent,
                                    isTyping: true
                                ))
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: conversation.messages.count) { _ in
                        scrollToBottom(scrollView: scrollView)
                    }
                    .onChange(of: isTyping) { _ in
                        scrollToBottom(scrollView: scrollView)
                    }
                    .onAppear {
                        scrollToBottom(scrollView: scrollView)
                    }
                }
            } else {
                VStack {
                    Spacer()
                    Text("No conversation selected")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            Divider()
            
            ChatInputView(inputText: $inputText, onSend: sendMessage)
        }
    }
    
    private func scrollToBottom(scrollView: ScrollViewProxy) {
        if let lastMessage = appState.currentConversation?.messages.last {
            withAnimation {
                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              var conversation = appState.currentConversation else {
            return
        }
        
        // Create user message
        let userMessage = Message(
            id: UUID().uuidString,
            content: inputText,
            sender: .user
        )
        
        // Add to conversation
        conversation.messages.append(userMessage)
        conversation.lastMessagePreview = inputText
        
        // Update conversation
        if let index = appState.conversations.firstIndex(where: { $0.id == conversation.id }) {
            appState.conversations[index] = conversation
            appState.currentConversation = conversation
        }
        
        // Clear input
        inputText = ""
        
        // Simulate agent typing
        isTyping = true
        
        // Simulate agent response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            
            // Create agent response
            let agentMessage = Message(
                id: UUID().uuidString,
                content: "I'm a simulated response to your message: \"\(userMessage.content)\"",
                sender: .agent
            )
            
            // Add to conversation
            if var updatedConversation = appState.currentConversation {
                updatedConversation.messages.append(agentMessage)
                updatedConversation.lastMessagePreview = agentMessage.content
                
                // Update conversation
                if let index = appState.conversations.firstIndex(where: { $0.id == updatedConversation.id }) {
                    appState.conversations[index] = updatedConversation
                    appState.currentConversation = updatedConversation
                }
            }
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AppState())
}