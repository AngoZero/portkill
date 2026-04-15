import type { PortEntry } from '../app/types';
import clsx from 'clsx';

interface Props {
  entry: PortEntry;
  isNew: boolean;
  onKill: (entry: PortEntry) => void;
}

export function PortRow({ entry, isNew, onKill }: Props) {
  const displayHost =
    entry.hostAddress === '*' ? 'all interfaces' : entry.hostAddress;

  return (
    <div className={clsx('port-row', isNew && 'port-row--new')}>
      {isNew && <div className="port-row__new-bar" />}
      <div className="port-row__info">
        <span className="port-row__name">{entry.processName}</span>
        <span className="port-row__meta">
          <span className="port-row__port">:{entry.port}</span>
          <span className="port-row__badge">{entry.protocol}</span>
          <span className="port-row__host">{displayHost}</span>
        </span>
        <span className="port-row__pid">PID {entry.pid}</span>
      </div>
      <div className="port-row__action">
        {entry.isOwnedByCurrentUser ? (
          <button className="btn-kill" onClick={() => onKill(entry)}>
            KILL
          </button>
        ) : (
          <span className="badge-system">SYSTEM</span>
        )}
      </div>
    </div>
  );
}
