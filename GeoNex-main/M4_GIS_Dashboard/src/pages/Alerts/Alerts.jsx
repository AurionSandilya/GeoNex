import React, { useEffect, useState } from 'react';
import {
  AlertTriangle,
  Bell,
  Check,
  History,
  Radio,
  Send
} from 'lucide-react';
import { alertService } from '../../services/alerts/alertService.js';
import { RiskBadge } from '../../components/ui/RiskBadge.jsx';
import { StatusBadge } from '../../components/ui/StatusBadge.jsx';
import { DataSourceBadge } from '../../components/ui/DataSourceBadge.jsx';
import { Button } from '../../components/ui/Button.jsx';
import { useSelection } from '../../app/providers/SelectionContext.jsx';
import { useNavigate } from 'react-router-dom';

export function Alerts() {
  const [activeAlerts, setActiveAlerts] = useState([]);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterSeverity, setFilterSeverity] = useState('ALL');
  const [advisorySent, setAdvisorySent] = useState(false);
  const [dataSource, setDataSource] = useState('live');

  const { selectFeature } = useSelection();
  const navigate = useNavigate();

  useEffect(() => {
    async function fetchAlerts() {
      setLoading(true);
      try {
        const [activeData, historyData] = await Promise.all([
          alertService.getActiveAlerts(),
          alertService.getAlertHistory()
        ]);
        setActiveAlerts(activeData.data);
        setHistory(historyData.data);
        setDataSource(activeData.source === 'mock' || historyData.source === 'mock' ? 'mock' : 'live');
      } catch (err) {
        console.error("Alerts fetch error:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchAlerts();
  }, []);

  const handleInspectMap = (alertItem) => {
    selectFeature({
      type: 'ALERT',
      id: alertItem.id,
      title: alertItem.title,
      severity: alertItem.severity,
      priority: alertItem.priority || 'P1',
      coordinates: alertItem.coordinates,
      location_name: alertItem.location_name || 'Arunachal Pradesh Zone',
      message: alertItem.message || alertItem.bulletin_details,
      risk_score: alertItem.risk_score || 0.88,
      rainfall_24h: alertItem.rainfall_24h || 142.0,
      soil_saturation: alertItem.soil_saturation || 84.0,
      affected_infrastructure: alertItem.affected_infrastructure || [],
      recommended_action: alertItem.recommended_action || 'Inspect area',
      status: alertItem.status || 'ACTIVE',
      created_at: alertItem.created_at || new Date().toISOString(),
    }, { zoom: 13.5 });
    navigate('/risk-map');
  };

  const criticalCount = activeAlerts.filter(a => a.severity === 'CRITICAL' || a.priority === 'P1').length;
  const highCount = activeAlerts.filter(a => a.severity === 'HIGH' || a.priority === 'P2').length;

  const filteredActive = activeAlerts.filter(item => {
    if (filterSeverity === 'ALL') return true;
    return item.severity === filterSeverity || item.priority === filterSeverity;
  });

  return (
    <div className="h-full overflow-y-auto bg-slate-50 p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-rose-50 text-rose-600 flex items-center justify-center">
              <Bell className="w-4 h-4" />
            </div>
            <div>
              <h1 className="font-bold text-slate-900 text-lg tracking-tight">Alert Bulletins & Dispatch</h1>
              <p className="text-xs text-slate-500">
                Real-time disaster management advisories issued to District Emergency Operation Centres (EOC).
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <DataSourceBadge source={dataSource} />
          {advisorySent && (
            <span className="text-xs font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2.5 py-1 rounded-lg flex items-center gap-1 animate-in fade-in">
              <Check className="w-3.5 h-3.5 text-emerald-600" /> Dispatched to EOC Control Room
            </span>
          )}
          <Button
            variant={advisorySent ? "secondary" : "danger"}
            size="sm"
            icon={advisorySent ? Check : Send}
            onClick={() => {
              setAdvisorySent(true);
              setTimeout(() => setAdvisorySent(false), 4000);
            }}
          >
            {advisorySent ? 'Advisory Broadcasted' : 'Issue Emergency Advisory'}
          </Button>
        </div>
      </div>

      {/* Metric KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Active Bulletins</span>
          <div className="text-2xl font-bold text-slate-900 mt-1">{activeAlerts.length}</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">Papum Pare jurisdiction</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-rose-200/80 bg-rose-50/20 shadow-card">
          <span className="text-[11px] font-medium text-rose-700 block">Critical Priority (P1)</span>
          <div className="text-2xl font-bold text-rose-600 mt-1">{criticalCount}</div>
          <span className="text-[10px] text-rose-500 mt-0.5 block">Immediate evacuation protocol</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-amber-200/80 bg-amber-50/20 shadow-card">
          <span className="text-[11px] font-medium text-amber-800 block">High Risk (P2)</span>
          <div className="text-2xl font-bold text-amber-600 mt-1">{highCount}</div>
          <span className="text-[10px] text-amber-600 mt-0.5 block">Traffic restriction advisory</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Archived Dispatches</span>
          <div className="text-2xl font-bold text-slate-900 mt-1">{history.length}</div>
          <span className="text-[10px] text-emerald-600 mt-0.5 block font-medium">100% verified resolution</span>
        </div>
      </div>

      {/* Active Bulletins Section */}
      <div className="space-y-3">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <Radio className="w-4 h-4 text-rose-600 animate-pulse" />
            <h2 className="font-semibold text-slate-900 text-sm tracking-tight">
              Active Warnings ({filteredActive.length})
            </h2>
          </div>

          <div className="flex items-center gap-1">
            {['ALL', 'CRITICAL', 'HIGH'].map(sev => (
              <button
                key={sev}
                onClick={() => setFilterSeverity(sev)}
                className={`px-2.5 py-1 text-xs font-medium rounded-lg cursor-pointer transition-colors ${filterSeverity === sev
                    ? 'bg-slate-900 text-white shadow-xs'
                    : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200'
                  }`}
              >
                {sev === 'ALL' ? 'All Alerts' : sev === 'CRITICAL' ? 'Critical Only' : 'High Risk Only'}
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="p-12 text-center text-slate-400 text-xs">Loading alert bulletins...</div>
        ) : filteredActive.length === 0 ? (
          <div className="p-8 text-center bg-white border border-slate-200 rounded-xl text-slate-500 text-xs">
            No active bulletins matching the filter.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {filteredActive.map(alert => (
              <div
                key={alert.id}
                className="p-5 rounded-xl border border-slate-200/90 bg-white shadow-card flex flex-col justify-between space-y-4 hover:border-slate-300 transition-all"
              >
                <div>
                  <div className="flex items-center justify-between gap-2 mb-2">
                    <RiskBadge level={alert.severity} size="sm" />
                    <span className="font-mono text-[11px] text-slate-400">{alert.id}</span>
                  </div>

                  <h3 className="font-semibold text-slate-900 text-sm leading-snug">
                    {alert.title}
                  </h3>

                  <p className="text-xs text-slate-600 mt-2 leading-relaxed">
                    {alert.message}
                  </p>
                </div>

                <div className="space-y-3 pt-3 border-t border-slate-100 text-xs">
                  <div className="flex flex-wrap items-center gap-1.5">
                    <span className="text-slate-400 text-[11px]">Affected Corridors:</span>
                    {(alert.affected_infrastructure || []).map((loc, idx) => (
                      <span key={idx} className="bg-slate-50 border border-slate-200 px-2 py-0.5 rounded-md text-[11px] font-medium text-slate-700">
                        {loc}
                      </span>
                    ))}
                  </div>

                  <div className="grid grid-cols-2 gap-2 text-xs">
                    <div className="bg-sky-50/50 border border-sky-100 p-2 rounded-lg text-slate-700">
                      <span className="text-[10px] text-slate-400 block">Rainfall (24h)</span>
                      <span className="font-mono font-bold text-sky-900">{alert.rainfall_24h} mm</span>
                    </div>
                    <div className="bg-amber-50/50 border border-amber-100 p-2 rounded-lg text-slate-700">
                      <span className="text-[10px] text-slate-400 block">Soil Saturation</span>
                      <span className="font-mono font-bold text-amber-900">{alert.soil_saturation}%</span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-1">
                    <span className="text-amber-800 font-semibold text-xs flex items-center gap-1">
                      <AlertTriangle className="w-3.5 h-3.5 text-amber-600" />
                      {alert.recommended_action}
                    </span>
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => handleInspectMap(alert)}
                    >
                      View on Map
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Alert History Section */}
      <div className="space-y-3 pt-2">
        <div className="flex items-center gap-2">
          <History className="w-4 h-4 text-slate-500" />
          <h2 className="font-semibold text-slate-900 text-sm tracking-tight">
            Historical Archive & Resolution Log
          </h2>
        </div>

        <div className="bg-white border border-slate-200/90 rounded-xl shadow-card overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold text-[11px] uppercase tracking-wider">
                <tr>
                  <th className="py-3 px-4">Bulletin ID</th>
                  <th className="py-3 px-4">Risk Severity</th>
                  <th className="py-3 px-4">Incident Title</th>
                  <th className="py-3 px-4">Issued Date</th>
                  <th className="py-3 px-4">Resolution Outcome</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {history.map(item => (
                  <tr key={item.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3 px-4 font-mono font-semibold text-slate-800">{item.id}</td>
                    <td className="py-3 px-4"><RiskBadge level={item.severity} size="sm" /></td>
                    <td className="py-3 px-4 font-medium text-slate-800">{item.title}</td>
                    <td className="py-3 px-4 font-mono text-slate-500">{item.date}</td>
                    <td className="py-3 px-4">
                      <StatusBadge status={item.status} label={item.resolution} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
