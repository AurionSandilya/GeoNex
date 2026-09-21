import React, { useState } from 'react';
import {
  X,
  ShieldCheck,
  MapPin,
  Activity,
  Droplets,
  Building2,
  CheckCircle2,
  AlertTriangle,
  Cpu,
  Copy,
  Check,
  Navigation,
  Camera,
  Video,
  Play,
  FileText
} from 'lucide-react';
import { useSelection } from '../../app/providers/SelectionContext.jsx';
import { alertService } from '../../services/alerts/alertService.js';
import { riskService } from '../../services/risk/riskService.js';
import { RiskBadge } from '../ui/RiskBadge.jsx';
import { Button } from '../ui/Button.jsx';
import { ReportMediaModal } from '../reports/ReportMediaModal.jsx';

export function LocationDetailsPanel() {
  const { selectedFeature, clearSelection } = useSelection();
  const [ackLoading, setAckLoading] = useState(false);
  const [acknowledged, setAcknowledged] = useState(false);
  const [remarks, setRemarks] = useState('');
  const [mlLoading, setMlLoading] = useState(false);
  const [livePrediction, setLivePrediction] = useState(null);
  const [copiedCoords, setCopiedCoords] = useState(false);
  const [mediaModalOpen, setMediaModalOpen] = useState(false);

  if (!selectedFeature) return null;

  const lat = selectedFeature.coordinates ? selectedFeature.coordinates[1] : selectedFeature.latitude;
  const lon = selectedFeature.coordinates ? selectedFeature.coordinates[0] : selectedFeature.longitude;

  const handleCopyCoords = () => {
    if (lat === undefined || lon === undefined) return;
    navigator.clipboard.writeText(`${lat.toFixed(5)}, ${lon.toFixed(5)}`);
    setCopiedCoords(true);
    setTimeout(() => setCopiedCoords(false), 2000);
  };

  const handleRunAiPrediction = async () => {
    if (lat === undefined || lon === undefined) return;
    try {
      setMlLoading(true);
      const res = await riskService.getRiskByLocation(
        lat,
        lon,
        selectedFeature.rainfall_24h || 65.0,
        selectedFeature.slope_deg || 30.0
      );
      setLivePrediction(res);
    } catch (err) {
      console.warn('[LocationDetailsPanel] Live risk prediction error:', err);
    } finally {
      setMlLoading(false);
    }
  };

  const handleAcknowledge = async () => {
    try {
      setAckLoading(true);
      await alertService.acknowledgeAlert(selectedFeature.id || 'LOC-POINT', remarks || 'Acknowledged by DDMO officer');
      setAcknowledged(true);
    } catch (err) {
      console.error('[LocationDetailsPanel] Acknowledge error:', err);
    } finally {
      setAckLoading(false);
    }
  };

  const mediaList = Array.isArray(selectedFeature.media) ? selectedFeature.media : [];
  const photoCount = selectedFeature.photo_count ?? mediaList.filter(m => m.type === 'photo').length;
  const videoCount = selectedFeature.video_count ?? mediaList.filter(m => m.type === 'video').length;
  const hasMedia = mediaList.length > 0 || photoCount > 0 || videoCount > 0;

  return (
    <>
      <aside className="w-88 max-w-[calc(100vw-32px)] bg-white/95 backdrop-blur-md border border-slate-200/90 rounded-xl shadow-overlay flex flex-col max-h-[calc(100vh-140px)] z-30 pointer-events-auto overflow-hidden transition-all animate-in fade-in slide-in-from-right-4 duration-200">
        {/* Header */}
        <div className="px-4 py-3 bg-slate-900 text-white flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2">
            <Activity className="w-4 h-4 text-sky-400" />
            <h2 className="font-semibold text-xs tracking-tight">Location & Warning Details</h2>
          </div>
          <button
            onClick={clearSelection}
            className="p-1 text-slate-400 hover:text-white hover:bg-slate-800 rounded-md cursor-pointer transition-colors"
            aria-label="Close detail panel"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content Container */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {/* Title & Priority Badge */}
          <div>
            <div className="flex items-center gap-2 mb-1.5 flex-wrap">
              <RiskBadge level={livePrediction?.risk_level || selectedFeature.severity || 'HIGH'} size="sm" />
              <span className="text-[11px] bg-slate-100 text-slate-700 px-2 py-0.5 rounded-md border border-slate-200 font-medium">
                {acknowledged ? 'Acknowledged' : (selectedFeature.status || 'Active')}
              </span>
              {selectedFeature.type === 'TAPPED_LOCATION' && (
                <span className="text-[10px] bg-sky-50 text-sky-700 px-2 py-0.5 rounded-md border border-sky-200 font-medium">
                  Map Tap Assessment
                </span>
              )}
              {(selectedFeature.type === 'CITIZEN_REPORT' || selectedFeature.type === 'VERIFIED_REPORT') && (
                <span className="text-[10px] bg-purple-50 text-purple-700 px-2 py-0.5 rounded-md border border-purple-200 font-medium">
                  Field Incident Report
                </span>
              )}
            </div>

            <h3 className="font-semibold text-sm text-slate-900 leading-snug">
              {selectedFeature.title || 'Selected Risk Feature'}
            </h3>

            <div className="flex items-center gap-1.5 text-xs text-slate-600 mt-1">
              <MapPin className="w-3.5 h-3.5 text-slate-400 shrink-0" />
              <span className="font-medium">{selectedFeature.location_name || 'Papum Pare District'}</span>
            </div>

            {/* Exact Coordinates Strip with 1-click Copy */}
            {lat !== undefined && lon !== undefined && (
              <div className="mt-2.5 bg-slate-50 border border-slate-200/90 rounded-lg p-2 flex items-center justify-between gap-2">
                <div className="flex items-center gap-1.5 text-[11px] font-mono text-slate-700">
                  <Navigation className="w-3 h-3 text-sky-600 shrink-0" />
                  <span className="font-semibold">{lat.toFixed(5)}°N, {lon.toFixed(5)}°E</span>
                </div>
                <button
                  onClick={handleCopyCoords}
                  className="px-2 py-0.5 bg-white hover:bg-slate-100 border border-slate-200 text-slate-700 text-[10px] font-medium rounded transition-colors flex items-center gap-1 cursor-pointer"
                  title="Copy exact coordinates to clipboard"
                >
                  {copiedCoords ? (
                    <>
                      <Check className="w-3 h-3 text-emerald-600" />
                      <span className="text-emerald-700 font-semibold">Copied!</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3 h-3 text-slate-400" />
                      <span>Copy</span>
                    </>
                  )}
                </button>
              </div>
            )}
          </div>

          {/* Citizen & Field Media Evidence Strip (if available) */}
          {hasMedia && (
            <div className="bg-sky-50/70 border border-sky-200/90 rounded-xl p-3 space-y-2.5">
              <div className="flex items-center justify-between">
                <h4 className="text-xs font-semibold text-sky-950 flex items-center gap-1.5">
                  <Camera className="w-3.5 h-3.5 text-sky-600" />
                  Field & Citizen Media ({mediaList.length})
                </h4>
                <div className="flex items-center gap-1 text-[10px] font-medium text-sky-700">
                  {photoCount > 0 && <span>{photoCount}P</span>}
                  {photoCount > 0 && videoCount > 0 && <span>•</span>}
                  {videoCount > 0 && <span>{videoCount}V</span>}
                </div>
              </div>

              {/* Thumbnails preview */}
              {mediaList.length > 0 && (
                <div className="grid grid-cols-3 gap-1.5">
                  {mediaList.slice(0, 3).map((item, idx) => (
                    <div
                      key={item.id || idx}
                      onClick={() => setMediaModalOpen(true)}
                      className="relative aspect-4/3 rounded-lg overflow-hidden border border-sky-200/80 cursor-pointer group bg-slate-900 shadow-xs"
                      title={item.title}
                    >
                      <img
                        src={item.thumbnail || item.url}
                        alt={item.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                      />
                      {item.type === 'video' ? (
                        <div className="absolute inset-0 bg-black/35 flex items-center justify-center">
                          <div className="w-5 h-5 rounded-full bg-sky-600/90 text-white flex items-center justify-center">
                            <Play className="w-2.5 h-2.5 fill-white ml-0.5" />
                          </div>
                        </div>
                      ) : (
                        <div className="absolute top-1 right-1 w-4 h-4 rounded bg-black/50 text-white flex items-center justify-center">
                          <Camera className="w-2.5 h-2.5" />
                        </div>
                      )}
                      <span className="absolute bottom-1 left-1 text-[8px] font-bold px-1 rounded bg-black/70 text-white">
                        {item.source === 'FIELD_VERIFICATION' ? 'FIELD' : 'CITIZEN'}
                      </span>
                    </div>
                  ))}
                </div>
              )}

              <Button
                variant="secondary"
                size="xs"
                icon={Play}
                onClick={() => setMediaModalOpen(true)}
                className="w-full text-sky-800 border-sky-300 hover:bg-sky-100"
              >
                View Full Photos & Videos ({mediaList.length})
              </Button>
            </div>
          )}

          {/* Risk Score & Model Confidence Grid */}
          <div className="space-y-2">
            <div className="grid grid-cols-2 gap-2 bg-slate-50/80 border border-slate-200/80 p-3 rounded-lg">
              <div>
                <div className="text-[10px] text-slate-500 font-semibold uppercase tracking-wider">Risk Score</div>
                <div className="text-lg font-bold text-slate-900 flex items-baseline gap-1 mt-0.5">
                  {livePrediction 
                    ? `${((livePrediction.risk_score || 0) * 100).toFixed(0)}%`
                    : `${((selectedFeature.risk_score || 0.88) * 100).toFixed(0)}%`
                  }
                  <span className="text-xs font-medium text-rose-600">
                    {livePrediction?.risk_level || selectedFeature.severity || 'High'}
                  </span>
                </div>
              </div>
              <div>
                <div className="text-[10px] text-slate-500 font-semibold uppercase tracking-wider">ML Model</div>
                <div className="text-lg font-bold text-slate-900 mt-0.5">
                  {livePrediction 
                    ? `${((livePrediction.confidence || 0.9) * 100).toFixed(0)}%`
                    : `${((selectedFeature.confidence || 0.92) * 100).toFixed(0)}%`
                  }
                  <span className="text-[10px] text-sky-700 font-mono block">
                    {livePrediction?.model_version || selectedFeature.model_version || 'v1.4.2-XGBoost'}
                  </span>
                </div>
              </div>
            </div>

            {lat !== undefined && lon !== undefined && (
              <button
                onClick={handleRunAiPrediction}
                disabled={mlLoading}
                className="w-full py-1.5 px-2.5 rounded-lg bg-sky-50 hover:bg-sky-100 border border-sky-200 text-sky-800 text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors cursor-pointer disabled:opacity-50"
              >
                <Cpu className={`w-3.5 h-3.5 ${mlLoading ? 'animate-spin' : 'text-sky-600'}`} />
                <span>{mlLoading ? 'Computing ML Prediction...' : 'Re-run M1 AI Prediction for Location'}</span>
              </button>
            )}
          </div>

          {/* Environmental Triggers & Sensor Telemetry */}
          <div>
            <h4 className="text-xs font-semibold text-slate-700 mb-2 flex items-center gap-1.5">
              <Droplets className="w-3.5 h-3.5 text-sky-500" />
              Sensor Telemetry & Triggers
            </h4>
            <div className="grid grid-cols-2 gap-2 text-xs">
              <div className="bg-sky-50/60 border border-sky-100 p-2.5 rounded-lg">
                <span className="text-[10px] text-sky-700 font-medium block">24h Rainfall</span>
                <span className="text-sm font-bold text-sky-950 font-mono">{selectedFeature.rainfall_24h || 142.0} mm</span>
              </div>
              <div className="bg-amber-50/60 border border-amber-100 p-2.5 rounded-lg">
                <span className="text-[10px] text-amber-700 font-medium block">Soil Saturation</span>
                <span className="text-sm font-bold text-amber-950 font-mono">{selectedFeature.soil_saturation || 84.0}%</span>
              </div>
              <div className="bg-slate-50 border border-slate-200/80 p-2.5 rounded-lg">
                <span className="text-[10px] text-slate-500 font-medium block">Terrain Slope</span>
                <span className="text-sm font-bold text-slate-800 font-mono">{selectedFeature.slope_deg || 32.5}°</span>
              </div>
              <div className="bg-slate-50 border border-slate-200/80 p-2.5 rounded-lg">
                <span className="text-[10px] text-slate-500 font-medium block">SAR Shift Rate</span>
                <span className="text-sm font-bold text-slate-800 font-mono">{selectedFeature.sar_displacement_mm_yr ? `${selectedFeature.sar_displacement_mm_yr} mm/yr` : '-14.2 mm/yr'}</span>
              </div>
            </div>
          </div>

          {/* Affected Infrastructure */}
          <div>
            <h4 className="text-xs font-semibold text-slate-700 mb-1.5 flex items-center gap-1.5">
              <Building2 className="w-3.5 h-3.5 text-slate-400" />
              Affected Infrastructure & Corridors
            </h4>
            <ul className="text-xs space-y-1 text-slate-600 bg-slate-50 border border-slate-200/80 p-2.5 rounded-lg">
              {(selectedFeature.affected_infrastructure || ['Trans-Arunachal Highway (NH-229)', 'Sagalee PHC Hospital']).map((item, idx) => (
                <li key={idx} className="flex items-center gap-1.5">
                  <span className="w-1.5 h-1.5 bg-rose-500 rounded-full"></span>
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Recommended Action */}
          <div className="bg-amber-50/70 border border-amber-200/80 p-3 rounded-lg">
            <div className="flex items-center gap-1.5 text-amber-900 font-semibold text-xs">
              <AlertTriangle className="w-3.5 h-3.5 text-amber-600" />
              Recommended Operational Action
            </div>
            <p className="text-xs text-amber-800 mt-1 leading-relaxed">
              {selectedFeature.recommended_action || 'Deploy PWD earthmovers and restrict heavy vehicle movement along NH-229.'}
            </p>
          </div>

          {/* Officer Action Form */}
          <div className="border-t border-slate-100 pt-3">
            <h4 className="text-xs font-semibold text-slate-800 mb-2">Officer Verification & Acknowledgement</h4>

            {acknowledged ? (
              <div className="bg-emerald-50 border border-emerald-200 p-3 rounded-lg text-center">
                <CheckCircle2 className="w-5 h-5 text-emerald-600 mx-auto mb-1" />
                <p className="text-xs font-semibold text-emerald-900">Warning Acknowledged</p>
                <p className="text-[10px] text-emerald-700 mt-0.5">Recorded in DDMO Yupia Control Room audit log.</p>
              </div>
            ) : (
              <div className="space-y-2">
                <input
                  type="text"
                  value={remarks}
                  onChange={(e) => setRemarks(e.target.value)}
                  placeholder="Enter officer dispatch notes..."
                  className="w-full text-xs px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-sky-500 focus:bg-white transition-all"
                />
                <Button
                  variant="dark"
                  size="sm"
                  onClick={handleAcknowledge}
                  disabled={ackLoading}
                  className="w-full"
                  icon={ShieldCheck}
                >
                  {ackLoading ? 'Recording...' : 'Acknowledge Bulletin'}
                </Button>
              </div>
            )}
          </div>
        </div>
      </aside>

      {/* Media Modal popup from Map View */}
      {mediaModalOpen && (
        <ReportMediaModal
          report={selectedFeature}
          isOpen={mediaModalOpen}
          onClose={() => setMediaModalOpen(false)}
        />
      )}
    </>
  );
}
