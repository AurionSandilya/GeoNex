/**
 * Small visible indicator for whether the data currently shown came from a
 * live backend response or a demo/mock fallback. The audit (§5.10) flagged
 * that M4's mock-data fallback was completely invisible in the UI - a
 * viewer had no way to tell a real "all clear, zero active alerts" state
 * apart from "the backend is down and we're showing canned demo data".
 * This renders nothing when source is 'live' so normal operation stays
 * visually quiet.
 */
export function DataSourceBadge({ source, className = '' }) {
  if (source !== 'mock') return null;

  return (
    <span
      className={`inline-flex items-center gap-1 text-[10px] font-bold bg-amber-400 text-amber-950 px-2 py-0.5 rounded-full ${className}`}
      title="Backend unreachable - showing demo data, not live telemetry"
    >
      DEMO DATA
    </span>
  );
}
