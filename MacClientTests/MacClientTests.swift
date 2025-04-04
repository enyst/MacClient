//
//  MacClientTests.swift
//  MacClientTests
//
//  Created by Engel Nyst on 2025-03-23.
//

import Testing
@testable import MacClient

struct MacClientTests {

    @Test func testChatMessageRoleProperties() throws {
        let userMessage = ChatMessage(
            id: "1",
            conversationId: "conv1",
            role: .user,
            content: "Hello",
            timestamp: Date(),
            status: .sent
        )

        let assistantMessage = ChatMessage(
            id: "2",
            conversationId: "conv1",
            role: .assistant,
            content: "Hi there",
            timestamp: Date(),
            status: .received
        )

        let systemMessage = ChatMessage(
            id: "3",
            conversationId: "conv1",
            role: .system,
            content: "System init",
            timestamp: Date(),
            status: .received
        )

        #expect(userMessage.isUser == true)
        #expect(userMessage.isAssistant == false)
        #expect(userMessage.isSystem == false)

        #expect(assistantMessage.isUser == false)
        #expect(assistantMessage.isAssistant == true)
        #expect(assistantMessage.isSystem == false)

        #expect(systemMessage.isUser == false)
        #expect(systemMessage.isAssistant == false)
        #expect(systemMessage.isSystem == true)
    }
}
