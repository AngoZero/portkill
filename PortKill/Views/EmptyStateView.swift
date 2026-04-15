import SwiftUI

struct EmptyStateView: View {
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("NO LISTENING PORTS")
                .font(BrutalistTokens.labelFont)
                .foregroundStyle(BrutalistTokens.textSecondary)
                .tracking(1)

            Text("No TCP sockets in LISTEN state were found.")
                .font(BrutalistTokens.monoSmallFont)
                .foregroundStyle(BrutalistTokens.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: onRefresh) {
                Text("REFRESH")
                    .font(BrutalistTokens.labelFont)
                    .foregroundStyle(BrutalistTokens.refreshFg)
                    .padding(.horizontal, BrutalistTokens.buttonPaddingH)
                    .padding(.vertical, BrutalistTokens.buttonPaddingV)
                    .background(BrutalistTokens.refreshBg)
                    .cornerRadius(BrutalistTokens.cornerRadius)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(BrutalistTokens.rowPaddingH)
    }
}
