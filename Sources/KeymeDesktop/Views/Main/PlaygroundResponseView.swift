import SwiftUI

struct PlaygroundResponseView: View {
    let status: String
    let headers: String
    let responseBody: String
    @State private var tab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("response").font(.system(size: 10, design: .monospaced)).foregroundColor(Theme.textSecondary)
                if !status.isEmpty {
                    Text(status).font(.system(size: 11, design: .monospaced))
                        .foregroundColor(statusColor)
                }
            }
            Picker("", selection: $tab) {
                Text("body").tag(0)
                Text("headers").tag(1)
            }.pickerStyle(.segmented).font(.system(size: 10, design: .monospaced))
            ScrollView {
                Text(tab == 0 ? responseBody : headers)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Theme.textPrimary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8).background(Theme.bgSecondary).cornerRadius(6)
        }
    }

    private var statusColor: Color {
        guard let c = Int(status) else { return Theme.danger }
        return c < 300 ? Theme.accent : c < 500 ? Color.orange : Theme.danger
    }
}
