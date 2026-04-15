import Foundation
import Observation

enum PortTab: String, CaseIterable {
    case local  = "LOCAL"
    case system = "SYSTEM"
}

@MainActor
@Observable
final class PortListViewModel {
    var entries: [PortEntry] = []
    var isLoading = false        // guards against concurrent scans (auto + manual)
    var isManualLoading = false  // drives the spinner in the Refresh button
    var lastScanTime: Date?
    var errorMessage: String?
    var selectedTab: PortTab = .local

    /// IDs de entradas que acaban de aparecer — usados para el highlight verde.
    var newEntryIDs: Set<String> = []

    // Kill confirmation flow
    var pendingKillEntry: PortEntry?
    var showKillConfirmation = false

    private let scanner = PortScanner()
    private let terminator = ProcessTerminator()
    private var autoRefreshTask: Task<Void, Never>?
    private static let autoRefreshInterval: Duration = .seconds(2)
    private static let highlightDuration: Duration   = .seconds(3)

    // MARK: - Scanning

    func scan(manual: Bool = false) {
        guard !isLoading else { return }
        isLoading = true
        if manual { isManualLoading = true }
        errorMessage = nil

        Task {
            do {
                let result = try await scanner.scanListeningPorts()
                applyDiff(newEntries: result)
                self.lastScanTime = Date()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
            self.isManualLoading = false
        }
    }

    // MARK: - Diff & Highlight

    private func applyDiff(newEntries: [PortEntry]) {
        let currentIDs = Set(entries.map(\.id))
        let newIDs     = Set(newEntries.map(\.id))

        let added   = newIDs.subtracting(currentIDs)
        let removed = currentIDs.subtracting(newIDs)

        // Only update entries when something actually changed
        guard !added.isEmpty || !removed.isEmpty else { return }

        entries = newEntries

        // Schedule highlight removal after 3s
        if !added.isEmpty {
            newEntryIDs.formUnion(added)
            let toRemove = added
            Task {
                try? await Task.sleep(for: Self.highlightDuration)
                self.newEntryIDs.subtract(toRemove)
            }
        }
    }

    // MARK: - Kill Flow

    func requestKill(_ entry: PortEntry) {
        pendingKillEntry = entry
        showKillConfirmation = true
    }

    func confirmKill() {
        guard let entry = pendingKillEntry else { return }
        pendingKillEntry = nil

        let result = terminator.terminate(pid: entry.pid)

        if let message = result.errorMessage {
            errorMessage = message
        } else {
            entries.removeAll { $0.id == entry.id }
            newEntryIDs.remove(entry.id)
        }
    }

    func cancelKill() {
        pendingKillEntry = nil
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Auto-refresh

    func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.autoRefreshInterval)
                guard !Task.isCancelled else { break }
                scan()
            }
        }
    }

    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    // MARK: - Computed

    var filteredEntries: [PortEntry] {
        switch selectedTab {
        case .local:  return entries.filter { $0.isLocalDev }
        case .system: return entries.filter { !$0.isLocalDev }
        }
    }

    var filteredPortCount: Int { filteredEntries.count }

    func count(for tab: PortTab) -> Int {
        switch tab {
        case .local:  return entries.filter { $0.isLocalDev }.count
        case .system: return entries.filter { !$0.isLocalDev }.count
        }
    }
}
