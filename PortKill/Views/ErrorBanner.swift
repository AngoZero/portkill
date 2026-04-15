import SwiftUI

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(BrutalistTokens.errorFg)

            Text(message)
                .font(BrutalistTokens.monoSmallFont)
                .foregroundStyle(BrutalistTokens.errorFg)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(BrutalistTokens.errorFg)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BrutalistTokens.rowPaddingH)
        .padding(.vertical, 9)
        .background(BrutalistTokens.errorBg)
    }
}
