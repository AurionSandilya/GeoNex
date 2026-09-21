import React, { useState } from 'react';
import { MapLibreViewer } from '../../components/map/MapLibreViewer.jsx';
import { useRegion } from '../../app/providers/RegionContext.jsx';
import { useSelection } from '../../app/providers/SelectionContext.jsx';
import { riskService } from '../../services/risk/riskService.js';
import { RiskBadge } from '../../components/ui/RiskBadge.jsx';
import { Search, Compass, Cpu } from 'lucide-react';

export function RiskMap() {
  const { selectedDistrict } = useRegion();
  const { selectFeature } = useSelection();
  const [searchQuery, setSearchQuery] = useState('');
  const [analyzing, setAnalyzing] = useState(false);

  const handleCoordinateSearch = async (e) => {
    if (e.key && e.key !== 'Enter') return;
    if (!searchQuery.trim()) return;

    // Parse lat/lon from query like "27.55, 93.65" or "27.55 93.65"
    const coordsMatch = searchQuery.match(/(-?\d+\.?\d*)[,\s]+(-?\d+\.?\d*)/);
    let lat = 27.55;
    let lon = 93.65;
    let locationName = searchQuery.trim();

    if (coordsMatch) {
      lat = parseFloat(coordsMatch[1]);
      lon = parseFloat(coordsMatch[2]);
      // If user typed lon first (e.g. 93.65, 27.55)
      if (lat > 60 && lon < 40) {
        const tmp = lat;
        lat = lon;
        lon = tmp;
      }
      locationName = `Coord [${lat.toFixed(3)}°N, ${lon.toFixed(3)}°E]`;
    }

    try {
      setAnalyzing(true);
      const prediction = await riskService.getRiskByLocation(lat, lon, 75.0, 30.0);
      selectFeature({
        type: 'AI_PREDICTION',
        id: `PRED-${Date.now()}`,
        title: `AI Risk Assessment — ${locationName}`,
        severity: prediction.risk_level === 'CRITICAL' ? 'CRITICAL' : (prediction.risk_level === 'HIGH' ? 'HIGH' : 'MODERATE'),
        priority: prediction.risk_level === 'CRITICAL' ? 'P1' : 'P2',
        coordinates: [lon, lat],
        location_name: locationName,
        risk_score: prediction.risk_score,
        confidence: prediction.confidence,
        rainfall_24h: 75.0,
        soil_saturation: 80.0,
        affected_infrastructure: ['High-Risk Hill Slope Zone'],
        recommended_action: `M1 AI Model (${prediction.model_version}): Score ${prediction.risk_score}. Monitor slope stability.`,
        status: 'AI_VERIFIED',
        created_at: prediction.timestamp || new Date().toISOString()
      }, { center: [lon, lat], zoom: 14 });
    } catch (err) {
      console.warn('[RiskMap] AI inference failed:', err);
    } finally {
      setAnalyzing(false);
    }
  };

  return (
    <div className="w-full h-full relative flex flex-col overflow-hidden bg-slate-100">
      {/* Top Operational Toolbar */}
      <div className="bg-white/95 backdrop-blur-md border-b border-slate-200/90 px-4 py-2 flex items-center justify-between z-10 shrink-0 text-xs shadow-2xs select-none">
        <div className="flex items-center gap-3">
          <div className="font-semibold text-slate-800 flex items-center gap-1.5 text-xs">
            <Compass className="w-4 h-4 text-sky-600" />
            <span>Hazard Analysis View — {selectedDistrict?.name || 'Sector'}</span>
          </div>
          <RiskBadge level="HIGH" score={0.78} size="xs" />
        </div>

        <div className="flex items-center gap-2">
          <div className="relative">
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-2.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={handleCoordinateSearch}
              placeholder="Enter lat, lon (e.g. 27.55, 93.65)..."
              className="pl-8 pr-3 py-1 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-800 outline-none focus:ring-1 focus:ring-sky-500 focus:bg-white w-52 sm:w-64 transition-all"
            />
          </div>
          <button
            onClick={handleCoordinateSearch}
            disabled={analyzing}
            className="flex items-center gap-1.5 px-2.5 py-1 bg-sky-600 hover:bg-sky-700 text-white rounded-lg cursor-pointer font-medium text-xs transition-colors disabled:opacity-50"
          >
            <Cpu className={`w-3.5 h-3.5 ${analyzing ? 'animate-spin' : ''}`} />
            <span>{analyzing ? 'Evaluating...' : 'Predict AI Risk'}</span>
          </button>
        </div>
      </div>

      {/* Main Map Container */}
      <div className="flex-1 relative overflow-hidden">
        <MapLibreViewer />
      </div>
    </div>
  );
}
