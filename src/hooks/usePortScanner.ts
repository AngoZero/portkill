import { useState, useEffect, useRef, useCallback } from 'react';
import type { PortEntry, Tab } from '../app/types';
import { scanPorts, killProcess } from '../services/portApi';

const REFRESH_MS = 2000;
const HIGHLIGHT_MS = 3000;

export interface ScannerState {
  entries: PortEntry[];
  selectedTab: Tab;
  newIds: Set<string>;
  pendingKill: PortEntry | null;
  error: string | null;
  lastScanTime: Date | null;
  loading: boolean;
  scanning: boolean;
}

export interface ScannerActions {
  setTab: (tab: Tab) => void;
  requestKill: (entry: PortEntry) => void;
  confirmKill: () => Promise<void>;
  cancelKill: () => void;
  dismissError: () => void;
  refresh: () => void;
}

export function usePortScanner(): ScannerState & ScannerActions {
  const [entries, setEntries] = useState<PortEntry[]>([]);
  const [selectedTab, setSelectedTab] = useState<Tab>('local');
  const [newIds, setNewIds] = useState<Set<string>>(new Set());
  const [pendingKill, setPendingKill] = useState<PortEntry | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lastScanTime, setLastScanTime] = useState<Date | null>(null);
  const [loading, setLoading] = useState(true);
  const [scanning, setScanning] = useState(false);

  const prevIds = useRef<Set<string>>(new Set());
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const timers = useRef<Map<string, ReturnType<typeof setTimeout>>>(new Map());

  const scan = useCallback(async (manual = false) => {
    if (manual) setScanning(true);
    try {
      const result = await scanPorts();
      const nextIds = new Set(result.map((e) => e.id));

      const added = result.filter((e) => !prevIds.current.has(e.id)).map((e) => e.id);
      prevIds.current = nextIds;

      setEntries(result);
      setLastScanTime(new Date());
      setLoading(false);

      if (added.length > 0) {
        setNewIds((prev) => {
          const next = new Set(prev);
          added.forEach((id) => next.add(id));
          return next;
        });
        added.forEach((id) => {
          const existing = timers.current.get(id);
          if (existing) clearTimeout(existing);
          const t = setTimeout(() => {
            setNewIds((prev) => {
              const next = new Set(prev);
              next.delete(id);
              return next;
            });
            timers.current.delete(id);
          }, HIGHLIGHT_MS);
          timers.current.set(id, t);
        });
      }
    } catch (err) {
      setError(String(err));
      setLoading(false);
    } finally {
      if (manual) setScanning(false);
    }
  }, []);

  useEffect(() => {
    scan();
    intervalRef.current = setInterval(() => scan(), REFRESH_MS);
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      timers.current.forEach((t) => clearTimeout(t));
    };
  }, [scan]);

  const setTab = useCallback((tab: Tab) => setSelectedTab(tab), []);
  const refresh = useCallback(() => scan(true), [scan]);
  const requestKill = useCallback((entry: PortEntry) => setPendingKill(entry), []);
  const cancelKill = useCallback(() => setPendingKill(null), []);
  const dismissError = useCallback(() => setError(null), []);

  const confirmKill = useCallback(async () => {
    if (!pendingKill) return;
    try {
      await killProcess(pendingKill.pid);
      setPendingKill(null);
      await scan();
    } catch (err) {
      setError(String(err));
      setPendingKill(null);
    }
  }, [pendingKill, scan]);

  return {
    entries,
    selectedTab,
    newIds,
    pendingKill,
    error,
    lastScanTime,
    loading,
    scanning,
    setTab,
    requestKill,
    confirmKill,
    cancelKill,
    dismissError,
    refresh,
  };
}
