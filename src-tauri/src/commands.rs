use crate::{scanner, terminator, types::PortEntry};

fn current_user() -> String {
    std::env::var("USER")
        .or_else(|_| std::env::var("USERNAME"))
        .unwrap_or_else(|_| "unknown".to_string())
}

#[tauri::command]
pub fn scan_ports() -> Result<Vec<PortEntry>, String> {
    let user = current_user();
    scanner::scan_ports(&user)
}

#[tauri::command]
pub fn kill_process(pid: i32) -> Result<(), String> {
    terminator::kill_process(pid)
}
