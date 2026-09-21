import React from 'react';

export function StatusBadge({ status = 'OPERATIONAL', label = null }) {
  const norm = (status || '').toUpperCase();

  let styles = 'bg-slate-50 text-slate-700 border-slate-200';
  let dotStyle = 'bg-slate-400';

  if (norm === 'OPERATIONAL' || norm === 'VERIFIED' || norm === 'RESOLVED' || norm === 'ACTIVE') {
    styles = 'bg-emerald-50 text-emerald-700 border-emerald-200/80';
    dotStyle = 'bg-emerald-500';
  } else if (norm === 'DEGRADED' || norm === 'PENDING_VERIFICATION' || norm === 'UNVERIFIED' || norm === 'ACTION_REQUIRED' || norm === 'ACKNOWLEDGED') {
    styles = 'bg-amber-50 text-amber-800 border-amber-200/80';
    dotStyle = 'bg-amber-500';
  } else if (norm === 'OFFLINE' || norm === 'CRITICAL' || norm === 'REJECTED') {
    styles = 'bg-rose-50 text-rose-700 border-rose-200/80';
    dotStyle = 'bg-rose-500';
  }

  return (
    <span className={`inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md border text-xs font-medium ${styles}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${dotStyle}`} aria-hidden="true" />
      <span>{label || norm.replace(/_/g, ' ')}</span>
    </span>
  );
}
