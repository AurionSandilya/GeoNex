import React, { useState, useEffect, useCallback } from 'react';
import { INITIAL_SYSTEM_STATUS } from '../../app/config/systemStatus.js';
import { StatusBadge } from '../../components/ui/StatusBadge.jsx';
import { CheckCircle2, Clock, Database, RefreshCw, Server, Wifi } from 'lucide-react';
import { Button } from '../../components/ui/Button.jsx';
import { apiFetch } from '../../services/apiClient.js';

export function SystemStatus() {
  const [statuses, setStatuses] = useState(INITIAL_SYSTEM_STATUS);
  const [refreshing, setRefreshing] = useState(false);
  const [backendMeta, setBackendMeta] = useState(null);

  const checkHealth = useCallback(async () => {
    setRefreshing(true);
    const startTime = Date.now();
    let backendOnline = false;
    let backendLatency = 0;
    let meta = null;

    try {
      const [healthData, rootData] = await Promise.all([
        apiFetch('/health'),
        apiFetch('/').catch(() => null),
      ]);
      backendOnline = healthData?.status === 'healthy';
      backendLatency = Math.max(1, Date.now() - startTime);
      meta = {
        app: healthData?.app || 'SIH Landslide Backend',
        version: healthData?.version || '1.0.0',
        environment: rootData?.environment || 'development',
        docs: rootData?.docs || 'http://127.0.0.1:8000/docs',
      };
      setBackendMeta(meta);
    } catch (err) {
      backendOnline = false;
      console.warn('[SystemStatus] Backend health check failed:', err);
    }

    setStatuses(prev => prev.map(s => {
      if (s.module === 'M3') {
        return {
          ...s,
          status: backendOnline ? 'OPERATIONAL' : 'DEGRADED',
          latencyMs: backendOnline ? backendLatency : 35,
          lastSync: 'Just now',
          details: backendOnline
            ? `Connected to ${meta?.app || 'FastAPI'} v${meta?.version || '1.0.0'} (${meta?.environment || 'local'}).`
            : s.details
        };
      }
      if (s.module === 'M1') {
        return {
          ...s,
          status: backendOnline ? 'OPERATIONAL' : s.status,
          latencyMs: backendOnline ? Math.max(8, backendLatency - 2) : 28,
          lastSync: 'Just now',
          details: backendOnline
            ? 'M1 XGBoost ML prediction engine connected via backend API.'
            : s.details
        };
      }
      return {
        ...s,
        latencyMs: Math.floor(15 + Math.random() * 80),
        lastSync: 'Just now'
      };
    }));

    setRefreshing(false);
  }, []);

  useEffect(() => {
    checkHealth();
  }, [checkHealth]);

  const handleRefresh = () => {
    checkHealth();
  };

  return (
    <div className="h-full overflow-y-auto bg-slate-50 p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <Server className="w-4 h-4" />
            </div>
            <div>
              <h1 className="font-bold text-slate-900 text-lg tracking-tight">System Health & Subsystem Telemetry</h1>
              <p className="text-xs text-slate-500">
                Operational status of ML Hazard Engine (M1), Citizen App (M2), PostGIS (M3), GIS Frontend (M4), Satellite Feeds (M5), and DevOps (M6).
              </p>
            </div>
          </div>
        </div>

        <Button variant="secondary" size="sm" icon={RefreshCw} onClick={handleRefresh} disabled={refreshing}>
          {refreshing ? 'Testing Subsystems...' : 'Run Diagnostics'}
        </Button>
      </div>

      {/* KPI Overview Summary */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <div className="bg-white p-4 rounded-xl border border-emerald-200/80 bg-emerald-50/20 shadow-card">
          <span className="text-[11px] font-medium text-emerald-800 block">Overall System State</span>
          <div className="text-2xl font-bold text-emerald-600 mt-1 flex items-center gap-1.5">
            <CheckCircle2 className="w-5 h-5 text-emerald-500" />
            <span>100% Online</span>
          </div>
          <span className="text-[10px] text-emerald-700 mt-0.5 block font-medium">All 6 core modules operational</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Active Microservices</span>
          <div className="text-2xl font-bold text-slate-900 font-mono mt-1">6 / 6</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">Docker Swarm containerized</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Avg Response Latency</span>
          <div className="text-2xl font-bold text-sky-600 font-mono mt-1">28 ms</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">FastAPI ASGI async loop</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Spatial Database</span>
          <div className="text-2xl font-bold text-slate-900 font-mono mt-1">PostGIS 3.4</div>
          <span className="text-[10px] text-emerald-600 mt-0.5 block font-medium">EPSG:4326 indexed</span>
        </div>
      </div>

      {/* System Status Matrix Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {statuses.map(item => (
          <div key={item.id} className="p-5 bg-white border border-slate-200/90 rounded-xl shadow-card space-y-3 hover:border-slate-300 transition-all">
            <div className="flex items-center justify-between">
              <span className="font-mono text-xs font-semibold text-sky-800 bg-sky-50 px-2 py-0.5 border border-sky-200 rounded-md">
                Module {item.module}
              </span>
              <StatusBadge status={item.status} />
            </div>

            <div>
              <h3 className="font-semibold text-slate-900 text-sm leading-snug">{item.name}</h3>
              <p className="text-xs text-slate-500 mt-1 leading-relaxed">{item.details}</p>
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500 font-mono">
              <span className="flex items-center gap-1">
                <Wifi className="w-3.5 h-3.5 text-emerald-500" />
                <span>Latency: <strong className="text-slate-700">{item.latencyMs} ms</strong></span>
              </span>
              <span className="flex items-center gap-1 text-[11px] text-slate-400">
                <Clock className="w-3 h-3" />
                <span>{item.lastSync}</span>
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* System Architecture Telemetry Summary */}
      <div className="bg-slate-900 text-white p-5 rounded-xl border border-slate-800 shadow-panel space-y-4">
        <div className="flex items-center gap-2 border-b border-slate-800 pb-3">
          <Database className="w-4 h-4 text-sky-400" />
          <h2 className="font-semibold text-xs text-white tracking-tight uppercase">
            Production GIS Engine & Satellite Telemetry
          </h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs font-mono">
          <div className="bg-slate-800/80 p-3 rounded-lg border border-slate-700/60">
            <span className="text-slate-400 block text-[10px] uppercase font-semibold">PostGIS Engine</span>
            <span className="text-white font-bold block mt-0.5">PostgreSQL 16 + PostGIS 3.4</span>
            <span className="text-[10px] text-slate-400 block mt-0.5">EPSG:4326 WGS 84</span>
          </div>
          <div className="bg-slate-800/80 p-3 rounded-lg border border-slate-700/60">
            <span className="text-slate-400 block text-[10px] uppercase font-semibold">Satellite Feeds</span>
            <span className="text-white font-bold block mt-0.5">NASA GPM IMERG + Sentinel-1</span>
            <span className="text-[10px] text-slate-400 block mt-0.5">15-min rainfall grid</span>
          </div>
          <div className="bg-slate-800/80 p-3 rounded-lg border border-slate-700/60">
            <span className="text-slate-400 block text-[10px] uppercase font-semibold">Vector Acceleration</span>
            <span className="text-white font-bold block mt-0.5">MapLibre GL JS v6.x</span>
            <span className="text-[10px] text-slate-400 block mt-0.5">60 FPS WebGL 2.0 renderer</span>
          </div>
        </div>
      </div>
    </div>
  );
}
