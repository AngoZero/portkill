export interface PortEntry {
  id: string;
  processName: string;
  pid: number;
  port: number;
  protocol: string;
  user: string;
  hostAddress: string;
  isOwnedByCurrentUser: boolean;
  isLocalDev: boolean;
}

export type Tab = 'local' | 'system';
