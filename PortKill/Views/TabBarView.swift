import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: PortTab
    let countForTab: (PortTab) -> Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PortTab.allCases, id: \.self) { tab in
                tabButton(tab)

                if tab != PortTab.allCases.last {
                    Rectangle()
                        .frame(width: BrutalistTokens.borderWidth)
                        .foregroundStyle(BrutalistTokens.border)
                }
            }
        }
        .frame(height: 34)
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: BrutalistTokens.borderWidth)
                .foregroundStyle(BrutalistTokens.border)
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: PortTab) -> some View {
        let isActive = selectedTab == tab
        let count = countForTab(tab)

        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 5) {
                Text(tab.rawValue)
                    .font(BrutalistTokens.labelFont)
                    .tracking(1)

                Text("\(count)")
                    .font(BrutalistTokens.footerFont)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isActive ? Color.white.opacity(0.15) : BrutalistTokens.surface)
                    .cornerRadius(2)
            }
            .foregroundStyle(isActive ? BrutalistTokens.tabActiveFg : BrutalistTokens.tabInactiveFg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isActive ? BrutalistTokens.tabActiveBg : BrutalistTokens.background)
        }
        .buttonStyle(.plain)
    }
}
