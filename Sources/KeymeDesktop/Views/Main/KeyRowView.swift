import SwiftUI

struct KeyRowView: View {
    let entry: KeyEntry
    let providerName: String
    let isRevealed: Bool
    let dashboardURL: String?
    let onReveal: () -> Void
    let onCopy: () -> Void
    let onPlayground: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(providerName)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Theme.accent)
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .background(Theme.accentSubtle).cornerRadius(3)
                    Text(entry.alias)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Theme.textPrimary)
                }
                if !entry.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(Theme.textSecondary)
                                .padding(.horizontal, 5).padding(.vertical, 1)
                                .background(Color.white.opacity(0.04)).cornerRadius(2)
                        }
                    }
                }
            }
            Spacer()
            Text(isRevealed ? entry.apiKey : KeyMasking.mask(entry.apiKey))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(isRevealed ? Theme.textPrimary : Theme.textSecondary)
                .textSelection(.enabled)
            HStack(spacing: 8) {
                Button(action: onReveal) { Image(systemName: isRevealed ? "eye.slash" : "eye").font(.system(size: 11)) }.buttonStyle(.plain).foregroundColor(Theme.textSecondary)
                Button(action: onCopy) { Image(systemName: "doc.on.doc").font(.system(size: 11)) }.buttonStyle(.plain).foregroundColor(Theme.textSecondary)
                Button(action: onPlayground) { Image(systemName: "play.fill").font(.system(size: 10)) }.buttonStyle(.plain).foregroundColor(Theme.textSecondary)
                if let url = dashboardURL, let link = URL(string: url) {
                    Link(destination: link) { Image(systemName: "arrow.up.right.square").font(.system(size: 11)) }.foregroundColor(Theme.textSecondary)
                }
                Button(action: onDelete) { Image(systemName: "xmark").font(.system(size: 10)) }.buttonStyle(.plain).foregroundColor(Theme.danger.opacity(0.5))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
