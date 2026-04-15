import Foundation

struct PortScanner: Sendable {

    static let lsofPath = "/usr/sbin/lsof"

    func scanListeningPorts() async throws -> [PortEntry] {
        guard FileManager.default.fileExists(atPath: Self.lsofPath) else {
            throw ScanError.lsofNotFound
        }

        let output = try await runCommand(
            path: Self.lsofPath,
            arguments: ["-i", "-P", "-n", "-sTCP:LISTEN", "-F", "pcuLPnT"]
        )

        let entries = parseLsofOutput(output)
        return deduplicated(entries).sorted { $0.port < $1.port }
    }

    // MARK: - Process Execution

    private func runCommand(path: String, arguments: [String]) async throws -> String {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: path)
                process.arguments = arguments

                let outputPipe = Pipe()
                let errorPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                do {
                    try process.run()
                    process.waitUntilExit()
                    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    continuation.resume(returning: output)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Parsing
    //
    // lsof -F output: each field on its own line prefixed by a single char.
    //   p = PID (marks start of new process block)
    //   c = command name (full, not truncated)
    //   L = login name
    //   f = file descriptor (marks start of new FD block)
    //   P = protocol ("TCP" / "UDP")
    //   n = node name ("*:8080", "127.0.0.1:5432", "[::1]:3000")
    //   T = TCP state sub-field ("ST=LISTEN", "QR=0", …)

    nonisolated private func parseLsofOutput(_ output: String) -> [PortEntry] {
        let currentUserName = ProcessInfo.processInfo.userName
        var results: [PortEntry] = []
        var state = ParseState()

        for line in output.components(separatedBy: "\n") {
            guard !line.isEmpty, let prefix = line.first else { continue }
            let value = String(line.dropFirst())

            switch prefix {
            case "p":
                // New process block: flush pending FD, reset everything
                if let entry = state.makeEntry(currentUserName: currentUserName) {
                    results.append(entry)
                }
                state.resetAll()
                state.currentPID = Int32(value)

            case "c":
                state.currentCommand = value

            case "L":
                state.currentUser = value

            case "f":
                // New file-descriptor block: flush pending FD, reset FD fields only
                if let entry = state.makeEntry(currentUserName: currentUserName) {
                    results.append(entry)
                }
                state.resetFD()

            case "P":
                state.fdProtocol = value

            case "n":
                state.fdName = value

            case "T":
                // Multiple T sub-fields may appear; only capture the state one
                if value.hasPrefix("ST=") {
                    state.fdTCPState = String(value.dropFirst(3))
                }

            default:
                break
            }
        }

        // Flush final entry
        if let entry = state.makeEntry(currentUserName: currentUserName) {
            results.append(entry)
        }

        return results
    }

    // MARK: - Port & Host Extraction

    nonisolated static func extractPort(from name: String) -> UInt16? {
        // IPv6: [::1]:5432 — port is after "]:"
        if let bracketEnd = name.lastIndex(of: "]") {
            let afterBracket = name[name.index(after: bracketEnd)...]
            guard afterBracket.hasPrefix(":") else { return nil }
            return UInt16(afterBracket.dropFirst())
        }
        // IPv4 or wildcard: *:62909, 127.0.0.1:9000 — port is after last ":"
        if let lastColon = name.lastIndex(of: ":") {
            return UInt16(name[name.index(after: lastColon)...])
        }
        return nil
    }

    nonisolated static func extractHost(from name: String) -> String {
        // IPv6: [::1]:5432 → "[::1]"
        if let bracketEnd = name.lastIndex(of: "]") {
            return String(name[...bracketEnd])
        }
        // IPv4 or wildcard: 127.0.0.1:9000 → "127.0.0.1",  *:8080 → "*"
        if let lastColon = name.lastIndex(of: ":") {
            return String(name[..<lastColon])
        }
        return name
    }

    // MARK: - Deduplication
    //
    // One process can have both IPv4 and IPv6 sockets on the same port.
    // Keep only the first occurrence per (pid, port, protocol) triple.

    nonisolated private func deduplicated(_ entries: [PortEntry]) -> [PortEntry] {
        var seen = Set<String>()
        return entries.filter { seen.insert($0.id).inserted }
    }
}

// MARK: - Parse State

/// Lightweight value-type state machine for the lsof -F output parser.
private struct ParseState {
    var currentPID: Int32?
    var currentCommand = ""
    var currentUser = ""
    var fdProtocol: String?
    var fdName: String?
    var fdTCPState: String?

    /// Attempt to build a PortEntry from the current FD fields.
    /// Returns nil if required fields are missing or the entry should be filtered out.
    func makeEntry(currentUserName: String) -> PortEntry? {
        guard let pid = currentPID,
              let proto = fdProtocol,
              let name = fdName else { return nil }

        // V1: TCP LISTEN only.
        // Note: -sTCP:LISTEN doesn't suppress UDP entries from lsof output.
        guard proto == "TCP" else { return nil }
        guard fdTCPState == "LISTEN" else { return nil }

        // Skip fully-unresolved wildcard entries
        if name == "*:*" { return nil }

        guard let port = PortScanner.extractPort(from: name) else { return nil }
        let host = PortScanner.extractHost(from: name)

        return PortEntry(
            id: "\(pid)-\(port)-\(proto)",
            processName: currentCommand,
            pid: pid,
            port: port,
            protocolType: proto == "TCP" ? .tcp : .udp,
            user: currentUser,
            hostAddress: host,
            isOwnedByCurrentUser: currentUser == currentUserName
        )
    }

    mutating func resetFD() {
        fdProtocol = nil
        fdName = nil
        fdTCPState = nil
    }

    mutating func resetAll() {
        currentPID = nil
        currentCommand = ""
        currentUser = ""
        resetFD()
    }
}

// MARK: - Errors

enum ScanError: LocalizedError {
    case lsofNotFound

    var errorDescription: String? {
        "lsof not found at \(PortScanner.lsofPath). Cannot scan ports."
    }
}
