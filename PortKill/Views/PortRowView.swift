import SwiftUI

struct PortRowView: View {
    let entry: PortEntry
    let rowIndex: Int
    let isNew: Bool
    let onKill: (PortEntry) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {

            // Left: process name + connection info
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.processName)
                    .font(BrutalistTokens.processNameFont)
                    .foregroundStyle(BrutalistTokens.text)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack(spacing: 6) {
                    // Protocol badge
                    Text(entry.protocolType.rawValue)
                        .font(BrutalistTokens.footerFont)
                        .foregroundStyle(BrutalistTokens.badgeFg)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .overlay {
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(BrutalistTokens.badgeBorder, lineWidth: 1)
                        }

                    // Port number — most prominent element
                    Text(":\(entry.port)")
                        .font(BrutalistTokens.portNumberFont)
                        .foregroundStyle(BrutalistTokens.text)

                    // Bound address
                    Text(entry.displayAddress)
                        .font(BrutalistTokens.monoSmallFont)
                        .foregroundStyle(BrutalistTokens.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            // Right: PID + user + action
            VStack(alignment: .trailing, spacing: 4) {
                Text("PID \(entry.pid)")
                    .font(BrutalistTokens.monoSmallFont)
                    .foregroundStyle(BrutalistTokens.textSecondary)

                HStack(spacing: 5) {
                    Text(entry.user)
                        .font(BrutalistTokens.footerFont)
                        .foregroundStyle(BrutalistTokens.textSecondary)

                    actionButton
                }
            }
        }
        .padding(.horizontal, BrutalistTokens.rowPaddingH)
        .padding(.vertical, BrutalistTokens.rowPaddingV)
        .background(rowIndex.isMultiple(of: 2) ? BrutalistTokens.background : BrutalistTokens.surface)
        .overlay(alignment: .leading) {
            if isNew {
                Rectangle()
                    .frame(width: 3)
                    .foregroundStyle(BrutalistTokens.newEntryAccent)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: BrutalistTokens.borderWidth)
                .foregroundStyle(BrutalistTokens.borderLight)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if entry.isOwnedByCurrentUser {
            Button("KILL") { onKill(entry) }
                .font(BrutalistTokens.labelFont)
                .foregroundStyle(BrutalistTokens.killFg)
                .padding(.horizontal, BrutalistTokens.buttonPaddingH)
                .padding(.vertical, BrutalistTokens.buttonPaddingV)
                .background(BrutalistTokens.killBg)
                .cornerRadius(BrutalistTokens.cornerRadius)
                .buttonStyle(.plain)
        } else {
            Text("SYSTEM")
                .font(BrutalistTokens.labelFont)
                .foregroundStyle(BrutalistTokens.systemFg)
                .padding(.horizontal, BrutalistTokens.buttonPaddingH)
                .padding(.vertical, BrutalistTokens.buttonPaddingV)
                .background(BrutalistTokens.systemBg)
                .cornerRadius(BrutalistTokens.cornerRadius)
        }
    }
}
