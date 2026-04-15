mod commands;
mod scanner;
mod terminator;
mod types;

use tauri::{
    tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
    Manager,
};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            // No dock icon on macOS — behave like a menu bar accessory
            #[cfg(target_os = "macos")]
            app.set_activation_policy(tauri::ActivationPolicy::Accessory);

            // Build system tray icon
            let _tray = TrayIconBuilder::new()
                .icon(app.default_window_icon().unwrap().clone())
                .tooltip("PortKill")
                .on_tray_icon_event(|tray, event| {
                    if let TrayIconEvent::Click {
                        button: MouseButton::Left,
                        button_state: MouseButtonState::Up,
                        ..
                    } = event
                    {
                        let app = tray.app_handle();
                        toggle_window(app);
                    }
                })
                .build(app)?;

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::scan_ports,
            commands::kill_process,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

fn toggle_window(app: &tauri::AppHandle) {
    if let Some(win) = app.get_webview_window("main") {
        match win.is_visible() {
            Ok(true) => {
                let _ = win.hide();
            }
            _ => {
                position_near_tray(&win);
                let _ = win.show();
                let _ = win.set_focus();
            }
        }
    }
}

fn position_near_tray(win: &tauri::WebviewWindow) {
    let Ok(Some(monitor)) = win.primary_monitor() else {
        return;
    };
    let screen = monitor.size();
    let Ok(win_size) = win.outer_size() else {
        return;
    };

    // macOS: top-right below menu bar  |  Windows: bottom-right above taskbar
    #[cfg(target_os = "macos")]
    let (x, y) = (
        screen.width as i32 - win_size.width as i32 - 16,
        28,
    );

    #[cfg(windows)]
    let (x, y) = (
        screen.width as i32 - win_size.width as i32 - 16,
        screen.height as i32 - win_size.height as i32 - 60,
    );

    #[cfg(not(any(target_os = "macos", windows)))]
    let (x, y) = (
        screen.width as i32 - win_size.width as i32 - 16,
        28,
    );

    let _ = win.set_position(tauri::PhysicalPosition::new(x, y));
}
