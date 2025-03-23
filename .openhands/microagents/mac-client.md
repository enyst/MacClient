# MacClient SwiftUI Migration Plan

## Tips for LLM Implementation

As you work through this plan, follow these guidelines:

1. **Focus on one section at a time** - Complete each major section before moving to the next to maintain coherence
2. **Verify Swift/SwiftUI patterns** - The React patterns will need careful adaptation to idiomatic Swift
3. **Check for native alternatives** - Some web components have direct macOS counterparts
4. **Handle state differently** - Remember that SwiftUI's state management differs significantly from Redux
5. **Track completed tasks** - Check off each task as you complete it to maintain progress

When implementing complex components, remember to refer back to the original React files for behavior details, but adapt the patterns to fit SwiftUI's declarative approach. Focus on maintaining the core functionality while leveraging native macOS capabilities where appropriate.

## 1. Project Setup and Environment

- [ ] **Create a new macOS SwiftUI application**
  - [ ] Use Xcode to create a new macOS app with SwiftUI architecture
  - [ ] Set up the project with a minimum deployment target of macOS 15.0 (Sequoia)

- [ ] **Define basic architecture patterns**
  - [ ] Replace Redux with a combination of SwiftUI's @State, @ObservableObject, and @EnvironmentObject for state management
  - [ ] Use Swift's Combine framework for asynchronous operations instead of React's async patterns
  - [ ] Create a services layer for networking and WebSocket communication

- [ ] **Set up package dependencies**
  - [ ] Add Alamofire for HTTP networking (similar to Axios)
  - [ ] Add Starscream for WebSocket communication
  - [ ] Add KeychainAccess for secure credential storage
  - [ ] Add CodeEditor for code editing capabilities (similar to Monaco)

## 2. Core Models and State Management

- [ ] **Create data models**
  - [ ] Models for agent state (reference: `frontend/src/state/agent-slice.ts`)
  - [ ] Models for chat messages (reference: `frontend/src/state/chat-slice.ts`)
  - [ ] Models for file state (reference: `frontend/src/state/file-state-slice.ts`)
  - [ ] Models for commands (reference: `frontend/src/state/command-slice.ts`)
  - [ ] Models for metrics (reference: `frontend/src/state/metrics-slice.ts`)

- [ ] **Implement ObservableObjects for state containers**
  - [ ] Create `AppState` as the main state container
  - [ ] Implement `ConversationStore` for managing chat state
  - [ ] Implement `FileStore` for managing file operations
  - [ ] Implement `SettingsStore` for user preferences
  - [ ] Implement `AuthStore` for authentication state

## 3. Networking Services

- [ ] **Implement API client**
  - [ ] Port API methods from `frontend/src/api/open-hands.ts` to Swift services
  - [ ] Create Alamofire-based network client for REST API calls
  - [ ] Implement response models and error handling

- [ ] **WebSocket communication**
  - [ ] Create a WebSocket service based on patterns in `frontend/src/context/ws-client-provider.tsx`
  - [ ] Implement message parsing and event dispatching
  - [ ] Set up reconnection logic and error handling

- [ ] **GitHub integration**
  - [ ] Port GitHub API functionality from `frontend/src/api/github.ts`
  - [ ] Implement OAuth flow for GitHub authentication
  - [ ] Create models for GitHub repositories and user data

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

## 7. Configuration Options

- [ ] **Config.toml management**
  - [ ] Implement reading from and writing to `~/.openhands-state/config.toml`
  - [ ] Create configuration models matching the toml structure
  - [ ] Add validation for configuration values
  - [ ] Implement real-time config updates when settings change

## 8. Testing and Quality Assurance

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
