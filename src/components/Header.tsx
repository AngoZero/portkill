import { RefreshCw } from 'lucide-react';
import clsx from 'clsx';

interface Props {
  scanning: boolean;
  onRefresh: () => void;
}

export function Header({ scanning, onRefresh }: Props) {
  return (
    <header className="header">
      <span className="header__title">PORTKILL</span>
      <div className="header__actions">
        <button
          className={clsx('header__btn', scanning && 'header__btn--spinning')}
          onClick={onRefresh}
          title="Refresh"
          disabled={scanning}
        >
          <RefreshCw size={14} />
        </button>
      </div>
    </header>
  );
}
