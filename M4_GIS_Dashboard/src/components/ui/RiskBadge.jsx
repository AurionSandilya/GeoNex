import { AlertOctagon, AlertTriangle, CheckCircle2 } from 'lucide-react';

const RISK_CONFIG = {
  // NORMAL/WATCH/WARNING/CRITICAL are the vocabulary M3's AlertResponse and
  // M5's alert state machine actually emit (see the integration audit,
  // §3.9/5.8). LOW/MODERATE/HIGH are kept alongside them - unlike the
  // dedicated alerts-map layer, this component is also fed severity-like
  // strings from citizen-report and demo data that never went through M5
  // and don't use the alert vocabulary; replacing the table outright would
  // make those badges fall back to the LOW/green default instead of
  // showing their real color.
  LOW: {
    label: 'Low Risk',
    icon: CheckCircle2,
    badgeClass: 'bg-emerald-50 text-emerald-700 border-emerald-200/80',
    dotClass: 'bg-emerald-500',
  },
  NORMAL: {
    label: 'Normal',
    icon: CheckCircle2,
    badgeClass: 'bg-emerald-50 text-emerald-700 border-emerald-200/80',
    dotClass: 'bg-emerald-500',
  },
  MODERATE: {
    label: 'Moderate Risk',
    icon: AlertTriangle,
    badgeClass: 'bg-amber-50 text-amber-800 border-amber-200/80',
    dotClass: 'bg-amber-500',
  },
  WATCH: {
    label: 'Watch',
    icon: AlertTriangle,
    badgeClass: 'bg-amber-50 text-amber-800 border-amber-200/80',
    dotClass: 'bg-amber-500',
  },
  HIGH: {
    label: 'High Risk',
    icon: AlertTriangle,
    badgeClass: 'bg-orange-50 text-orange-800 border-orange-200/80',
    dotClass: 'bg-orange-500',
  },
  WARNING: {
    label: 'Warning',
    icon: AlertTriangle,
    badgeClass: 'bg-orange-50 text-orange-800 border-orange-200/80',
    dotClass: 'bg-orange-500',
  },
  CRITICAL: {
    label: 'Critical Risk',
    icon: AlertOctagon,
    badgeClass: 'bg-rose-50 text-rose-700 border-rose-200/80 font-semibold',
    dotClass: 'bg-rose-600 animate-pulse',
  }
};

export function RiskBadge({ level = 'LOW', score = null, showScore = false, size = 'md' }) {
  const normalizedLevel = (level || 'LOW').toUpperCase();
  const config = RISK_CONFIG[normalizedLevel] || RISK_CONFIG.LOW;

  const sizeClasses = size === 'xs'
    ? 'px-1.5 py-0.2 text-[10px] gap-1 rounded'
    : size === 'sm'
      ? 'px-2 py-0.5 text-xs gap-1.5 rounded-md'
      : size === 'lg'
        ? 'px-3 py-1.5 text-sm gap-2 rounded-lg'
        : 'px-2.5 py-1 text-xs gap-1.5 rounded-md';

  return (
    <span
      className={`inline-flex items-center border font-medium tracking-normal ${config.badgeClass} ${sizeClasses}`}
      aria-label={`Risk Level: ${config.label}${score !== null ? `, Score: ${score}` : ''}`}
    >
      <span className={`w-1.5 h-1.5 rounded-full ${config.dotClass}`} aria-hidden="true" />
      <span>{config.label}</span>
      {showScore && score !== null && (
        <span className="ml-1 opacity-75 border-l border-current/30 pl-1 font-mono text-[10px]">
          {(score * 100).toFixed(0)}%
        </span>
      )}
    </span>
  );
}
