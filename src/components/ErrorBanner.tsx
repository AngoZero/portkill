interface Props {
  message: string;
  onDismiss: () => void;
}

export function ErrorBanner({ message, onDismiss }: Props) {
  return (
    <div className="error-banner">
      <span className="error-banner__msg">{message}</span>
      <button className="error-banner__close" onClick={onDismiss}>
        ×
      </button>
    </div>
  );
}
