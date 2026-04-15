import SwiftUI

@main
struct PortKillApp: App {
    @State private var viewModel = PortListViewModel()

    var body: some Scene {
        MenuBarExtra {
            PortListView(viewModel: viewModel)
        } label: {
            Image(systemName: "scissors")
                .help("PortKill — Monitor listening ports")
        }
        .menuBarExtraStyle(.window)
    }
}
