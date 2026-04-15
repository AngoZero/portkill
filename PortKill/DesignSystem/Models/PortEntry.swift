import Foundation

enum PortProtocol: String, Sendable, CaseIterable, Hashable {
    case tcp = "TCP"
    case udp = "UDP"
}

struct PortEntry: Identifiable, Hashable, Sendable {
    let id: String              // "\(pid)-\(port)-\(protocolType.rawValue)"
    let processName: String
    let pid: Int32
    let port: UInt16
    let protocolType: PortProtocol
    let user: String
    let hostAddress: String     // "*", "127.0.0.1", "[::1]", etc.
    let isOwnedByCurrentUser: Bool

    var displayAddress: String {
        hostAddress == "*" ? "all interfaces" : hostAddress
    }

    /// True when the socket is bound to the loopback interface (localhost / development).
    var isLocalDev: Bool {
        hostAddress == "127.0.0.1" || hostAddress == "[::1]" || hostAddress == "localhost"
    }
}
