import SwiftUI

struct PortListView: View {
    @Bindable var viewModel: PortListViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(isLoading: viewModel.isManualLoading, onRefresh: { viewModel.scan(manual: true) })

            Rectangle()
                .frame(height: BrutalistTokens.borderWidth)
                .foregroundStyle(BrutalistTokens.border)

            TabBarView(selectedTab: $viewModel.selectedTab, countForTab: viewModel.count)

            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage, onDismiss: viewModel.dismissError)

                Rectangle()
                    .frame(height: BrutalistTokens.borderWidth)
                    .foregroundStyle(BrutalistTokens.border)
            }

            contentArea

            FooterView(portCount: viewModel.filteredPortCount, lastScanTime: viewModel.lastScanTime)
        }
        .background(BrutalistTokens.background)
        .frame(width: 480)
        .overlay {
            if viewModel.showKillConfirmation, let entry = viewModel.pendingKillEntry {
                KillConfirmationModal(
                    entry: entry,
                    onCancel: viewModel.cancelKill,
                    onConfirm: viewModel.confirmKill
                )
            }
        }
        .onAppear {
            if viewModel.entries.isEmpty {
                viewModel.scan()
            }
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.entries.isEmpty {
            VStack(spacing: 10) {
                ProgressView()
                    .scaleEffect(0.85)
                Text("SCANNING...")
                    .font(BrutalistTokens.labelFont)
                    .foregroundStyle(BrutalistTokens.textSecondary)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.filteredEntries.isEmpty {
            EmptyStateView(onRefresh: { viewModel.scan(manual: true) })
        } else {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.filteredEntries.enumerated()), id: \.element.id) { index, entry in
                        PortRowView(
                            entry: entry,
                            rowIndex: index,
                            isNew: viewModel.newEntryIDs.contains(entry.id),
                            onKill: viewModel.requestKill
                        )
                    }
                }
            }
        }
    }
}
