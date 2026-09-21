import React, { useState } from 'react';
import { ZoomIn, ZoomOut, Maximize, RotateCcw, Layers, Map as MapIcon, Check, X } from 'lucide-react';
import { useLayers } from '../../app/providers/LayerContext.jsx';

export function MapControls({ onZoomIn, onZoomOut, onResetView }) {
  const { layers, toggleLayer, activeBasemap, setActiveBasemap } = useLayers();
  const [showLayerDrawer, setShowLayerDrawer] = useState(false);
  const [showBasemapDrawer, setShowBasemapDrawer] = useState(false);

  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(() => { });
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen().catch(() => { });
      }
    }
  };

  return (
    <div className="flex flex-col gap-2 z-20 pointer-events-auto items-end">
      {/* Basemap Switcher Drawer */}
      {showBasemapDrawer && (
        <div className="bg-white/95 backdrop-blur-md border border-slate-200 rounded-xl shadow-overlay p-3 w-60 text-xs mb-1 animate-in fade-in duration-150">
          <div className="font-semibold text-slate-800 border-b border-slate-100 pb-2 mb-2 flex items-center justify-between">
            <span className="flex items-center gap-1.5">
              <MapIcon className="w-3.5 h-3.5 text-sky-600" /> Basemap Style
            </span>
            <button
              onClick={() => setShowBasemapDrawer(false)}
              className="p-1 text-slate-400 hover:text-slate-600 rounded-md cursor-pointer"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>
          <div className="space-y-1">
            {[
              { id: 'osm-standard', label: 'OpenStreetMap Standard' },
              { id: 'osm-topo', label: 'OpenTopoMap Terrain' },
              { id: 'osm-satellite', label: 'Esri Satellite Imagery' },
              { id: 'osm-dark', label: 'Carto Dark Matter' },
              { id: 'osm-light', label: 'Carto Positron Light' },
            ].map((mapItem) => (
              <button
                key={mapItem.id}
                onClick={() => { setActiveBasemap(mapItem.id); setShowBasemapDrawer(false); }}
                className={`w-full text-left px-2.5 py-1.5 rounded-lg flex items-center justify-between border cursor-pointer transition-colors ${activeBasemap === mapItem.id
                    ? 'bg-sky-50 border-sky-200 font-semibold text-sky-800'
                    : 'border-transparent hover:bg-slate-50 text-slate-700'
                  }`}
              >
                <span>{mapItem.label}</span>
                {activeBasemap === mapItem.id && <Check className="w-3.5 h-3.5 text-sky-600" />}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Layer Visibility Drawer */}
      {showLayerDrawer && (
        <div className="bg-white/95 backdrop-blur-md border border-slate-200 rounded-xl shadow-overlay p-3 w-64 text-xs mb-1 animate-in fade-in duration-150">
          <div className="font-semibold text-slate-800 border-b border-slate-100 pb-2 mb-2 flex items-center justify-between">
            <span className="flex items-center gap-1.5">
              <Layers className="w-3.5 h-3.5 text-sky-600" /> GIS Active Layers
            </span>
            <button
              onClick={() => setShowLayerDrawer(false)}
              className="p-1 text-slate-400 hover:text-slate-600 rounded-md cursor-pointer"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>
          <div className="space-y-1">
            {[
              { key: 'riskZones', label: 'Landslide Risk Grid' },
              { key: 'activeWarnings', label: 'Active Bulletins (P1-P4)' },
              { key: 'fieldReports', label: 'Citizen Field Reports' },
              { key: 'roadNetwork', label: 'National Highway (NH-229)' },
              { key: 'infrastructure', label: 'Hospitals & Critical Infra' },
              { key: 'villages', label: 'Villages & Settlements' },
              { key: 'emergencyPriorities', label: 'Emergency Priority Zones' }
            ].map(layer => (
              <label
                key={layer.key}
                className="flex items-center justify-between p-1.5 hover:bg-slate-50 rounded-lg cursor-pointer text-slate-700 select-none"
              >
                <span className="font-medium">{layer.label}</span>
                <input
                  type="checkbox"
                  checked={layers[layer.key]}
                  onChange={() => toggleLayer(layer.key)}
                  className="rounded text-sky-600 focus:ring-sky-500 w-3.5 h-3.5 cursor-pointer"
                />
              </label>
            ))}
          </div>
        </div>
      )}

      {/* Floating Control Button Group */}
      <div className="bg-white/95 backdrop-blur-md border border-slate-200/90 rounded-xl shadow-panel divide-y divide-slate-100 flex flex-col overflow-hidden">
        <button
          onClick={onZoomIn}
          className="p-2 text-slate-600 hover:bg-slate-50 hover:text-sky-600 cursor-pointer transition-colors"
          title="Zoom In"
          aria-label="Zoom In"
        >
          <ZoomIn className="w-4 h-4" />
        </button>
        <button
          onClick={onZoomOut}
          className="p-2 text-slate-600 hover:bg-slate-50 hover:text-sky-600 cursor-pointer transition-colors"
          title="Zoom Out"
          aria-label="Zoom Out"
        >
          <ZoomOut className="w-4 h-4" />
        </button>
        <button
          onClick={onResetView}
          className="p-2 text-slate-600 hover:bg-slate-50 hover:text-sky-600 cursor-pointer transition-colors"
          title="Reset to Center"
          aria-label="Reset View"
        >
          <RotateCcw className="w-4 h-4" />
        </button>
        <button
          onClick={() => { setShowBasemapDrawer(!showBasemapDrawer); setShowLayerDrawer(false); }}
          className={`p-2 cursor-pointer transition-colors ${showBasemapDrawer ? 'bg-sky-50 text-sky-600' : 'text-slate-600 hover:bg-slate-50 hover:text-sky-600'
            }`}
          title="Change Basemap"
          aria-label="Switch Basemap"
        >
          <MapIcon className="w-4 h-4" />
        </button>
        <button
          onClick={() => { setShowLayerDrawer(!showLayerDrawer); setShowBasemapDrawer(false); }}
          className={`p-2 cursor-pointer transition-colors ${showLayerDrawer ? 'bg-sky-50 text-sky-600' : 'text-slate-600 hover:bg-slate-50 hover:text-sky-600'
            }`}
          title="Toggle Layers"
          aria-label="Toggle Layers"
        >
          <Layers className="w-4 h-4" />
        </button>
        <button
          onClick={toggleFullscreen}
          className="p-2 text-slate-600 hover:bg-slate-50 hover:text-sky-600 cursor-pointer transition-colors"
          title="Toggle Fullscreen"
          aria-label="Toggle Fullscreen"
        >
          <Maximize className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}
