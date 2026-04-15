import SwiftUI

struct FooterView: View {
    let portCount: Int
    let lastScanTime: Date?

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    var body: some View {
        HStack {
            Text("\(portCount) PORT\(portCount == 1 ? "" : "S") LISTENING")
                .font(BrutalistTokens.footerFont)
                .foregroundStyle(BrutalistTokens.textSecondary)

            Spacer()

            if let time = lastScanTime {
                Text("LAST SCAN \(Self.timeFormatter.string(from: time))")
                    .font(BrutalistTokens.footerFont)
                    .foregroundStyle(BrutalistTokens.textSecondary)
            }
        }
        .padding(.horizontal, BrutalistTokens.rowPaddingH)
        .padding(.vertical, 8)
        .background(BrutalistTokens.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .frame(height: BrutalistTokens.borderWidth)
                .foregroundStyle(BrutalistTokens.borderLight)
        }
    }
}
