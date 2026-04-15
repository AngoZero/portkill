pub fn kill_process(pid: i32) -> Result<(), String> {
    #[cfg(unix)]
    return kill_unix(pid);

    #[cfg(windows)]
    return kill_windows(pid);

    #[allow(unreachable_code)]
    Err("Unsupported platform".to_string())
}

#[cfg(unix)]
fn kill_unix(pid: i32) -> Result<(), String> {
    let result = unsafe { libc::kill(pid, libc::SIGTERM) };
    if result == 0 {
        return Ok(());
    }
    match std::io::Error::last_os_error().raw_os_error() {
        Some(libc::EPERM) => Err("Permission denied — cannot kill a system or root process.".to_string()),
        Some(libc::ESRCH) => Err("Process not found — it may have already exited.".to_string()),
        _ => Err(format!("Failed to kill process {pid}")),
    }
}

#[cfg(windows)]
fn kill_windows(pid: i32) -> Result<(), String> {
    let output = std::process::Command::new("taskkill")
        .args(["/PID", &pid.to_string(), "/F"])
        .output()
        .map_err(|e| format!("Failed to run taskkill: {e}"))?;

    if output.status.success() {
        Ok(())
    } else {
        let msg = String::from_utf8_lossy(&output.stderr).to_string();
        Err(format!("Failed to kill process {pid}: {msg}"))
    }
}
