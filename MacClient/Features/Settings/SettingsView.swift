import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("theme") private var theme: String = "system"
    @AppStorage("fontSize") private var fontSize: Double = 14.0
    @AppStorage("enableNotifications") private var enableNotifications: Bool = true
    
    var body: some View {
        Form {
            Section(header: Text("API Configuration")) {
                SecureField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Verify API Key") {
                    // Verify API key functionality
                }
                .disabled(apiKey.isEmpty)
            }
            
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $theme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                VStack(alignment: .leading) {
                    Text("Font Size: \(Int(fontSize))")
                    Slider(value: $fontSize, in: 10...24, step: 1)
                }
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $enableNotifications)
                
                if enableNotifications {
                    Toggle("New Message Alerts", isOn: .constant(true))
                    Toggle("Repository Updates", isOn: .constant(true))
                    Toggle("Mention Alerts", isOn: .constant(true))
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2023.1")
                        .foregroundColor(.secondary)
                }
                
                Link("View on GitHub", destination: URL(string: "https://github.com/enyst/MacClient")!)
                
                Link("Report an Issue", destination: URL(string: "https://github.com/enyst/MacClient/issues/new")!)
            }
        }
        .padding()
        .frame(maxWidth: 600)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}