import React, { useState } from 'react';
import { ChevronDown, ChevronUp, MapPin, Building2, Route } from 'lucide-react';

export function MapLegend() {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <div className="bg-white/95 backdrop-blur-md border border-slate-200/90 rounded-xl shadow-panel text-xs w-52 overflow-hidden z-20 pointer-events-auto select-none">
      {/* Legend Title */}
      <div
        onClick={() => setCollapsed(!collapsed)}
        className="px-3 py-2 bg-slate-900 text-white font-semibold flex items-center justify-between cursor-pointer"
      >
        <span className="text-[11px] tracking-tight">Map Symbology</span>
        {collapsed ? <ChevronUp className="w-3.5 h-3.5 text-slate-400" /> : <ChevronDown className="w-3.5 h-3.5 text-slate-400" />}
      </div>

      {!collapsed && (
        <div className="p-3 space-y-3 divide-y divide-slate-100">
          {/* Risk Levels */}
          <div>
            <div className="text-[10px] font-semibold text-slate-400 uppercase tracking-wider mb-1.5">Risk Level</div>
            <div className="space-y-1 text-slate-700">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-rose-600 shrink-0"></span>
                <span className="font-medium text-slate-800">Critical Risk</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-orange-500 shrink-0"></span>
                <span className="text-slate-600">High Risk</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-amber-500 shrink-0"></span>
                <span className="text-slate-600">Moderate Risk</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 shrink-0"></span>
                <span className="text-slate-600">Low Risk</span>
              </div>
            </div>
          </div>

          {/* Feature Symbols */}
          <div className="pt-2">
            <div className="text-[10px] font-semibold text-slate-400 uppercase tracking-wider mb-1.5">Layers</div>
            <div className="space-y-1.5 text-slate-600">
              <div className="flex items-center gap-2">
                <span className="w-3.5 h-3.5 rounded bg-rose-600 text-white font-bold text-[9px] flex items-center justify-center">P1</span>
                <span>Active Warning (P1-P4)</span>
              </div>
              <div className="flex items-center gap-2">
                <MapPin className="w-3.5 h-3.5 text-sky-600" />
                <span>Field Report</span>
              </div>
              <div className="flex items-center gap-2">
                <Building2 className="w-3.5 h-3.5 text-purple-600" />
                <span>Critical Infrastructure</span>
              </div>
              <div className="flex items-center gap-2">
                <Route className="w-3.5 h-3.5 text-amber-600" />
                <span>Highway (NH-229)</span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
