import type { PortEntry } from '../app/types';

interface Props {
  entry: PortEntry;
  onConfirm: () => void;
  onCancel: () => void;
}

export function KillModal({ entry, onConfirm, onCancel }: Props) {
  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <p className="modal__label">KILL PROCESS</p>
        <h2 className="modal__name">{entry.processName}</h2>
        <table className="modal__table">
          <tbody>
            <tr>
              <td>PID</td>
              <td>{entry.pid}</td>
            </tr>
            <tr>
              <td>PORT</td>
              <td>:{entry.port}</td>
            </tr>
            <tr>
              <td>PROTO</td>
              <td>{entry.protocol}</td>
            </tr>
            <tr>
              <td>ADDR</td>
              <td>{entry.hostAddress === '*' ? 'all interfaces' : entry.hostAddress}</td>
            </tr>
          </tbody>
        </table>
        <p className="modal__warning">Send SIGTERM to this process.</p>
        <div className="modal__actions">
          <button className="btn-outline" onClick={onCancel}>
            CANCEL
          </button>
          <button className="btn-kill" onClick={onConfirm}>
            KILL
          </button>
        </div>
      </div>
    </div>
  );
}
