import React, { useEffect, useState, useCallback } from 'react';
import { AlertTriangle, Clock, MapPin, CheckCircle2, ChevronRight, Filter, ChevronUp, ChevronDown, RefreshCw, Flame, Users } from 'lucide-react';
import { alertService } from '../../services/alerts/alertService.js';
import { emergencyService } from '../../services/emergency/emergencyService.js';
import { useSelection } from '../../app/providers/SelectionContext.jsx';
import { DataSourceBadge } from '../ui/DataSourceBadge.jsx';

function formatRelativeTime(dateStr) {
  if (!dateStr) return 'Just now';
  const diffMs = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diffMs / (1000 * 60));
  if (mins < 1) return 'Just now';
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

export function WarningPriorityQueue() {
  const [activeTab, setActiveTab] = useState('PRIORITIES'); // 'PRIORITIES' | 'WARNINGS'
  const [alerts, setAlerts] = useState([]);
  const [priorities, setPriorities] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [filterSeverity, setFilterSeverity] = useState('ALL');
  const [isMinimized, setIsMinimized] = useState(false);
  const [dataSource, setDataSource] = useState('live');

  const { selectedFeature, selectFeature } = useSelection();

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const [alertsData, prioritiesData] = await Promise.allSettled([
        alertService.getActiveAlerts(),
        emergencyService.getEmergencyPriorities(),
      ]);

      let anyMock = false;

      if (alertsData.status === 'fulfilled') {
        const alertList = alertsData.value?.data || [];
        if (alertsData.value?.source === 'mock') anyMock = true;
        const priorityOrder = { P1: 1, P2: 2, P3: 3, P4: 4, CRITICAL: 1, HIGH: 2, MODERATE: 3, LOW: 4 };
        const sorted = [...alertList].sort((a, b) => {
          const pA = priorityOrder[a.priority || a.severity] || 99;
          const pB = priorityOrder[b.priority || b.severity] || 99;
          return pA - pB;
        });
        setAlerts(sorted);
      }

      if (prioritiesData.status === 'fulfilled' && Array.isArray(prioritiesData.value?.data)) {
        if (prioritiesData.value?.source === 'mock') anyMock = true;
        setPriorities(prioritiesData.value.data);
      }

      setDataSource(anyMock ? 'mock' : 'live');
      setError(null);
    } catch (err) {
      console.error('[WarningPriorityQueue] Error fetching data:', err);
      setError('Unable to load queue data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleSelectPriority = (item) => {
    selectFeature({
      type: 'EMERGENCY_PRIORITY',
      id: `EMG-${item.priority}-${item.location_name.replace(/[^a-zA-Z0-9]/g, '_')}`,
      title: `${item.priority} Priority — ${item.location_name}`,
      severity: item.priority === 'P1' ? 'CRITICAL' : item.priority === 'P2' ? 'HIGH' : 'MODERATE',
      priority: item.priority,
      coordinates: item.coordinates,
      location_name: item.location_name,
      risk_score: item.risk_score || 0.85,
      confidence: 0.94,
      priority_score: item.priority_score,
      affected_infrastructure: item.factors?.critical_assets || [item.factors?.road_blockage_impact || 'Corridor'],
      population_exposed: item.factors?.population_exposed || 0,
      recommended_action: item.recommendation || 'Deploy emergency squad.',
      status: 'ACTIVE_RANKING',
      created_at: new Date().toISOString(),
    }, { zoom: 13.5 });
  };

  const handleSelectWarning = (alertItem) => {
    selectFeature({
      type: 'ALERT',
      id: alertItem.id,
      title: alertItem.title,
      severity: alertItem.severity,
      priority: alertItem.priority || 'P1',
      coordinates: alertItem.coordinates || [93.42, 27.24],
      location_name: alertItem.location_name || 'Papum Pare Zone',
      message: alertItem.message || alertItem.bulletin_details,
      risk_score: alertItem.risk_score || 0.88,
      rainfall_24h: alertItem.rainfall_24h || 142.0,
      soil_saturation: alertItem.soil_saturation || 84.0,
      affected_infrastructure: alertItem.affected_infrastructure || [],
      recommended_action: alertItem.recommended_action || 'Inspect area',
      status: alertItem.status || 'ACTIVE',
      created_at: alertItem.created_at || new Date().toISOString(),
    }, { zoom: 13 });
  };

  const getPriorityStyle = (severity, priority) => {
    if (severity === 'CRITICAL' || priority === 'P1') {
      return {
        badge: 'bg-rose-50 text-rose-700 border-rose-200 font-semibold',
        border: 'border-l-rose-500',
        bg: 'hover:bg-rose-50/40',
        label: 'P1 Critical',
      };
    }
    if (severity === 'HIGH' || priority === 'P2') {
      return {
        badge: 'bg-orange-50 text-orange-700 border-orange-200 font-semibold',
        border: 'border-l-orange-500',
        bg: 'hover:bg-orange-50/40',
        label: 'P2 High',
      };
    }
    if (severity === 'MODERATE' || priority === 'P3') {
      return {
        badge: 'bg-amber-50 text-amber-700 border-amber-200 font-medium',
        border: 'border-l-amber-500',
        bg: 'hover:bg-amber-50/40',
        label: 'P3 Moderate',
      };
    }
    return {
      badge: 'bg-emerald-50 text-emerald-700 border-emerald-200 font-medium',
      border: 'border-l-emerald-500',
      bg: 'hover:bg-emerald-50/40',
      label: 'P4 Low',
    };
  };

  // Minimized Floating Pill Render
  if (isMinimized) {
    const totalCount = activeTab === 'PRIORITIES' ? priorities.length : alerts.length;
    return (
      <aside
        onClick={() => setIsMinimized(false)}
        className="w-72 max-w-[calc(100vw-32px)] bg-slate-900/95 backdrop-blur-md text-white border border-slate-800 rounded-xl shadow-panel px-3.5 py-2.5 flex items-center justify-between z-20 pointer-events-auto cursor-pointer hover:bg-slate-900 transition-all"
        title="Click to expand Warning Queue"
      >
        <div className="flex items-center gap-2 text-xs">
          <AlertTriangle className="w-4 h-4 text-amber-400 shrink-0" />
          <span className="font-semibold tracking-tight">Priority Queue</span>
          <span className="text-[10px] font-bold bg-rose-600 text-white px-2 py-0.5 rounded-full">
            {totalCount} Active
          </span>
        </div>
        <div className="flex items-center gap-1 text-slate-400 hover:text-white">
          <span className="text-[11px]">Expand</span>
          <ChevronUp className="w-3.5 h-3.5" />
        </div>
      </aside>
    );
  }

  const filteredAlerts = alerts.filter(item => {
    if (filterSeverity === 'ALL') return true;
    return item.severity === filterSeverity || item.priority === filterSeverity;
  });

  const filteredPriorities = priorities.filter(item => {
    if (filterSeverity === 'ALL') return true;
    if (filterSeverity === 'CRITICAL') return item.priority === 'P1';
    if (filterSeverity === 'HIGH') return item.priority === 'P2';
    return true;
  });

  return (
    <aside className="w-84 max-w-[calc(100vw-32px)] bg-white/95 backdrop-blur-md border border-slate-200/90 rounded-xl shadow-panel flex flex-col max-h-96 z-20 pointer-events-auto overflow-hidden transition-all duration-200">
      {/* Header */}
      <div className="px-3.5 py-2.5 bg-slate-900 text-white flex items-center justify-between shrink-0">
        <div className="flex items-center gap-2">
          <AlertTriangle className="w-4 h-4 text-amber-400 shrink-0" />
          <h2 className="font-semibold text-xs tracking-tight">Warning & Decision Queue</h2>
        </div>
        <div className="flex items-center gap-1.5">
          <DataSourceBadge source={dataSource} />
          <span className="text-[10px] font-bold bg-white/15 text-slate-200 px-2 py-0.5 rounded-full">
            {activeTab === 'PRIORITIES' ? `${priorities.length} P-Ranked` : `${alerts.length} Warnings`}
          </span>
          <button
            onClick={fetchData}
            disabled={loading}
            className="p-1 hover:bg-white/15 rounded-md text-slate-300 hover:text-white cursor-pointer transition-colors"
            title="Refresh Queue"
            aria-label="Refresh Queue"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
          </button>
          <button
            onClick={() => setIsMinimized(true)}
            className="p-1 hover:bg-white/15 rounded-md text-slate-300 hover:text-white cursor-pointer transition-colors"
            title="Minimize Queue"
            aria-label="Minimize Queue"
          >
            <ChevronDown className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* Subsystem Tab Navigation: Decision Support vs Early Warnings */}
      <div className="flex border-b border-slate-200 bg-slate-100/75 p-1 text-[11px] font-semibold shrink-0">
        <button
          onClick={() => setActiveTab('PRIORITIES')}
          className={`flex-1 py-1 rounded-md transition-colors cursor-pointer flex items-center justify-center gap-1.5 ${
            activeTab === 'PRIORITIES'
              ? 'bg-white text-slate-900 shadow-xs'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Flame className="w-3 h-3 text-rose-500" />
          <span>Decision Priorities (P1-P3)</span>
        </button>
        <button
          onClick={() => setActiveTab('WARNINGS')}
          className={`flex-1 py-1 rounded-md transition-colors cursor-pointer flex items-center justify-center gap-1.5 ${
            activeTab === 'WARNINGS'
              ? 'bg-white text-slate-900 shadow-xs'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <AlertTriangle className="w-3 h-3 text-amber-500" />
          <span>Warnings ({alerts.length})</span>
        </button>
      </div>

      {/* Filter Tabs */}
      <div className="px-3 py-1.5 bg-slate-50/80 border-b border-slate-100 flex items-center justify-between text-xs shrink-0">
        <span className="text-slate-500 text-[10px] font-medium flex items-center gap-1">
          <Filter className="w-3 h-3 text-slate-400" /> Filter:
        </span>
        <div className="flex items-center gap-1">
          {['ALL', 'CRITICAL', 'HIGH'].map(sev => (
            <button
              key={sev}
              onClick={() => setFilterSeverity(sev)}
              className={`px-2 py-0.5 text-[10px] font-semibold rounded-md cursor-pointer transition-colors ${filterSeverity === sev
                  ? 'bg-slate-800 text-white shadow-xs'
                  : 'bg-slate-200/70 text-slate-600 hover:bg-slate-200'
                }`}
            >
              {sev === 'ALL' ? 'All' : sev === 'CRITICAL' ? 'Critical (P1)' : 'High (P2)'}
            </button>
          ))}
        </div>
      </div>

      {/* Cards List */}
      <div className="flex-1 overflow-y-auto divide-y divide-slate-100">
        {loading && (
          <div className="p-4 text-center text-xs text-slate-500 flex items-center justify-center gap-2">
            <div className="w-3.5 h-3.5 border-2 border-sky-600 border-t-transparent rounded-full animate-spin"></div>
            <span>Loading queue data...</span>
          </div>
        )}

        {!loading && error && (
          <div className="p-3 text-center text-xs text-rose-600 bg-rose-50">
            {error}
          </div>
        )}

        {/* Tab 1: Emergency Decision Support Priorities (Backend M3) */}
        {!loading && !error && activeTab === 'PRIORITIES' && (
          filteredPriorities.length === 0 ? (
            <div className="p-5 text-center text-xs text-slate-500">
              <CheckCircle2 className="w-6 h-6 text-emerald-500 mx-auto mb-1.5 opacity-90" />
              <p className="font-semibold text-slate-700">No Emergency Priorities</p>
              <p className="text-[11px] text-slate-400 mt-0.5">Threshold below risk criteria.</p>
            </div>
          ) : (
            filteredPriorities.map((item, idx) => {
              const isSelected = selectedFeature?.location_name === item.location_name;
              const isP1 = item.priority === 'P1';

              return (
                <div
                  key={`prio-${idx}`}
                  onClick={() => handleSelectPriority(item)}
                  className={`p-3 cursor-pointer transition-all border-l-4 ${
                    isP1 ? 'border-l-rose-500 hover:bg-rose-50/40' : 'border-l-amber-500 hover:bg-amber-50/40'
                  } ${isSelected ? 'bg-sky-50/80 ring-1 ring-sky-500/50' : 'bg-white'}`}
                >
                  <div className="flex items-center justify-between gap-1.5">
                    <span className={`px-1.5 py-0.5 text-[10px] rounded font-bold border ${
                      isP1 ? 'bg-rose-50 text-rose-700 border-rose-200' : 'bg-amber-50 text-amber-700 border-amber-200'
                    }`}>
                      {item.priority} Decision Rank
                    </span>
                    <span className="text-[10px] font-mono text-slate-500 font-semibold">
                      Score: {item.priority_score}
                    </span>
                  </div>

                  <h3 className="font-semibold text-xs text-slate-800 mt-1.5 leading-snug">
                    {item.location_name}
                  </h3>

                  <div className="flex flex-wrap items-center gap-2 mt-2 text-[10px] text-slate-500">
                    <span className="flex items-center gap-1 font-medium text-slate-700 bg-slate-100 px-1.5 py-0.5 rounded">
                      <Users className="w-3 h-3 text-slate-500" />
                      {item.factors?.population_exposed?.toLocaleString() || 0} exposed
                    </span>
                    <span className="text-amber-800 font-medium">
                      Risk: {((item.risk_score || 0) * 100).toFixed(0)}%
                    </span>
                  </div>

                  <p className="text-[11px] text-slate-600 mt-1.5 line-clamp-2 italic">
                    "{item.recommendation}"
                  </p>

                  <div className="flex items-center justify-between text-[10px] text-slate-400 mt-2">
                    <span className="truncate max-w-[170px] text-slate-500 font-medium">
                      {item.factors?.critical_assets?.join(', ') || item.factors?.road_blockage_impact}
                    </span>
                    <span className="text-sky-600 font-medium flex items-center gap-0.5">
                      View Map <ChevronRight className="w-3 h-3" />
                    </span>
                  </div>
                </div>
              );
            })
          )
        )}

        {/* Tab 2: Active Early Warning Bulletins */}
        {!loading && !error && activeTab === 'WARNINGS' && (
          filteredAlerts.length === 0 ? (
            <div className="p-5 text-center text-xs text-slate-500">
              <CheckCircle2 className="w-6 h-6 text-emerald-500 mx-auto mb-1.5 opacity-90" />
              <p className="font-semibold text-slate-700">No Active Warnings</p>
              <p className="text-[11px] text-slate-400 mt-0.5">All monitored sectors normal.</p>
            </div>
          ) : (
            filteredAlerts.map(alert => {
              const isSelected = selectedFeature?.id === alert.id;
              const style = getPriorityStyle(alert.severity, alert.priority);

              return (
                <div
                  key={alert.id}
                  onClick={() => handleSelectWarning(alert)}
                  className={`p-3 cursor-pointer transition-all border-l-4 ${style.border} ${isSelected
                      ? 'bg-sky-50/80 ring-1 ring-sky-500/50'
                      : `bg-white ${style.bg}`
                    }`}
                >
                  <div className="flex items-center justify-between gap-1.5">
                    <span className={`px-1.5 py-0.5 text-[10px] rounded border ${style.badge}`}>
                      {style.label}
                    </span>
                    <span className="text-[10px] text-slate-400 flex items-center gap-1 font-mono">
                      <Clock className="w-2.5 h-2.5" /> {formatRelativeTime(alert.created_at)}
                    </span>
                  </div>

                  <h3 className="font-semibold text-xs text-slate-800 mt-1.5 leading-snug line-clamp-2">
                    {alert.title}
                  </h3>

                  <div className="flex items-center justify-between text-[11px] text-slate-500 mt-2">
                    <span className="flex items-center gap-1 font-medium text-slate-600 truncate max-w-[160px]">
                      <MapPin className="w-3 h-3 text-slate-400 shrink-0" />
                      {alert.location_name || 'Papum Pare'}
                    </span>
                    <span className="text-sky-600 font-medium flex items-center text-[10px] gap-0.5">
                      Inspect <ChevronRight className="w-3 h-3" />
                    </span>
                  </div>
                </div>
              );
            })
          )
        )}
      </div>

      {/* Footer Info */}
      <div className="px-3 py-1.5 bg-slate-50/80 border-t border-slate-100 text-[10px] text-slate-400 text-center shrink-0">
        Click an item to focus map location
      </div>
    </aside>
  );
}
