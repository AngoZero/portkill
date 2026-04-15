interface Props {
  count: number;
  lastScanTime: Date | null;
}

function fmt(date: Date): string {
  return date.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  });
}

export function Footer({ count, lastScanTime }: Props) {
  return (
    <footer className="footer">
      <span>{count} PORT{count !== 1 ? 'S' : ''} LISTENING</span>
      {lastScanTime && <span>LAST SCAN {fmt(lastScanTime)}</span>}
    </footer>
  );
}
