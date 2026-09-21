import React, { useEffect, useState } from 'react';
import {
  Area,
  AreaChart,
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts';
import { BarChart3, CloudRain, TrendingUp, Layers } from 'lucide-react';
import { environmentalService } from '../../services/environmental/environmentalService.js';
import { RiskBadge } from '../../components/ui/RiskBadge.jsx';

// 7-day historical risk trend for Papum Pare
const SEVEN_DAY_RISK_TREND = [
  { day: 'Sep 3', riskScore: 0.28, rainfall: 18.4, alerts: 0 },
  { day: 'Sep 4', riskScore: 0.31, rainfall: 22.1, alerts: 0 },
  { day: 'Sep 5', riskScore: 0.44, rainfall: 58.5, alerts: 1 },
  { day: 'Sep 6', riskScore: 0.61, rainfall: 92.0, alerts: 1 },
  { day: 'Sep 7', riskScore: 0.75, rainfall: 118.5, alerts: 2 },
  { day: 'Sep 8', riskScore: 0.88, rainfall: 142.0, alerts: 2 },
  { day: 'Sep 9', riskScore: 0.91, rainfall: 162.0, alerts: 2 },
];

export function Analytics() {
  const [timelineData, setTimelineData] = useState([]);

  useEffect(() => {
    async function loadData() {
      const timeline = await environmentalService.getRainfallTimeline();
      setTimelineData(timeline.data);
    }
    loadData();
  }, []);

  // Arunachal Pradesh district sector risk distribution data
  const subdivisionData = [
    { name: 'Sela Pass Corridor (Tawang)', riskScore: 96, criticalEvents: 22, popExposed: 3100, status: 'CRITICAL' },
    { name: 'Anini Gorge (Dibang Valley)', riskScore: 94, criticalEvents: 19, popExposed: 2400, status: 'CRITICAL' },
    { name: 'Sagalee Highway (Papum Pare)', riskScore: 92, criticalEvents: 14, popExposed: 4200, status: 'CRITICAL' },
    { name: 'Yachuli Pass (Lower Subansiri)', riskScore: 88, criticalEvents: 12, popExposed: 6200, status: 'CRITICAL' },
    { name: 'Dirang Valley (West Kameng)', riskScore: 81, criticalEvents: 10, popExposed: 5400, status: 'HIGH' },
    { name: 'Pasighat Slope (East Siang)', riskScore: 79, criticalEvents: 8, popExposed: 14000, status: 'HIGH' },
    { name: 'Mechuka Airfield (Shi Yomi)', riskScore: 82, criticalEvents: 7, popExposed: 3500, status: 'HIGH' },
    { name: 'Naharlagun-Yupia (Papum Pare)', riskScore: 54, criticalEvents: 4, popExposed: 12400, status: 'MODERATE' }
  ];

  // Environmental Factor Correlation
  const factorData = [
    { factor: 'Rainfall > 100mm/24h', impact: 92, fill: '#0284c7' },
    { factor: 'Slope Gradient > 35°', impact: 85, fill: '#e11d48' },
    { factor: 'Soil Saturation > 80%', impact: 78, fill: '#d97706' },
    { factor: 'SAR InSAR Shift > 10mm/yr', impact: 64, fill: '#7c3aed' },
    { factor: 'Deforested Road Cut Slope', impact: 52, fill: '#059669' }
  ];

  return (
    <div className="h-full overflow-y-auto bg-slate-50 p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="border-b border-slate-200/80 pb-5">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-sky-50 text-sky-600 flex items-center justify-center">
            <BarChart3 className="w-4 h-4" />
          </div>
          <div>
            <h1 className="font-bold text-slate-900 text-lg tracking-tight">Risk Analytics & Decision Support</h1>
            <p className="text-xs text-slate-500">
              Multi-factor environmental trigger analysis, satellite telemetry, and historical trend modeling for Papum Pare.
            </p>
          </div>
        </div>
      </div>

      {/* Metric KPI Summary */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">7-Day Max 24h Rain</span>
          <div className="text-2xl font-bold text-sky-600 font-mono mt-1">162.0 mm</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">Recorded at Sagalee station</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Peak Soil Saturation</span>
          <div className="text-2xl font-bold text-amber-600 font-mono mt-1">84.0%</div>
          <span className="text-[10px] text-amber-600 mt-0.5 block font-medium">Exceeds 75% threshold</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">High Risk Sectors</span>
          <div className="text-2xl font-bold text-rose-600 font-mono mt-1">4 of 7</div>
          <span className="text-[10px] text-rose-600 mt-0.5 block font-medium">Sagalee, Mengio, Toru, Karsingsa</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200/90 shadow-card">
          <span className="text-[11px] font-medium text-slate-500 block">Exposed Population</span>
          <div className="text-2xl font-bold text-slate-900 font-mono mt-1">54,800</div>
          <span className="text-[10px] text-slate-400 mt-0.5 block">Census 2021 estimation</span>
        </div>
      </div>

      {/* Grid of Decision Support Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

        {/* Chart 1: 7-Day Risk Escalation Trend (Full Width) */}
        <div className="bg-white p-5 rounded-xl border border-slate-200/90 shadow-card space-y-3 lg:col-span-2">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-slate-100 pb-3">
            <div>
              <h2 className="font-semibold text-slate-900 text-sm tracking-tight flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-rose-600" />
                <span>7-Day Landslide Risk Escalation Trend</span>
              </h2>
              <p className="text-[11px] text-slate-400 mt-0.5">Continuous ML inference vs. measured GPM IMERG rainfall accumulation</p>
            </div>
            <div className="flex items-center gap-2">
              <RiskBadge level="CRITICAL" score={0.91} showScore={true} size="sm" />
              <span className="text-[10px] text-slate-400 font-mono bg-slate-50 px-2 py-0.5 rounded border border-slate-200">XGBoost v1.4</span>
            </div>
          </div>

          <div className="h-60 w-full pt-2">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={SEVEN_DAY_RISK_TREND}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="day" stroke="#94a3b8" fontSize={11} tickLine={false} />
                <YAxis yAxisId="risk" domain={[0, 1]} stroke="#e11d48" fontSize={11} tickFormatter={v => `${(v * 100).toFixed(0)}%`} tickLine={false} />
                <YAxis yAxisId="rain" orientation="right" stroke="#0284c7" fontSize={11} unit="mm" tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: '#ffffff', borderRadius: '8px', fontSize: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 12px rgba(0,0,0,0.08)' }}
                  formatter={(value, name) => {
                    if (name === 'ML Risk Score') return [`${(value * 100).toFixed(0)}%`, name];
                    if (name === 'Rainfall (mm)') return [`${value} mm`, name];
                    return [value, name];
                  }}
                />
                <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '8px' }} />
                <ReferenceLine yAxisId="risk" y={0.75} stroke="#e11d48" strokeDasharray="4 4" label={{ value: 'Warning Threshold (75%)', position: 'insideTopRight', fontSize: 10, fill: '#e11d48' }} />
                <Line yAxisId="risk" type="monotone" dataKey="riskScore" name="ML Risk Score" stroke="#e11d48" strokeWidth={2.5} dot={{ r: 4, fill: '#e11d48' }} activeDot={{ r: 6 }} />
                <Line yAxisId="rain" type="monotone" dataKey="rainfall" name="Rainfall (mm)" stroke="#0284c7" strokeWidth={2} strokeDasharray="5 3" dot={{ r: 3, fill: '#0284c7' }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
          <div className="bg-rose-50/50 border border-rose-100 rounded-lg p-2.5 text-[11px] text-rose-800">
            <strong>Key Insight:</strong> Rainfall exceeded 100mm threshold on Sep 7, driving composite risk probability past 0.75 critical limit. High probability of debris flows along highway corridors.
          </div>
        </div>

        {/* Chart 2: 24h Rain vs Probability Curve */}
        <div className="bg-white p-5 rounded-xl border border-slate-200/90 shadow-card space-y-3">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <div>
              <h2 className="font-semibold text-slate-900 text-sm tracking-tight flex items-center gap-2">
                <CloudRain className="w-4 h-4 text-sky-600" />
                <span>24-Hour Rainfall vs Risk Probability Dynamics</span>
              </h2>
              <p className="text-[11px] text-slate-400 mt-0.5">Real-time GPM IMERG satellite feed</p>
            </div>
          </div>

          <div className="h-60 w-full pt-2">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={timelineData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="time" stroke="#94a3b8" fontSize={11} tickLine={false} />
                <YAxis yAxisId="left" stroke="#0284c7" fontSize={11} unit="mm" tickLine={false} />
                <YAxis yAxisId="right" orientation="right" stroke="#e11d48" fontSize={11} domain={[0, 1]} tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: '#ffffff', borderRadius: '8px', fontSize: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 12px rgba(0,0,0,0.08)' }}
                />
                <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '8px' }} />
                <Area yAxisId="left" type="monotone" dataKey="rainfall" name="24h Rain (mm)" stroke="#0284c7" fill="#e0f2fe" fillOpacity={0.6} />
                <Area yAxisId="right" type="monotone" dataKey="riskScore" name="Risk Probability" stroke="#e11d48" fill="#ffe4e6" fillOpacity={0.4} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Chart 3: Environmental Trigger Factor Importance */}
        <div className="bg-white p-5 rounded-xl border border-slate-200/90 shadow-card space-y-3">
          <div className="border-b border-slate-100 pb-3">
            <h2 className="font-semibold text-slate-900 text-sm tracking-tight flex items-center gap-2">
              <Layers className="w-4 h-4 text-purple-600" />
              <span>Multi-Factor Trigger Weight Analysis</span>
            </h2>
            <p className="text-[11px] text-slate-400 mt-0.5">SHAP feature importance ranking from XGBoost hazard model</p>
          </div>

          <div className="space-y-3 pt-2">
            {factorData.map(item => (
              <div key={item.factor} className="space-y-1">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-medium text-slate-700">{item.factor}</span>
                  <span className="font-mono font-bold text-slate-900">{item.impact}% impact</span>
                </div>
                <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all duration-500"
                    style={{ width: `${item.impact}%`, backgroundColor: item.fill }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Sector Risk Breakdown Table */}
        <div className="bg-white p-5 rounded-xl border border-slate-200/90 shadow-card space-y-3 lg:col-span-2">
          <div className="border-b border-slate-100 pb-3 flex items-center justify-between">
            <div>
              <h2 className="font-semibold text-slate-900 text-sm tracking-tight">
                Sector-Wise Risk & Population Exposure Index
              </h2>
              <p className="text-[11px] text-slate-400 mt-0.5">Jurisdictional vulnerability assessment for Papum Pare District</p>
            </div>
            <span className="text-[11px] text-slate-400 font-mono">6 monitored sectors</span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold text-[11px] uppercase tracking-wider">
                <tr>
                  <th className="py-2.5 px-4">Sector Name</th>
                  <th className="py-2.5 px-4">Current Risk Score</th>
                  <th className="py-2.5 px-4">Status</th>
                  <th className="py-2.5 px-4">Historical Events</th>
                  <th className="py-2.5 px-4 text-right">Exposed Population</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {subdivisionData.map(sector => (
                  <tr key={sector.name} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-2.5 px-4 font-semibold text-slate-800">{sector.name}</td>
                    <td className="py-2.5 px-4 font-mono font-bold text-slate-900">{sector.riskScore}/100</td>
                    <td className="py-2.5 px-4">
                      <RiskBadge level={sector.status} size="xs" />
                    </td>
                    <td className="py-2.5 px-4 font-mono text-slate-600">{sector.criticalEvents} incidents</td>
                    <td className="py-2.5 px-4 text-right font-mono text-slate-800">{sector.popExposed.toLocaleString()}</td>
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
