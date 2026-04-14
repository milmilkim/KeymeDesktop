import SwiftUI

struct PlaygroundView: View {
    @ObservedObject var vm: PlaygroundViewModel

    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 8) {
                Text("request").font(.system(size: 10, design: .monospaced)).foregroundColor(Theme.textSecondary)
                HStack {
                    Picker("", selection: $vm.method) {
                        ForEach(vm.methods, id: \.self) { Text($0) }
                    }.frame(width: 80).font(.system(size: 11, design: .monospaced))
                    TextField("url", text: $vm.url).font(.system(size: 11, design: .monospaced)).textFieldStyle(.plain)
                        .padding(6).background(Theme.bgSecondary).cornerRadius(4)
                }
                Text("headers").font(.system(size: 10, design: .monospaced)).foregroundColor(Theme.textSecondary)
                ForEach($vm.headers) { $h in
                    HStack {
                        TextField("key", text: $h.key).font(.system(size: 10, design: .monospaced)).textFieldStyle(.plain)
                            .padding(4).background(Theme.bgSecondary).frame(width: 130)
                        TextField("value", text: $h.value).font(.system(size: 10, design: .monospaced)).textFieldStyle(.plain)
                            .padding(4).background(Theme.bgSecondary)
                    }
                }
                Button("+ header") { vm.headers.append(HTTPHeader(key: "", value: "")) }
                    .font(.system(size: 10, design: .monospaced)).buttonStyle(.plain).foregroundColor(Theme.accent)

                Text("body").font(.system(size: 10, design: .monospaced)).foregroundColor(Theme.textSecondary)
                TextEditor(text: $vm.body).font(.system(size: 10, design: .monospaced))
                    .scrollContentBackground(.hidden).background(Theme.bgSecondary).frame(minHeight: 150)

                HStack {
                    Spacer()
                    Button(action: { Task { await vm.send() } }) {
                        Text(vm.isLoading ? "sending..." : "send ⌘⏎")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.bgPrimary)
                            .padding(.horizontal, 16).padding(.vertical, 6)
                            .background(Theme.accent).cornerRadius(6)
                    }
                    .buttonStyle(.plain).disabled(vm.isLoading)
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }.padding(12)

            PlaygroundResponseView(status: vm.responseStatus, headers: vm.responseHeaders, responseBody: vm.responseBody)
                .padding(12)
        }.background(Theme.bgPrimary)
    }
}
