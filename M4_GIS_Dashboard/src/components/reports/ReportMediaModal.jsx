import React, { useState, useEffect } from 'react';
import {
  X,
  Camera,
  Video,
  Play,
  MapPin,
  Calendar,
  User,
  ShieldCheck,
  ShieldAlert,
  Navigation,
  Copy,
  Check,
  ExternalLink,
  Layers,
  FileCheck,
  Maximize2,
  Tv,
  CheckCircle2,
  Clock,
  Smartphone,
  Compass,
  AlertTriangle
} from 'lucide-react';
import { RiskBadge } from '../ui/RiskBadge.jsx';
import { StatusBadge } from '../ui/StatusBadge.jsx';
import { Button } from '../ui/Button.jsx';
import { useSelection } from '../../app/providers/SelectionContext.jsx';
import { useNavigate } from 'react-router-dom';

export function ReportMediaModal({ report, isOpen, onClose, onVerify }) {
  const [activeMediaIndex, setActiveMediaIndex] = useState(0);
  const [mediaFilter, setMediaFilter] = useState('ALL'); // 'ALL' | 'PHOTOS' | 'VIDEOS' | 'CITIZEN' | 'FIELD'
  const [showHudOverlay, setShowHudOverlay] = useState(true);
  const [copiedCoords, setCopiedCoords] = useState(false);
  const [officerNotes, setOfficerNotes] = useState('');
  const [verifying, setVerifying] = useState(false);

  const { selectFeature } = useSelection();
  const navigate = useNavigate();

  // Reset active media when modal opens or report changes
  useEffect(() => {
    setActiveMediaIndex(0);
    setMediaFilter('ALL');
    setOfficerNotes('');
  }, [report?.id, isOpen]);

  // Handle ESC key to close
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen || !report) return null;

  const mediaList = Array.isArray(report.media) ? report.media : [];

  const filteredMedia = mediaList.filter((item) => {
    if (mediaFilter === 'PHOTOS') return item.type === 'photo';
    if (mediaFilter === 'VIDEOS') return item.type === 'video';
    if (mediaFilter === 'CITIZEN') return item.source === 'CITIZEN_UPLOAD';
    if (mediaFilter === 'FIELD') return item.source === 'FIELD_VERIFICATION';
    return true;
  });

  const activeItem = filteredMedia[activeMediaIndex] || filteredMedia[0] || mediaList[0];

  const lat = report.coordinates ? report.coordinates[1] : report.latitude;
  const lon = report.coordinates ? report.coordinates[0] : report.longitude;

  const handleCopyCoords = () => {
    if (lat === undefined || lon === undefined) return;
    navigator.clipboard.writeText(`${lat.toFixed(5)}, ${lon.toFixed(5)}`);
    setCopiedCoords(true);
    setTimeout(() => setCopiedCoords(false), 2000);
  };

  const handleInspectOnMap = () => {
    selectFeature(
      {
        type: report.verification_status === 'VERIFIED' ? 'VERIFIED_REPORT' : 'CITIZEN_REPORT',
        id: report.id,
        title: report.description || report.location_name,
        location_name: report.location_name,
        severity: report.severity,
        status: report.verification_status,
        coordinates: report.coordinates,
        created_at: report.reported_at || report.created_at,
        risk_score: report.severity === 'CRITICAL' ? 0.9 : report.severity === 'HIGH' ? 0.75 : 0.4,
        media: report.media,
        photo_count: report.photo_count,
        video_count: report.video_count,
        reporter_name: report.reporter_name,
        reporter_type: report.reporter_type,
        verified_by: report.verified_by,
        verification_notes: report.verification_notes
      },
      { zoom: 14 }
    );
    onClose();
    navigate('/risk-map');
  };

  const handleVerifyInModal = async () => {
    if (!onVerify) return;
    try {
      setVerifying(true);
      await onVerify(report.id, officerNotes || 'Verified through photographic and video evidence');
    } catch (err) {
      console.error('Failed to verify report in modal:', err);
    } finally {
      setVerifying(false);
    }
  };

  const isVerified = report.verification_status === 'VERIFIED';
  const photoCount = report.photo_count ?? mediaList.filter(m => m.type === 'photo').length;
  const videoCount = report.video_count ?? mediaList.filter(m => m.type === 'video').length;

  return (
    <div
      className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-3 sm:p-5 overflow-y-auto animate-in fade-in duration-200"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="report-modal-title"
    >
      <div
        className="bg-slate-900 border border-slate-700/80 rounded-2xl shadow-2xl w-full max-w-6xl max-h-[92vh] flex flex-col overflow-hidden text-slate-100 animate-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header Bar */}
        <div className="px-5 py-3.5 bg-slate-900/90 border-b border-slate-800 flex items-center justify-between gap-3 shrink-0">
          <div className="flex items-center gap-2.5 flex-wrap">
            <span className="font-mono font-bold text-xs bg-slate-800 text-sky-400 px-2.5 py-1 rounded-md border border-slate-700">
              {report.id}
            </span>
            <RiskBadge level={report.severity || 'HIGH'} size="sm" />
            <StatusBadge status={report.verification_status} />
            <span
              className={`text-[11px] font-medium px-2 py-0.5 rounded-md flex items-center gap-1 ${
                report.reporter_type === 'FIELD_OFFICER'
                  ? 'bg-amber-950/80 text-amber-300 border border-amber-700/60'
                  : 'bg-sky-950/80 text-sky-300 border border-sky-700/60'
              }`}
            >
              {report.reporter_type === 'FIELD_OFFICER' ? (
                <>
                  <ShieldCheck className="w-3 h-3" />
                  Field Verification Report
                </>
              ) : (
                <>
                  <Smartphone className="w-3 h-3" />
                  Citizen Mobile Report
                </>
              )}
            </span>
          </div>

          <div className="flex items-center gap-2">
            <Button variant="secondary" size="xs" icon={Navigation} onClick={handleInspectOnMap}>
              Inspect on GIS Map
            </Button>
            <button
              onClick={onClose}
              className="p-1.5 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-colors cursor-pointer"
              title="Close modal (Esc)"
              aria-label="Close modal"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Modal Body: Split Layout (Media Stage on Left, Report Dossier on Right) */}
        <div className="flex-1 overflow-y-auto grid grid-cols-1 lg:grid-cols-12 min-h-0 divide-y lg:divide-y-0 lg:divide-x divide-slate-800">
          {/* Left / Center: Interactive Media Viewer Stage (7 cols on lg) */}
          <div className="lg:col-span-7 p-4 sm:p-5 flex flex-col bg-slate-950/70 space-y-4">
            {/* Filter Tabs */}
            <div className="flex items-center justify-between gap-2 flex-wrap text-xs">
              <div className="flex items-center gap-1.5 bg-slate-900 p-1 rounded-xl border border-slate-800">
                <button
                  onClick={() => { setMediaFilter('ALL'); setActiveMediaIndex(0); }}
                  className={`px-2.5 py-1 rounded-lg font-medium transition-all cursor-pointer ${
                    mediaFilter === 'ALL'
                      ? 'bg-sky-600 text-white shadow-xs'
                      : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
                  }`}
                >
                  All Evidence ({mediaList.length})
                </button>
                {photoCount > 0 && (
                  <button
                    onClick={() => { setMediaFilter('PHOTOS'); setActiveMediaIndex(0); }}
                    className={`px-2.5 py-1 rounded-lg font-medium transition-all flex items-center gap-1 cursor-pointer ${
                      mediaFilter === 'PHOTOS'
                        ? 'bg-sky-600 text-white shadow-xs'
                        : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
                    }`}
                  >
                    <Camera className="w-3 h-3" />
                    Photos ({photoCount})
                  </button>
                )}
                {videoCount > 0 && (
                  <button
                    onClick={() => { setMediaFilter('VIDEOS'); setActiveMediaIndex(0); }}
                    className={`px-2.5 py-1 rounded-lg font-medium transition-all flex items-center gap-1 cursor-pointer ${
                      mediaFilter === 'VIDEOS'
                        ? 'bg-sky-600 text-white shadow-xs'
                        : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
                    }`}
                  >
                    <Video className="w-3 h-3" />
                    Videos ({videoCount})
                  </button>
                )}
              </div>

              {activeItem?.type === 'video' && (
                <button
                  onClick={() => setShowHudOverlay(!showHudOverlay)}
                  className={`px-2.5 py-1 rounded-lg border text-[11px] font-medium flex items-center gap-1 transition-colors cursor-pointer ${
                    showHudOverlay
                      ? 'bg-sky-950/80 border-sky-600 text-sky-300'
                      : 'bg-slate-900 border-slate-800 text-slate-400 hover:text-slate-200'
                  }`}
                >
                  <Tv className="w-3 h-3" />
                  <span>{showHudOverlay ? 'Telemetry HUD On' : 'Telemetry HUD Off'}</span>
                </button>
              )}
            </div>

            {/* Active Display Stage */}
            <div className="relative aspect-video sm:aspect-16/10 bg-slate-900 rounded-xl overflow-hidden border border-slate-800 flex items-center justify-center group shadow-inner">
              {activeItem ? (
                activeItem.type === 'video' ? (
                  <div className="relative w-full h-full bg-black flex items-center justify-center">
                    <video
                      key={activeItem.url}
                      src={activeItem.url}
                      controls
                      autoPlay={false}
                      className="w-full h-full object-contain"
                      poster={activeItem.thumbnail}
                    >
                      Your browser does not support HTML5 video streaming.
                    </video>

                    {/* Inspection HUD Telemetry Overlay */}
                    {showHudOverlay && (
                      <div className="pointer-events-none absolute inset-x-0 top-0 p-3 bg-linear-to-b from-black/80 via-black/30 to-transparent flex items-start justify-between text-[11px] font-mono text-emerald-400">
                        <div className="space-y-0.5">
                          <div className="flex items-center gap-1.5 font-bold tracking-wider text-white">
                            <span className="w-2 h-2 rounded-full bg-rose-500 animate-pulse"></span>
                            <span>{activeItem.source === 'FIELD_VERIFICATION' ? 'BRO/DDMO UAV DRONE STREAM' : 'CITIZEN MOBILE VIDEO'}</span>
                          </div>
                          <div className="text-[10px] text-emerald-300 opacity-90">
                            {lat !== undefined && lon !== undefined ? `${lat.toFixed(5)}°N • ${lon.toFixed(5)}°E` : 'GPS LOCKED'}
                          </div>
                          <div className="text-[10px] text-slate-300">
                            RES: {activeItem.resolution || '1080p'} • DUR: {activeItem.duration || '0:30'}
                          </div>
                        </div>

                        <div className="text-right space-y-0.5">
                          <div className="text-sky-300 font-semibold text-[10px]">
                            {activeItem.device || 'Surveillance Payload'}
                          </div>
                          <div className="text-[10px] text-slate-400">
                            {new Date(activeItem.captured_at || report.reported_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                ) : (
                  <div className="relative w-full h-full flex items-center justify-center bg-black/40">
                    <img
                      src={activeItem.url}
                      alt={activeItem.title || 'Field Report Evidence'}
                      className="w-full h-full object-contain transition-transform duration-300"
                    />

                    {/* Geotag Watermark Overlay on Photo */}
                    <div className="absolute inset-x-0 bottom-0 p-3 bg-linear-to-t from-black/90 via-black/50 to-transparent flex items-end justify-between text-xs text-white">
                      <div>
                        <div className="font-semibold text-sm drop-shadow-xs">{activeItem.title}</div>
                        <div className="text-[11px] text-slate-300 flex items-center gap-2 mt-0.5">
                          <span className="flex items-center gap-1 text-sky-300">
                            <MapPin className="w-3 h-3" />
                            {lat !== undefined && lon !== undefined ? `${lat.toFixed(4)}°N, ${lon.toFixed(4)}°E` : report.location_name}
                          </span>
                          <span>•</span>
                          <span className="flex items-center gap-1 text-slate-400">
                            <Clock className="w-3 h-3" />
                            {new Date(activeItem.captured_at || report.reported_at).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })}
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center gap-1.5">
                        <a
                          href={activeItem.url}
                          target="_blank"
                          rel="noreferrer"
                          className="p-1.5 rounded-lg bg-black/60 hover:bg-black/90 text-white/90 hover:text-white border border-white/20 transition-colors"
                          title="Open full resolution in new tab"
                        >
                          <ExternalLink className="w-3.5 h-3.5" />
                        </a>
                      </div>
                    </div>
                  </div>
                )
              ) : (
                <div className="p-8 text-center text-slate-500 space-y-2">
                  <Camera className="w-8 h-8 mx-auto text-slate-600" />
                  <p className="text-xs font-medium">No media uploaded for this report</p>
                </div>
              )}
            </div>

            {/* Active Media Caption & Technical Specs */}
            {activeItem && (
              <div className="bg-slate-900 border border-slate-800 p-3 rounded-xl text-xs space-y-1.5">
                <div className="flex items-center justify-between gap-2">
                  <span className="font-medium text-slate-200">{activeItem.caption || activeItem.title}</span>
                  <span
                    className={`text-[10px] font-semibold px-2 py-0.5 rounded uppercase tracking-wider shrink-0 ${
                      activeItem.source === 'FIELD_VERIFICATION'
                        ? 'bg-amber-950/70 text-amber-300 border border-amber-800/60'
                        : 'bg-sky-950/70 text-sky-300 border border-sky-800/60'
                    }`}
                  >
                    {activeItem.source === 'FIELD_VERIFICATION' ? 'Official Field Verification' : 'Citizen Mobile Upload'}
                  </span>
                </div>
                <div className="flex flex-wrap items-center gap-3 text-[11px] text-slate-400 font-mono">
                  {activeItem.device && <span>Device: {activeItem.device}</span>}
                  {activeItem.resolution && <span>Res: {activeItem.resolution}</span>}
                  {activeItem.file_size && <span>Size: {activeItem.file_size}</span>}
                  {activeItem.source_label && <span>Source: {activeItem.source_label}</span>}
                </div>
              </div>
            )}

            {/* Thumbnail Carousel / Filmstrip */}
            {filteredMedia.length > 1 && (
              <div>
                <div className="text-[11px] font-semibold text-slate-400 mb-1.5 uppercase tracking-wider">
                  Available Media Assets ({filteredMedia.length})
                </div>
                <div className="flex items-center gap-2 overflow-x-auto pb-1">
                  {filteredMedia.map((item, idx) => {
                    const isSelected = (activeItem?.id && item.id === activeItem.id) || (!activeItem?.id && idx === activeMediaIndex);
                    return (
                      <button
                        key={item.id || idx}
                        onClick={() => setActiveMediaIndex(idx)}
                        className={`relative shrink-0 w-24 h-16 rounded-lg overflow-hidden border transition-all cursor-pointer ${
                          isSelected
                            ? 'border-sky-500 ring-2 ring-sky-500/40 shadow-md scale-102'
                            : 'border-slate-800 opacity-70 hover:opacity-100 hover:border-slate-600'
                        }`}
                      >
                        <img
                          src={item.thumbnail || item.url}
                          alt={item.title}
                          className="w-full h-full object-cover"
                        />
                        <div className="absolute inset-0 bg-black/20 flex items-center justify-center">
                          {item.type === 'video' ? (
                            <div className="w-6 h-6 rounded-full bg-sky-600/90 text-white flex items-center justify-center shadow-xs">
                              <Play className="w-3 h-3 fill-white ml-0.5" />
                            </div>
                          ) : (
                            <div className="w-5 h-5 rounded bg-black/50 text-white flex items-center justify-center">
                              <Camera className="w-3 h-3 text-white" />
                            </div>
                          )}
                        </div>
                        {item.duration && (
                          <span className="absolute bottom-1 right-1 bg-black/80 text-white font-mono text-[9px] px-1 rounded">
                            {item.duration}
                          </span>
                        )}
                        <span
                          className={`absolute top-1 left-1 text-[8px] font-bold px-1 rounded ${
                            item.source === 'FIELD_VERIFICATION' ? 'bg-amber-600 text-white' : 'bg-sky-600 text-white'
                          }`}
                        >
                          {item.source === 'FIELD_VERIFICATION' ? 'FIELD' : 'USER'}
                        </span>
                      </button>
                    );
                  })}
                </div>
              </div>
            )}
          </div>

          {/* Right Column: Individual Report Dossier & Verification Details (5 cols on lg) */}
          <div className="lg:col-span-5 p-4 sm:p-5 flex flex-col space-y-4 bg-slate-900/60 overflow-y-auto">
            {/* Title & Description */}
            <div>
              <h2 id="report-modal-title" className="font-bold text-base text-slate-100 leading-snug">
                {report.location_name}
              </h2>
              <p className="text-xs text-slate-300 mt-1.5 leading-relaxed bg-slate-800/60 p-2.5 rounded-lg border border-slate-700/60">
                {report.description || 'Ground observation report'}
              </p>
            </div>

            {/* Location & GPS Info */}
            <div className="bg-slate-800/70 border border-slate-700/70 rounded-xl p-3 space-y-2 text-xs">
              <div className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-1.5 text-slate-300 font-medium">
                  <MapPin className="w-3.5 h-3.5 text-sky-400 shrink-0" />
                  <span>{report.location_name} ({report.district || 'Papum Pare'})</span>
                </div>
              </div>

              {lat !== undefined && lon !== undefined && (
                <div className="bg-slate-900/80 border border-slate-700/60 rounded-lg p-2 flex items-center justify-between">
                  <div className="flex items-center gap-1.5 font-mono text-[11px] text-sky-300">
                    <Compass className="w-3.5 h-3.5 text-sky-400 shrink-0" />
                    <span>{lat.toFixed(5)}°N, {lon.toFixed(5)}°E</span>
                  </div>
                  <button
                    onClick={handleCopyCoords}
                    className="px-2 py-0.5 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 text-[10px] flex items-center gap-1 border border-slate-600 transition-colors cursor-pointer"
                  >
                    {copiedCoords ? (
                      <>
                        <Check className="w-3 h-3 text-emerald-400" />
                        <span className="text-emerald-400 font-semibold">Copied</span>
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

              <div className="flex items-center justify-between text-[11px] text-slate-400 pt-1">
                <span className="flex items-center gap-1">
                  <Calendar className="w-3 h-3 text-slate-500" />
                  {report.reported_at ? new Date(report.reported_at).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' }) : 'Recent'}
                </span>
                <span className="flex items-center gap-1 text-slate-300">
                  <User className="w-3 h-3 text-slate-400" />
                  <span>{report.reporter_name || 'Citizen Contributor'}</span>
                </span>
              </div>
            </div>

            {/* Verification Status & Field Checklist */}
            <div className="border border-slate-800 rounded-xl p-3 bg-slate-950/50 space-y-2.5">
              <div className="flex items-center justify-between">
                <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider flex items-center gap-1.5">
                  <FileCheck className="w-3.5 h-3.5 text-sky-400" />
                  Field Verification Status
                </span>
                <span
                  className={`text-[10px] font-bold px-2 py-0.5 rounded uppercase ${
                    isVerified
                      ? 'bg-emerald-950 text-emerald-300 border border-emerald-700/60'
                      : 'bg-amber-950 text-amber-300 border border-amber-700/60'
                  }`}
                >
                  {report.verification_status}
                </span>
              </div>

              {isVerified ? (
                <div className="space-y-2 text-xs">
                  <div className="bg-emerald-950/40 border border-emerald-800/60 rounded-lg p-2.5 text-emerald-200 space-y-1">
                    <div className="font-semibold flex items-center gap-1.5 text-emerald-300">
                      <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
                      <span>Verified by: {report.verified_by || 'DDMO & Ground Cell'}</span>
                    </div>
                    {report.verified_at && (
                      <div className="text-[10px] text-emerald-400/80 font-mono">
                        Verification Timestamp: {new Date(report.verified_at).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })}
                      </div>
                    )}
                    {report.verification_notes && (
                      <p className="text-[11px] text-emerald-100/90 mt-1 italic">
                        "{report.verification_notes}"
                      </p>
                    )}
                  </div>
                </div>
              ) : (
                <div className="space-y-2 text-xs">
                  <div className="bg-amber-950/40 border border-amber-800/60 rounded-lg p-2.5 text-amber-200">
                    <div className="font-medium flex items-center gap-1.5">
                      <AlertTriangle className="w-3.5 h-3.5 text-amber-400 shrink-0" />
                      <span>Awaiting DDMO Officer On-Site Confirmation</span>
                    </div>
                    <p className="text-[11px] text-amber-300/80 mt-1">
                      Crowdsourced report requires verification against satellite radar displacement and field unit check before official emergency dispatch.
                    </p>
                  </div>
                </div>
              )}

              {/* Checklist items if available */}
              {report.checklist && report.checklist.length > 0 && (
                <div className="space-y-1.5 pt-1">
                  <span className="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">
                    Ground Inspection Checklist
                  </span>
                  <div className="space-y-1 text-xs">
                    {report.checklist.map((item, idx) => (
                      <div key={idx} className="flex items-center justify-between bg-slate-900/80 px-2 py-1.5 rounded border border-slate-800 text-[11px]">
                        <span className="text-slate-300">{item.label}</span>
                        <span className="font-mono font-semibold text-sky-400">{item.status}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Officer In-Modal Verification Form */}
            {!isVerified && onVerify && (
              <div className="bg-slate-800/80 border border-slate-700/80 rounded-xl p-3 space-y-2 text-xs">
                <span className="font-semibold text-slate-200 block text-xs">
                  Duty Officer Action — Verify Report
                </span>
                <input
                  type="text"
                  value={officerNotes}
                  onChange={(e) => setOfficerNotes(e.target.value)}
                  placeholder="Enter officer ground verification remarks..."
                  className="w-full text-xs px-3 py-2 bg-slate-900 border border-slate-700 rounded-lg text-slate-100 placeholder-slate-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
                />
                <Button
                  variant="primary"
                  size="sm"
                  icon={ShieldCheck}
                  disabled={verifying}
                  onClick={handleVerifyInModal}
                  className="w-full"
                >
                  {verifying ? 'Verifying & Geocoding...' : 'Verify Report & Geocode on Map'}
                </Button>
              </div>
            )}

            {/* Bottom Actions */}
            <div className="pt-2 flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                icon={Navigation}
                onClick={handleInspectOnMap}
                className="flex-1"
              >
                Inspect on GIS Map
              </Button>
              <Button
                variant="secondary"
                size="sm"
                onClick={onClose}
              >
                Close
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
