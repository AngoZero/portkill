use std::collections::HashSet;
use std::process::Command;

use crate::types::PortEntry;

pub fn scan_ports(current_user: &str) -> Result<Vec<PortEntry>, String> {
    #[cfg(unix)]
    return scan_unix(current_user);

    #[cfg(windows)]
    return scan_windows(current_user);

    #[allow(unreachable_code)]
    Err("Unsupported platform".to_string())
}

// ─── macOS / Linux ───────────────────────────────────────────────────────────

#[cfg(unix)]
fn scan_unix(current_user: &str) -> Result<Vec<PortEntry>, String> {
    let output = Command::new("/usr/sbin/lsof")
        .args(["-i", "-P", "-n", "-sTCP:LISTEN", "-F", "pcLPn"])
        .output()
        .map_err(|e| format!("Failed to run lsof: {e}"))?;

    if !output.status.success() && output.stdout.is_empty() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    parse_lsof(&stdout, current_user)
}

#[cfg(unix)]
fn parse_lsof(output: &str, current_user: &str) -> Result<Vec<PortEntry>, String> {
    let mut entries: Vec<PortEntry> = Vec::new();
    let mut seen: HashSet<String> = HashSet::new();

    let mut pid: i32 = 0;
    let mut command = String::new();
    let mut user = String::new();
    let mut protocol = String::new();

    for line in output.lines() {
        if line.is_empty() {
            continue;
        }
        let key = &line[..1];
        let value = &line[1..];

        match key {
            "p" => {
                pid = value.parse().unwrap_or(0);
            }
            "c" => {
                command = value.to_string();
            }
            "L" => {
                user = value.to_string();
            }
            "P" => {
                protocol = value.to_uppercase();
            }
            "n" => {
                if let Some((host, port)) = parse_address(value) {
                    let id = format!("{}-{}-{}", pid, port, protocol);
                    if seen.insert(id) {
                        entries.push(PortEntry::new(
                            command.clone(),
                            pid,
                            port,
                            protocol.clone(),
                            user.clone(),
                            host,
                            current_user,
                        ));
                    }
                }
            }
            _ => {}
        }
    }

    entries.sort_by_key(|e| e.port);
    Ok(entries)
}

// ─── Windows ─────────────────────────────────────────────────────────────────

#[cfg(windows)]
fn scan_windows(current_user: &str) -> Result<Vec<PortEntry>, String> {
    use std::collections::HashMap;

    let output = Command::new("netstat")
        .args(["-ano", "-p", "TCP"])
        .output()
        .map_err(|e| format!("Failed to run netstat: {e}"))?;

    let stdout = String::from_utf8_lossy(&output.stdout);

    // Collect (host, port, pid) for LISTENING entries
    let mut pid_ports: Vec<(String, u16, i32)> = Vec::new();
    for line in stdout.lines() {
        let parts: Vec<&str> = line.split_whitespace().collect();
        if parts.len() >= 5 && parts[0].eq_ignore_ascii_case("TCP") && parts[3] == "LISTENING" {
            let pid: i32 = parts[4].parse().unwrap_or(0);
            if let Some((host, port)) = parse_address(parts[1]) {
                pid_ports.push((host, port, pid));
            }
        }
    }

    // Resolve process names for unique PIDs
    let unique_pids: HashSet<i32> = pid_ports.iter().map(|(_, _, p)| *p).collect();
    let mut pid_names: HashMap<i32, String> = HashMap::new();

    for pid in unique_pids {
        let out = Command::new("tasklist")
            .args(["/FI", &format!("PID eq {}", pid), "/FO", "CSV", "/NH"])
            .output();
        if let Ok(o) = out {
            let s = String::from_utf8_lossy(&o.stdout);
            if let Some(first) = s.split(',').next() {
                let name = first
                    .trim()
                    .trim_matches('"')
                    .trim_end_matches(".exe")
                    .to_string();
                if !name.is_empty() && !name.starts_with("INFO:") {
                    pid_names.insert(pid, name);
                }
            }
        }
    }

    let mut seen: HashSet<String> = HashSet::new();
    let mut entries: Vec<PortEntry> = Vec::new();

    for (host, port, pid) in pid_ports {
        let process_name = pid_names
            .get(&pid)
            .cloned()
            .unwrap_or_else(|| pid.to_string());
        let id = format!("{}-{}-TCP", pid, port);
        if seen.insert(id) {
            entries.push(PortEntry::new(
                process_name,
                pid,
                port,
                "TCP".to_string(),
                current_user.to_string(),
                host,
                current_user,
            ));
        }
    }

    entries.sort_by_key(|e| e.port);
    Ok(entries)
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

fn parse_address(addr: &str) -> Option<(String, u16)> {
    // Formats: "127.0.0.1:8080", "[::1]:3000", "*:80", "0.0.0.0:443"
    let last_colon = addr.rfind(':')?;
    let port: u16 = addr[last_colon + 1..].parse().ok()?;
    let raw_host = &addr[..last_colon];

    // Normalize IPv6
    let host = match raw_host {
        "[::1]" | "::1" => "[::1]".to_string(),
        h => h.to_string(),
    };

    Some((host, port))
}
