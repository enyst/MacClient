import SwiftUI

struct ChatMessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading) {
                HStack {
                    if message.sender == .agent {
                        Image(systemName: "brain")
                            .foregroundColor(.blue)
                            .padding(.trailing, 4)
                    }
                    
                    Text(message.sender == .user ? "You" : "Assistant")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if message.sender == .user {
                        Image(systemName: "person.circle")
                            .foregroundColor(.blue)
                            .padding(.leading, 4)
                    }
                }
                
                if message.isTyping {
                    TypingIndicatorView()
                        .padding(.vertical, 8)
                } else {
                    Text(message.content)
                        .padding()
                        .background(message.sender == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.sender == .agent {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicatorView: View {
    @State private var animationOffset = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(.gray)
                    .offset(y: sin(animationOffset + Double(index) * 0.5) * 2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                animationOffset = 2 * .pi
            }
        }
    }
}

#Preview {
    VStack {
        ChatMessageView(message: Message(
            id: "1",
            content: "Hello, how can I help you today?",
            sender: .agent,
            timestamp: Date()
        ))
        
        ChatMessageView(message: Message(
            id: "2",
            content: "I need help with my Swift code.",
            sender: .user,
            timestamp: Date()
        ))
        
        ChatMessageView(message: Message(
            id: "3",
            content: "",
            sender: .agent,
            timestamp: Date(),
            isTyping: true
        ))
    }
}