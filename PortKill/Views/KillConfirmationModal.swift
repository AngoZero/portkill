import SwiftUI

struct KillConfirmationModal: View {
    let entry: PortEntry
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            // Backdrop — bloquea clicks hacia las vistas de abajo
            Color.black.opacity(0.45)
                .contentShape(Rectangle())
                .onTapGesture { onCancel() }

            // Modal box centrado
            modalBox
                .padding(.horizontal, 28)
        }
    }

    private var modalBox: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            Text("KILL PROCESS?")
                .font(BrutalistTokens.appTitleFont)
                .foregroundStyle(BrutalistTokens.text)
                .tracking(1.5)
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 14)

            Rectangle()
                .frame(height: BrutalistTokens.borderWidth)
                .foregroundStyle(BrutalistTokens.borderLight)

            // Body
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(entry.processName)
                        .font(BrutalistTokens.processNameFont)
                        .foregroundStyle(BrutalistTokens.text)

                    Spacer()

                    Text("PID \(entry.pid)")
                        .font(BrutalistTokens.monoSmallFont)
                        .foregroundStyle(BrutalistTokens.textSecondary)
                }

                HStack(spacing: 6) {
                    Text(entry.protocolType.rawValue)
                        .font(BrutalistTokens.footerFont)
                        .foregroundStyle(BrutalistTokens.badgeFg)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .overlay {
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(BrutalistTokens.badgeBorder, lineWidth: 1)
                        }

                    Text(":\(entry.port)")
                        .font(BrutalistTokens.portNumberFont)
                        .foregroundStyle(BrutalistTokens.text)

                    Text(entry.displayAddress)
                        .font(BrutalistTokens.monoSmallFont)
                        .foregroundStyle(BrutalistTokens.textSecondary)
                }

                Text("Send SIGTERM to this process. If it does not stop, it may need to be killed manually.")
                    .font(BrutalistTokens.monoSmallFont)
                    .foregroundStyle(BrutalistTokens.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
            .padding(18)

            Rectangle()
                .frame(height: BrutalistTokens.borderWidth)
                .foregroundStyle(BrutalistTokens.borderLight)

            // Actions
            HStack(spacing: 10) {
                // Cancel
                Button(action: onCancel) {
                    Text("CANCEL")
                        .font(BrutalistTokens.labelFont)
                        .foregroundStyle(BrutalistTokens.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .overlay {
                    RoundedRectangle(cornerRadius: BrutalistTokens.cornerRadius)
                        .stroke(BrutalistTokens.border, lineWidth: BrutalistTokens.borderWidth)
                }

                // Kill
                Button(action: onConfirm) {
                    Text("KILL \(entry.processName.uppercased())")
                        .font(BrutalistTokens.labelFont)
                        .foregroundStyle(BrutalistTokens.killFg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(BrutalistTokens.killBg)
                .cornerRadius(BrutalistTokens.cornerRadius)
            }
            .padding(14)
        }
        .background(BrutalistTokens.background)
        .cornerRadius(3)
        .overlay {
            RoundedRectangle(cornerRadius: 3)
                .stroke(BrutalistTokens.border, lineWidth: 2)
        }
    }
}
