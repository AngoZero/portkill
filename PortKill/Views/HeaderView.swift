import SwiftUI

struct HeaderView: View {
    let isLoading: Bool
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("PORTKILL")
                .font(BrutalistTokens.appTitleFont)
                .foregroundStyle(BrutalistTokens.text)
                .tracking(2)

            Spacer()

            Button(action: onRefresh) {
                HStack(spacing: 5) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.55)
                            .frame(width: 11, height: 11)
                            .tint(BrutalistTokens.refreshFg)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(BrutalistTokens.refreshFg)
                    }
                    Text("REFRESH")
                        .font(BrutalistTokens.labelFont)
                        .foregroundStyle(BrutalistTokens.refreshFg)
                }
                .padding(.horizontal, BrutalistTokens.buttonPaddingH)
                .padding(.vertical, BrutalistTokens.buttonPaddingV)
                .background(BrutalistTokens.refreshBg)
                .cornerRadius(BrutalistTokens.cornerRadius)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
        .padding(.horizontal, BrutalistTokens.rowPaddingH)
        .padding(.vertical, 11)
        .background(BrutalistTokens.background)
    }
}
