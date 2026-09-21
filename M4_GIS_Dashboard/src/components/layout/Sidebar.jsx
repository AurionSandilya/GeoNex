import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';
import {
  BarChart3,
  Bell,
  ChevronLeft,
  ChevronRight,
  FileText,
  History,
  LayoutDashboard,
  Map,
  Server
} from 'lucide-react';

export function Sidebar() {
  const [collapsed, setCollapsed] = useState(false);

  const navItems = [
    { to: '/', label: 'Overview', icon: LayoutDashboard },
    { to: '/risk-map', label: 'Risk Map', icon: Map },
    { to: '/reports', label: 'Field Reports', icon: FileText, badge: '5' },
    { to: '/alerts', label: 'Alert Bulletins', icon: Bell, badge: '2', badgeColor: 'bg-rose-500' },
    { to: '/analytics', label: 'Risk Analytics', icon: BarChart3 },
    { to: '/historical-events', label: 'Disaster History', icon: History },
    { to: '/system-status', label: 'System Health', icon: Server }
  ];

  return (
    <aside
      className={`bg-white border-r border-slate-200/90 flex flex-col justify-between transition-all duration-200 z-20 shrink-0 select-none ${collapsed ? 'w-14' : 'w-56'
        }`}
      aria-label="Operational Navigation Sidebar"
    >
      <div>
        {/* Toggle collapse button */}
        <div className="p-2 border-b border-slate-100 flex justify-end">
          <button
            onClick={() => setCollapsed(!collapsed)}
            className="p-1.5 rounded-md text-slate-400 hover:text-slate-700 hover:bg-slate-100 cursor-pointer transition-colors"
            aria-label={collapsed ? "Expand sidebar navigation" : "Collapse sidebar navigation"}
            title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
          >
            {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
          </button>
        </div>

        {/* Navigation links */}
        <nav className="p-2 space-y-1">
          {navItems.map(item => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === '/'}
                className={({ isActive }) =>
                  `flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-medium transition-all duration-150 ${isActive
                    ? 'bg-sky-50 text-sky-700 font-semibold shadow-2xs'
                    : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                  }`
                }
                title={collapsed ? item.label : undefined}
              >
                {({ isActive }) => (
                  <>
                    <Icon className={`w-4 h-4 shrink-0 transition-colors ${isActive ? 'text-sky-600' : 'text-slate-400'}`} aria-hidden="true" />
                    {!collapsed && <span className="truncate flex-1">{item.label}</span>}
                    {!collapsed && item.badge && (
                      <span className={`px-1.5 py-0.2 text-[10px] font-bold rounded-full text-white ${item.badgeColor || 'bg-slate-700'}`}>
                        {item.badge}
                      </span>
                    )}
                  </>
                )}
              </NavLink>
            );
          })}
        </nav>
      </div>

      {/* Footer metadata */}
      {!collapsed && (
        <div className="p-3 border-t border-slate-100 bg-slate-50/70 text-[11px] text-slate-500 space-y-0.5">
          <div className="font-semibold text-slate-800 flex items-center justify-between">
            <span>KAIRO</span>
            <span className="text-[10px] text-sky-700 bg-sky-50 px-1.5 py-0.2 rounded border border-sky-200">SIH 2026</span>
          </div>
          <div className="text-[10px] text-slate-400 font-mono">Papum Pare • PostGIS 3.4</div>
        </div>
      )}
    </aside>
  );
}
