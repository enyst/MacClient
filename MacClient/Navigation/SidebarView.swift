import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List(selection: $navigationRouter.selectedRoute) {
            Section(header: Text("Navigation")) {
                ForEach([NavigationRoute.chat, .files, .github, .settings], id: \.self) { route in
                    NavigationLink(value: route) {
                        Label(route.title, systemImage: route.icon)
                    }
                }
            }
            
            Section(header: Text("Conversations")) {
                if appState.conversations.isEmpty {
                    Text("No conversations")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(appState.conversations) { conversation in
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(conversation.title)
                                    .lineLimit(1)
                                Text(conversation.lastMessagePreview)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                        .onTapGesture {
                            appState.selectConversation(conversation)
                            navigationRouter.navigate(to: .chat)
                        }
                    }
                }
            }
            
            Section(header: Text("User")) {
                if let user = appState.currentUser {
                    HStack {
                        if let avatarUrl = user.avatarUrl {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle")
                            }
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle")
                                .frame(width: 24, height: 24)
                        }
                        
                        Text(user.name)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                } else {
                    Button(action: {
                        // TODO: Implement sign in action
                    }) {
                        Text("Sign In")
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
    }
}