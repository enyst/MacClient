# MacClient SwiftUI Migration Plan
## Project Goal

This document outlines the plan to migrate the frontend functionality of the OpenHands project (originally located in the `playground` repository at `/Users/enyst/repos/odie/workspace/playground` or [https://github.com/enyst/playground](https://github.com/enyst/playground)) to a native macOS application using SwiftUI. The MacClient application will interact with the existing backend services provided by the `playground` project.

## Current State and Priorities

The MacClient project is a native macOS SwiftUI application that aims to provide almost the same functionality as the OpenHands web UI, except in cases specified below. The project has a basic structure set up, but several critical components need to be implemented or updated to match the OpenHands functionality.

### Current State
- Basic project structure is set up with SwiftUI and Core Data
- Core models and state management are partially implemented
- Basic networking services are implemented but need updates
- ContentView is empty and needs implementation
- WebSocketService uses Starscream instead of Socket.IO

### Critical Priorities
1. **WebSocket Implementation**: Update WebSocketService to use Socket.IO protocol instead of raw WebSockets
2. **Event Handling**: Implement proper event handling for "oh_event" and "oh_user_action" events
3. **ContentView Implementation**: Create the main UI components to match OpenHands web UI
4. **Message Handling**: Update message models and handling to match OpenHands format

### Implementation Approach
- Focus on migrating functionality from OpenHands web UI, not creating placeholders
- Ensure API compatibility with OpenHands backend
- Adapt React patterns to SwiftUI's declarative approach
- Leverage native macOS capabilities where appropriate

## Tips for LLM Implementation

As you work through this plan, follow these guidelines:

1. **Focus on one section at a time** - Complete each major section before moving to the next to maintain coherence
2. **Verify Swift/SwiftUI patterns** - The React patterns will need careful adaptation to idiomatic Swift
3. **Check for native alternatives** - Some web components have direct macOS counterparts
4. **Handle state differently** - Remember that SwiftUI's state management differs significantly from Redux
5. **Track completed tasks** - Check off each task as you complete it to maintain progress

## Migration Guidelines

- **Always refer to the OpenHands implementation**: Before implementing any component or feature, thoroughly examine the corresponding code in the OpenHands playground repository to understand its behavior and structure
- **Migrate, don't create placeholders**: It is not acceptable to create placeholder implementations that diverge from the OpenHands functionality
- **If you believe a placeholder is necessary**: Stop implementation and consult with the user before proceeding
- **Maintain API compatibility**: Ensure that all API calls and WebSocket communications match the format and behavior of the OpenHands implementation
- **Adapt to SwiftUI patterns**: While maintaining functional equivalence, adapt the React patterns to idiomatic SwiftUI code
- **Leverage native macOS capabilities**: Use native macOS UI components and features where they provide better user experience, but without sacrificing compatibility

## 1. Project Setup and Environment

- [x] **Create a new macOS SwiftUI application**
  - [x] Use Xcode to create a new macOS app with SwiftUI architecture
  - [x] Set up the project with a minimum deployment target of macOS 15.0 (Sequoia)

- [x] **Define basic architecture patterns**
  - [x] Replace Redux with a combination of SwiftUI's @State, @ObservableObject, and @EnvironmentObject for state management
  - [x] Use Swift's Combine framework for asynchronous operations instead of React's async patterns
  - [x] Create a services layer for networking and WebSocket communication

- [x] **Set up package dependencies**
  - [x] Add Alamofire for HTTP networking (similar to Axios)
  - [x] Add Starscream for WebSocket communication
  - [x] Add KeychainAccess for secure credential storage
  - [x] Add CodeEditor for code editing capabilities (similar to Monaco)

## 2. Core Models and State Management

- [~] **Create data models**
  - [~] Models for agent state (reference: `frontend/src/state/agent-slice.ts`)
    - Basic models created in AgentModels.swift, but need to be aligned with OpenHands event types
  - [~] Models for chat messages (reference: `frontend/src/state/chat-slice.ts`)
    - Basic models created in ChatModels.swift, but need to be updated to match OpenHands message format
  - [~] Models for file state (reference: `frontend/src/state/file-state-slice.ts`)
    - Basic FileItem model exists, but needs expansion to match OpenHands file operations
  - [~] Models for commands (reference: `frontend/src/state/command-slice.ts`)
    - Basic structure exists, but needs to be aligned with OpenHands command handling
  - [~] Models for metrics (reference: `frontend/src/state/metrics-slice.ts`)
    - Basic structure exists, but needs implementation

- [~] **Implement ObservableObjects for state containers**
  - [~] Create `AppState` as the main state container
    - Basic structure created, but needs to be expanded with proper event handling
  - [~] Implement `ConversationStore` for managing chat state
    - Basic structure created, but needs to be aligned with OpenHands conversation management
  - [~] Implement `FileStore` for managing file operations
    - Basic structure created, but needs implementation of file operations
  - [~] Implement `SettingsStore` for user preferences
    - Basic structure created, but needs to be expanded with proper settings management
  - [~] Implement `AuthStore` for authentication state
    - Basic structure created, but needs to be aligned with OpenHands authentication flow

## 3. Networking Services

- [~] **Implement API client**
  - [~] Port API methods from `frontend/src/api/open-hands.ts` to Swift services
    - Basic API service created, but needs to be aligned with OpenHands API endpoints
  - [~] Create Alamofire-based network client for REST API calls
    - Basic implementation exists, but needs to be expanded with proper error handling
  - [~] Implement response models and error handling
    - Basic models created, but need to be aligned with OpenHands response formats

- [~] **WebSocket communication**
  - [~] Create a WebSocket service based on patterns in `frontend/src/context/ws-client-provider.tsx`
    - Basic WebSocket service created, but needs to be updated to use Socket.IO protocol instead of raw WebSockets
  - [~] Implement message parsing and event dispatching
    - Basic implementation exists, but needs to be aligned with OpenHands event types ("oh_event" and "oh_user_action")
  - [~] Set up reconnection logic and error handling
    - Basic implementation exists, but needs to be expanded with proper reconnection logic

- [~] **GitHub integration**
  - [~] Port GitHub API functionality from `frontend/src/api/github.ts`
    - Basic GitHub service created, but needs to be aligned with OpenHands GitHub integration
  - [~] Implement OAuth flow for GitHub authentication
    - Basic structure exists, but needs implementation
  - [~] Create models for GitHub repositories and user data
    - Basic models created, but need to be aligned with OpenHands GitHub models

## 4. Main UI Components

- [ ] **App structure and navigation**
  - [ ] Implement main navigation structure based on `frontend/src/routes.ts`
  - [ ] Create sidebar navigation (reference: `frontend/src/components/features/sidebar/sidebar.tsx`)
  - [ ] Implement tab-based layout for different panels

- [ ] **Conversation/Chat interface**
  - [ ] Create message bubbles and chat layout (reference: `frontend/src/components/features/chat/chat-message.tsx`)
  - [ ] Implement message list with scrolling behavior (reference: `frontend/src/components/features/chat/messages.tsx`)
  - [ ] Create typing indicator (reference: `frontend/src/components/features/chat/typing-indicator.tsx`)
  - [ ] Implement chat input without image upload (reference: `frontend/src/components/features/chat/chat-input.tsx`)
  - [ ] Add action buttons for feedback and trajectory export (reference: `frontend/src/components/features/trajectory/trajectory-actions.tsx`)
  - [ ] Make command output expandable directly within the chat interface

- [ ] **File explorer**
  - [ ] Create macOS-native file browser component (reference: `frontend/src/components/features/file-explorer/file-explorer.tsx`)
  - [ ] Implement tree view with folder expansion (reference: `frontend/src/components/features/file-explorer/explorer-tree.tsx`)
  - [ ] Add file icons based on file types (reference: `frontend/src/components/features/file-explorer/file-icon.tsx`)
  - [ ] Support file selection and viewing (reference: `frontend/src/components/features/file-explorer/tree-node.tsx`)

- [ ] **Code viewer/editor**
  - [ ] Integrate CodeEditor package for code display and editing
  - [ ] Implement syntax highlighting based on file extension (reference: `frontend/src/routes/_oh.app._index/route.tsx`)
  - [ ] Add support for file modification indicators

## 5. Secondary UI Components

- [ ] **Settings interface**
  - [ ] Integrate settings in the main menu with multiple tabs corresponding to sections in config.toml
  - [ ] Implement GitHub token management using secure storage

- [ ] **Modals and dialogs**
  - [ ] Create confirmation dialogs (reference: `frontend/src/components/shared/modals/confirmation-modals/base-modal.tsx`)
  - [ ] Implement feedback form (reference: `frontend/src/components/features/feedback/feedback-form.tsx`)

- [ ] **Buttons and controls**
  - [ ] Create custom button styles for brand consistency (reference: `frontend/src/components/features/settings/brand-button.tsx`)
  - [ ] Implement action buttons with tooltips (reference: `frontend/src/components/shared/buttons/tooltip-button.tsx`)
  - [ ] Add controls for agent actions (reference: `frontend/src/components/features/controls/agent-control-bar.tsx`)

## 6. Behavior Implementation

- [ ] **Chat functionality**
  - [ ] Implement message sending logic (reference: `frontend/src/services/chat-service.ts`)
  - [ ] Create handlers for different message types (reference: `frontend/src/services/actions.ts` and `frontend/src/services/observations.ts`)
  - [ ] Add auto-scrolling behavior for new messages (reference: `frontend/src/hooks/use-scroll-to-bottom.ts`)
  - [ ] Implement URL handling that opens links in the native system browser

- [ ] **GitHub repository integration**
  - [ ] Implement repository listing and selection (reference: `frontend/src/components/features/github/github-repo-selector.tsx`)
  - [ ] Add repository search functionality (reference: `frontend/src/hooks/query/use-search-repositories.ts`)
  - [ ] Create repository status indicators (reference: `frontend/src/components/features/conversation-panel/conversation-state-indicator.tsx`)

- [ ] **Authentication and user management**
  - [ ] Implement GitHub OAuth flow for authentication (reference: `frontend/src/hooks/use-github-auth-url.ts`)
  - [ ] Create secure token storage using Keychain
  - [ ] Add user profile display (reference: `frontend/src/components/features/sidebar/user-avatar.tsx`)

- [ ] **File operations**
  - [ ] Implement file listing and browsing (reference: `frontend/src/hooks/query/use-list-files.ts`)
  - [ ] Add file content fetching (reference: `frontend/src/hooks/query/use-list-file.ts`)
  - [ ] Create file saving functionality (reference: `frontend/src/api/open-hands.ts` - saveFile method)

## 7. Socket.IO Implementation (Critical Priority)

- [ ] **Replace Starscream with Socket.IO client**
  - [ ] Research and add a Swift Socket.IO client library (e.g., SocketIO-Client-Swift)
  - [ ] Update WebSocketService to use Socket.IO protocol instead of raw WebSockets
  - [ ] Implement proper Socket.IO connection with query parameters and namespace handling

- [ ] **Implement OpenHands event handling**
  - [ ] Add support for "oh_event" events from the server
    - These events contain agent responses, tool calls, and other server-initiated events
  - [ ] Add support for "oh_user_action" events to the server
    - These events are used to send user messages and actions to the server
  - [ ] Implement proper event serialization/deserialization that matches the OpenHands format exactly

- [ ] **Update message handling**
  - [ ] Align WebSocketMessage structure with OpenHands event format
    - Current implementation uses a generic structure that doesn't match OpenHands
  - [ ] Update ConversationService.handleWebSocketMessage to properly handle Socket.IO events
    - Current implementation expects different message types than OpenHands uses
  - [ ] Implement proper error handling for Socket.IO events
    - Include reconnection logic with exponential backoff

- [ ] **WebSocketService refactoring**
  - [ ] Refactor WebSocketService.swift to use Socket.IO instead of Starscream
  - [ ] Update the connection method to match OpenHands socket.io connection parameters
  - [ ] Implement proper event emitters for sending events to the server
  - [ ] Update the message publisher to emit properly formatted OpenHands events

## 8. Configuration Options

- [ ] **Config.toml management**
  - [ ] Implement reading from and writing to `~/.openhands-state/config.toml`
  - [ ] Create configuration models matching the toml structure
  - [ ] Add validation for configuration values
  - [ ] Implement real-time config updates when settings change

## 9. Testing and Quality Assurance

- [ ] **Unit tests**
  - [ ] Create unit tests for core models
  - [ ] Implement network service mocking
  - [ ] Test state management logic

- [ ] **UI tests**
  - [ ] Implement snapshot tests for UI components
  - [ ] Create interaction tests for user flows
  - [ ] Test accessibility features

- [ ] **Integration tests**
  - [ ] Test end-to-end communication with backend
  - [ ] Verify GitHub integration
  - [ ] Test file operations

## 10. ContentView Implementation (High Priority)

- [ ] **Create main ContentView**
  - [ ] Examine the OpenHands web UI layout structure in detail
  - [ ] Implement equivalent layout with sidebar and main content area in SwiftUI
  - [ ] Add navigation between different views that matches OpenHands navigation flow
  - [ ] Implement proper state management for UI components using SwiftUI's @State and @EnvironmentObject

- [ ] **Implement chat interface**
  - [ ] Create message bubbles with styling that matches OpenHands design
  - [ ] Implement message list with scrolling behavior identical to OpenHands
  - [ ] Add input field with send button that behaves like the OpenHands chat input
  - [ ] Implement proper handling of different message types (text, code blocks, tool calls)

- [ ] **Add file browser**
  - [ ] Implement file tree view that matches OpenHands file explorer functionality
  - [ ] Add file content display with syntax highlighting
  - [ ] Implement file operations (create, edit, delete) that match OpenHands behavior
  - [ ] Add support for file search and navigation

- [ ] **Implement settings view**
  - [ ] Create settings form with validation that matches OpenHands settings
  - [ ] Add GitHub token management with secure storage
  - [ ] Implement theme switching that matches OpenHands theme options
  - [ ] Add support for configuration export/import