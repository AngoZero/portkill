import { invoke } from '@tauri-apps/api/core';
import type { PortEntry } from '../app/types';

export async function scanPorts(): Promise<PortEntry[]> {
  return invoke<PortEntry[]>('scan_ports');
}

export async function killProcess(pid: number): Promise<void> {
  return invoke<void>('kill_process', { pid });
}
