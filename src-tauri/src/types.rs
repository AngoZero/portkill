use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PortEntry {
    pub id: String,
    pub process_name: String,
    pub pid: i32,
    pub port: u16,
    pub protocol: String,
    pub user: String,
    pub host_address: String,
    pub is_owned_by_current_user: bool,
    pub is_local_dev: bool,
}

impl PortEntry {
    pub fn new(
        process_name: String,
        pid: i32,
        port: u16,
        protocol: String,
        user: String,
        host_address: String,
        current_user: &str,
    ) -> Self {
        let id = format!("{}-{}-{}", pid, port, protocol);
        let is_owned_by_current_user = user == current_user;
        let is_local_dev = matches!(
            host_address.as_str(),
            "127.0.0.1" | "::1" | "[::1]" | "localhost"
        );
        Self {
            id,
            process_name,
            pid,
            port,
            protocol,
            user,
            host_address,
            is_owned_by_current_user,
            is_local_dev,
        }
    }
}
