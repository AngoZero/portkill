import Darwin

struct ProcessTerminator: Sendable {

    enum TerminationResult: Sendable {
        case success
        case permissionDenied
        case processNotFound
        case failed(String)

        var errorMessage: String? {
            switch self {
            case .success:
                return nil
            case .permissionDenied:
                return "Permission denied — cannot kill a system or root process."
            case .processNotFound:
                return "Process not found — it may have already exited."
            case .failed(let msg):
                return "Kill failed: \(msg)"
            }
        }
    }

    func terminate(pid: Int32) -> TerminationResult {
        let result = kill(pid, SIGTERM)
        guard result != 0 else { return .success }

        switch errno {
        case EPERM:  return .permissionDenied
        case ESRCH:  return .processNotFound
        default:
            let msg = String(cString: strerror(errno))
            return .failed(msg)
        }
    }
}
