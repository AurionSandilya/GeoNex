import React, { useState } from 'react';
import { Calendar, Eye, History, MapPin, Search } from 'lucide-react';
import { HISTORICAL_EVENTS_GEOJSON } from '../../data/geojson/historicalEvents.js';
import { RiskBadge } from '../../components/ui/RiskBadge.jsx';
import { StatusBadge } from '../../components/ui/StatusBadge.jsx';
import { Button } from '../../components/ui/Button.jsx';
import { useSelection } from '../../app/providers/SelectionContext.jsx';
import { useNavigate } from 'react-router-dom';

export function HistoricalEvents() {
  const [events] = useState(HISTORICAL_EVENTS_GEOJSON.features);
  const [searchQuery, setSearchQuery] = useState('');
  const { selectFeature } = useSelection();
  const navigate = useNavigate();

  const filteredEvents = events.filter(e => {
    const p = e.properties;
    const q = searchQuery.toLowerCase();
    return p.title.toLowerCase().includes(q) || p.location_name.toLowerCase().includes(q) || p.event_id.toLowerCase().includes(q);
  });

  const handleInspectMap = (event) => {
    const p = event.properties;
    const coords = event.geometry?.coordinates || [93.45, 27.22];
    selectFeature({
      type: 'HISTORICAL',
      id: p.event_id,
      title: p.title,
      location_name: p.location_name,
      severity: p.severity,
      rainfall_24h: p.rainfall_trigger_mm,
      message: `Historical disaster incident: ${p.road_closure_days} days road blockage recorded on ${p.date}.`,
      coordinates: coords,
      status: 'VERIFIED'
    }, { zoom: 13 });
    navigate('/risk-map');
  };

  return (
    <div className="h-full overflow-y-auto bg-slate-50 p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="border-b border-slate-200/80 pb-5">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center">
            <History className="w-4 h-4" />
          </div>
          <div>
            <h1 className="font-bold text-slate-900 text-lg tracking-tight">GSI Historical Landslide Catalog</h1>
            <p className="text-xs text-slate-500">
              Historical landslide inventory for Papum Pare and North-East India corridors with recorded rainfall trigger parameters.
            </p>
          </div>
        </div>
      </div>

      {/* KPI Metric Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Cataloged Incidents</span>
          <div className="text-2xl font-bold text-purple-700 font-mono mt-1">{events.length}</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">GSI validated historical inventory</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Max Recorded Rain Trigger</span>
          <div className="text-2xl font-bold text-sky-600 font-mono mt-1">218 mm</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">Sagalee corridor landslide (2022)</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Avg Highway Closure</span>
          <div className="text-2xl font-bold text-amber-600 font-mono mt-1">4.2 days</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">NH-229 & NH-415 transport disruption</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Corridor Coverage</span>
          <div className="text-2xl font-bold text-emerald-600 font-mono mt-1">100%</div>
          <span className="text-[10px] text-emerald-600 mt-0.5 block font-medium">Mapped to current PostGIS grid</span>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-3.5 border border-slate-200/90 rounded-xl shadow-card flex items-center justify-between gap-4 text-xs">
        <div className="relative min-w-[280px] flex-1 sm:flex-initial">
          <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search incident name, location, event ID..."
            className="w-full pl-8 pr-3 py-1.5 bg-slate-50 border border-slate-200 rounded-lg text-xs outline-none focus:ring-1 focus:ring-sky-500 focus:bg-white transition-all"
          />
        </div>

        <div className="text-slate-400 font-mono text-[11px]">
          Showing <strong>{filteredEvents.length}</strong> of {events.length} incidents
        </div>
      </div>

      {/* Catalog Table */}
      <div className="bg-white border border-slate-200/90 rounded-xl shadow-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold text-[11px] uppercase tracking-wider">
              <tr>
                <th className="py-3 px-4">Event ID</th>
                <th className="py-3 px-4">Incident Name & Location</th>
                <th className="py-3 px-4">Date</th>
                <th className="py-3 px-4">Severity</th>
                <th className="py-3 px-4">Trigger Rain</th>
                <th className="py-3 px-4">Road Impact</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {filteredEvents.map(event => {
                const p = event.properties;
                return (
                  <tr key={p.event_id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3 px-4 font-mono font-semibold text-purple-900">{p.event_id}</td>
                    <td className="py-3 px-4">
                      <div className="font-medium text-slate-900 leading-snug">{p.title}</div>
                      <div className="text-[11px] text-slate-500 flex items-center gap-1 mt-0.5">
                        <MapPin className="w-3 h-3 text-purple-600 shrink-0" />
                        <span>{p.location_name}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4 font-mono text-slate-500">
                      <div className="flex items-center gap-1">
                        <Calendar className="w-3 h-3 text-slate-400" />
                        <span>{p.date}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <RiskBadge level={p.severity} size="sm" />
                    </td>
                    <td className="py-3 px-4 font-mono font-semibold text-sky-700">
                      {p.rainfall_trigger_mm} mm
                    </td>
                    <td className="py-3 px-4 text-slate-600">
                      {p.road_closure_days} days closure
                    </td>
                    <td className="py-3 px-4">
                      <StatusBadge status="VERIFIED" label={p.verification_status} />
                    </td>
                    <td className="py-3 px-4 text-right">
                      <Button
                        size="xs"
                        variant="secondary"
                        icon={Eye}
                        onClick={() => handleInspectMap(event)}
                      >
                        Inspect Map
                      </Button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
