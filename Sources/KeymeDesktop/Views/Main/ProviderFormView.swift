import SwiftUI

struct ProviderFormView: View {
    @State var name = ""
    @State var baseURL = ""
    @State var dashboardURL = ""
    let onSave: (Provider) -> Void
    @Environment(\.dismiss) var dismiss

    private static let presets: [(String, String, String)] = [
        ("OpenAI", "https://api.openai.com/v1", "https://platform.openai.com/api-keys"),
        ("Anthropic", "https://api.anthropic.com/v1", "https://console.anthropic.com/settings/keys"),
        ("OpenRouter", "https://openrouter.ai/api/v1", "https://openrouter.ai/keys"),
        ("Google AI", "https://generativelanguage.googleapis.com/v1beta", "https://aistudio.google.com/apikey"),
        ("Groq", "https://api.groq.com/openai/v1", "https://console.groq.com/keys"),
        ("xAI", "https://api.x.ai/v1", "https://console.x.ai"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("add provider").font(.system(size: 14, weight: .semibold, design: .monospaced)).foregroundColor(Theme.accent)

            Text("presets").font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Self.presets, id: \.0) { p in
                        Button(p.0) { name = p.0; baseURL = p.1; dashboardURL = p.2 }
                            .font(.system(size: 10, design: .monospaced)).buttonStyle(.plain)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Theme.bgSecondary).foregroundColor(Theme.textPrimary).cornerRadius(4)
                    }
                }
            }

            field("name", text: $name, placeholder: "provider name")
            field("base url", text: $baseURL, placeholder: "https://api.example.com/v1")
            field("dashboard url", text: $dashboardURL, placeholder: "https://console.example.com (optional)")

            HStack {
                Spacer()
                Button("save") {
                    onSave(Provider(name: name, baseURL: baseURL, dashboardURL: dashboardURL.isEmpty ? nil : dashboardURL))
                    dismiss()
                }
                .font(.system(size: 11, design: .monospaced)).buttonStyle(.plain).foregroundColor(Theme.accent)
                .disabled(name.isEmpty || baseURL.isEmpty)
            }
        }
        .padding(16).frame(width: 400).background(Theme.bgPrimary)
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textSecondary)
            TextField(placeholder, text: text)
                .font(.system(size: 11, design: .monospaced)).textFieldStyle(.plain)
                .padding(8).background(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border)).cornerRadius(6)
        }
    }
}
