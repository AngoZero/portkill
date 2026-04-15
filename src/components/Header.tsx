import { RefreshCw, X } from 'lucide-react';
import { getCurrentWindow } from '@tauri-apps/api/window';
import clsx from 'clsx';

interface Props {
  scanning: boolean;
  onRefresh: () => void;
}

export function Header({ scanning, onRefresh }: Props) {
  function handleClose() {
    getCurrentWindow().hide();
  }

  return (
    <header className="header" data-tauri-drag-region>
      <span className="header__title" data-tauri-drag-region>PORTKILL</span>
      <div className="header__actions">
        <button
          className={clsx('header__btn', scanning && 'header__btn--spinning')}
          onClick={onRefresh}
          title="Refresh"
          disabled={scanning}
        >
          <RefreshCw size={14} />
        </button>
        <button className="header__btn header__btn--close" onClick={handleClose} title="Hide">
          <X size={14} />
        </button>
      </div>
    </header>
  );
}
