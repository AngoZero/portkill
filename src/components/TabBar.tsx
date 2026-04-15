import type { PortEntry, Tab } from '../app/types';

interface Props {
  entries: PortEntry[];
  selected: Tab;
  onChange: (tab: Tab) => void;
}

export function TabBar({ entries, selected, onChange }: Props) {
  const localCount = entries.filter((e) => e.isLocalDev).length;
  const systemCount = entries.filter((e) => !e.isLocalDev).length;

  return (
    <div className="tabbar">
      <button
        className={`tabbar__tab ${selected === 'local' ? 'tabbar__tab--active' : ''}`}
        onClick={() => onChange('local')}
      >
        LOCAL
        <span className="tabbar__count">{localCount}</span>
      </button>
      <button
        className={`tabbar__tab ${selected === 'system' ? 'tabbar__tab--active' : ''}`}
        onClick={() => onChange('system')}
      >
        SYSTEM
        <span className="tabbar__count">{systemCount}</span>
      </button>
    </div>
  );
}
