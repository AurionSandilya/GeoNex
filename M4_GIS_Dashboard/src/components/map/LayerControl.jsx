import React from 'react';
import {
  Activity,
  AlertTriangle,
  Building2,
  CheckCircle2,
  CloudRain,
  Droplets,
  Eye,
  EyeOff,
  FileText,
  GraduationCap,
  History,
  Home,
  Layers,
  Navigation,
  PlusSquare,
  Radio,
  ShieldAlert,
  X,
  Zap
} from 'lucide-react';
import { GIS_LAYER_CATEGORIES } from '../../app/config/layers.js';
import { useLayer } from '../../app/providers/LayerContext.jsx';

const LAYER_ICON_MAP = {
  Activity,
  ShieldAlert,
  CloudRain,
  Droplets,
  Radio,
  History,
  UserAlert: AlertTriangle,
  CheckCircle2,
  Navigation,
  Home,
  GraduationCap,
  Cross: PlusSquare,
  Zap,
  Building2,
  FileText
};

export function LayerControl({ isOpen, onClose }) {
  const { layers, toggleLayerVisibility, setLayerOpacity, setCategoryVisibility } = useLayer();

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-y-0 right-0 z-40 w-88 bg-white border-l border-slate-200 shadow-overlay flex flex-col transition-all duration-200 animate-in slide-in-from-right-full"
      aria-label="GIS Layer Visibility and Controls Drawer"
    >
      {/* Header */}
      <div className="p-3.5 bg-slate-900 text-white flex items-center justify-between shadow-xs">
        <div className="flex items-center gap-2 font-semibold text-xs tracking-tight">
          <Layers className="w-4 h-4 text-sky-400" aria-hidden="true" />
          <span>GIS Layer Manager</span>
        </div>
        <button
          onClick={onClose}
          className="p-1 text-slate-400 hover:text-white rounded-md hover:bg-slate-800 cursor-pointer transition-colors"
          aria-label="Close Layer Control Drawer"
        >
          <X className="w-4 h-4" />
        </button>
      </div>

      {/* Categorized Layers Container */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 text-xs bg-slate-50/70">
        {GIS_LAYER_CATEGORIES.map(cat => {
          const CatIcon = LAYER_ICON_MAP[cat.icon] || Layers;
          const catLayers = layers.filter(l => l.category === cat.id);
          const activeCount = catLayers.filter(l => l.visible).length;
          const allActive = activeCount === catLayers.length;

          return (
            <div key={cat.id} className="bg-white border border-slate-200/90 rounded-xl p-3.5 shadow-card space-y-3">
              {/* Category Header with Master Toggle */}
              <div className="flex items-center justify-between pb-2 border-b border-slate-100 font-semibold text-slate-900 text-xs">
                <div className="flex items-center gap-1.5 text-slate-800">
                  <CatIcon className="w-3.5 h-3.5 text-sky-600" aria-hidden="true" />
                  <span>{cat.name}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[10px] text-slate-400 font-mono">
                    {activeCount}/{catLayers.length}
                  </span>
                  <button
                    onClick={() => setCategoryVisibility(cat.id, !allActive)}
                    className="text-[10px] px-2 py-0.5 rounded-md font-medium border border-slate-200 hover:bg-slate-50 text-slate-600 cursor-pointer transition-colors"
                    title={allActive ? "Hide Category" : "Show Category"}
                  >
                    {allActive ? "Hide All" : "Show All"}
                  </button>
                </div>
              </div>

              {/* Layer Cards */}
              <div className="space-y-2">
                {catLayers.map(layer => {
                  const LayerIcon = LAYER_ICON_MAP[layer.icon] || Layers;

                  return (
                    <div
                      key={layer.id}
                      className={`p-2.5 rounded-lg border transition-all ${layer.visible
                          ? 'bg-sky-50/40 border-sky-200 text-slate-900'
                          : 'bg-slate-50 border-slate-100 text-slate-500 opacity-75'
                        }`}
                    >
                      <div className="flex items-center justify-between gap-2">
                        <label className="flex items-center gap-2 font-medium text-xs cursor-pointer select-none flex-1">
                          <input
                            type="checkbox"
                            checked={layer.visible}
                            onChange={() => toggleLayerVisibility(layer.id)}
                            className="rounded text-sky-600 focus:ring-sky-500 w-3.5 h-3.5 cursor-pointer"
                          />
                          <LayerIcon className={`w-3.5 h-3.5 shrink-0 ${layer.visible ? 'text-sky-600' : 'text-slate-400'}`} />
                          <span className={layer.visible ? 'font-semibold text-slate-900' : 'text-slate-600'}>
                            {layer.name}
                          </span>
                        </label>

                        <button
                          onClick={() => toggleLayerVisibility(layer.id)}
                          className={`p-1 rounded-md cursor-pointer transition-colors ${layer.visible ? 'text-sky-600 hover:bg-sky-100' : 'text-slate-400 hover:bg-slate-200'
                            }`}
                          title={layer.visible ? "Hide Layer" : "Show Layer"}
                        >
                          {layer.visible ? <Eye className="w-3.5 h-3.5" /> : <EyeOff className="w-3.5 h-3.5" />}
                        </button>
                      </div>

                      <p className="text-[11px] text-slate-400 leading-tight mt-1 pl-5">
                        {layer.description}
                      </p>

                      {/* Opacity Control for Active Layers */}
                      {layer.visible && (
                        <div className="flex items-center gap-2 pt-2 mt-1.5 border-t border-slate-200/60 pl-5">
                          <span className="text-[10px] text-slate-400 font-mono w-12">Opacity:</span>
                          <input
                            type="range"
                            min="0.1"
                            max="1.0"
                            step="0.05"
                            value={layer.opacity}
                            onChange={(e) => setLayerOpacity(layer.id, parseFloat(e.target.value))}
                            className="flex-1 h-1 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-sky-600"
                            aria-label={`Adjust Opacity for ${layer.name}`}
                          />
                          <span className="text-[10px] font-mono text-slate-700 w-8 text-right font-semibold">
                            {Math.round(layer.opacity * 100)}%
                          </span>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
