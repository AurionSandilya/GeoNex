import React from 'react';
import { AlertOctagon, CloudRain, Cpu, Users } from 'lucide-react';
import { useRegion } from '../../app/providers/RegionContext.jsx';
import { RiskBadge } from '../ui/RiskBadge.jsx';

export function MapStatusStrip() {
  const { selectedDistrict } = useRegion();

  return (
    <footer 
      className="h-8 bg-slate-900 text-slate-300 px-3 sm:px-4 flex items-center justify-between z-30 shrink-0 text-[11px] shadow-sm border-t border-slate-800 select-none"
      aria-label="Operational Status Bar"
    >
      <div className="flex items-center gap-3 sm:gap-4 overflow-x-auto no-scrollbar">
        <div className="flex items-center gap-2">
          <span className="text-slate-400 font-medium">Focus:</span>
          <span className="text-amber-400 font-semibold">{selectedDistrict?.name || 'All Sectors'}</span>
          <RiskBadge level="HIGH" score={0.78} size="xs" />
        </div>

        <div className="hidden sm:flex items-center gap-1.5 text-slate-300 border-l border-slate-800 pl-3">
          <AlertOctagon className="w-3 h-3 text-rose-400 shrink-0" aria-hidden="true" />
          <span>Critical: <strong className="text-white font-mono">2</strong></span>
          <span className="text-slate-600">|</span>
          <span>High: <strong className="text-white font-mono">2</strong></span>
        </div>

        <div className="hidden md:flex items-center gap-1.5 text-slate-300 border-l border-slate-800 pl-3">
          <CloudRain className="w-3 h-3 text-sky-400 shrink-0" aria-hidden="true" />
          <span>Peak 24h Rain: <strong className="text-sky-300 font-mono">162.0 mm</strong></span>
        </div>

        <div className="hidden lg:flex items-center gap-1.5 text-slate-300 border-l border-slate-800 pl-3">
          <Users className="w-3 h-3 text-slate-400 shrink-0" aria-hidden="true" />
          <span>Exposed: <strong className="text-white font-mono">54,800</strong></span>
        </div>
      </div>

      <div className="flex items-center gap-3 text-slate-400 shrink-0 pl-2">
        <div className="hidden xl:flex items-center gap-1 font-mono text-[10px]">
          <Cpu className="w-3 h-3 text-emerald-400 shrink-0" aria-hidden="true" />
          <span>XGBoost v1.4 (87% Conf)</span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" aria-hidden="true" />
          <span className="text-slate-300 font-mono text-[10px]">GIS SYNC</span>
        </div>
      </div>
    </footer>
  );
}
