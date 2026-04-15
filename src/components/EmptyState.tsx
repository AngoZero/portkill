interface Props {
  onRefresh: () => void;
}

export function EmptyState({ onRefresh }: Props) {
  return (
    <div className="empty">
      <p className="empty__msg">NO PORTS LISTENING</p>
      <button className="btn-outline" onClick={onRefresh}>
        REFRESH
      </button>
    </div>
  );
}
