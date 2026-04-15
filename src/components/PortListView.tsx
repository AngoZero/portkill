import { usePortScanner } from '../hooks/usePortScanner';
import { Header } from './Header';
import { TabBar } from './TabBar';
import { PortRow } from './PortRow';
import { KillModal } from './KillModal';
import { EmptyState } from './EmptyState';
import { ErrorBanner } from './ErrorBanner';
import { Footer } from './Footer';

export function PortListView() {
  const state = usePortScanner();

  const filtered = state.entries.filter((e) =>
    state.selectedTab === 'local' ? e.isLocalDev : !e.isLocalDev,
  );

  return (
    <div className="app">
      <Header scanning={state.scanning} onRefresh={state.refresh} />
      <div className="divider" />
      <TabBar entries={state.entries} selected={state.selectedTab} onChange={state.setTab} />

      {state.error && (
        <ErrorBanner message={state.error} onDismiss={state.dismissError} />
      )}

      <div className="content">
        {state.loading ? (
          <div className="scanning">
            <span className="scanning__dot" />
            SCANNING...
          </div>
        ) : filtered.length === 0 ? (
          <EmptyState onRefresh={state.refresh} />
        ) : (
          <div className="port-list">
            {filtered.map((entry) => (
              <PortRow
                key={entry.id}
                entry={entry}
                isNew={state.newIds.has(entry.id)}
                onKill={state.requestKill}
              />
            ))}
          </div>
        )}
      </div>

      <div className="divider" />
      <Footer count={state.entries.length} lastScanTime={state.lastScanTime} />

      {state.pendingKill && (
        <KillModal
          entry={state.pendingKill}
          onConfirm={state.confirmKill}
          onCancel={state.cancelKill}
        />
      )}
    </div>
  );
}
