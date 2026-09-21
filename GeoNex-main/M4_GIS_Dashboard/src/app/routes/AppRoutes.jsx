import { Route, Routes } from 'react-router-dom';
import { Dashboard } from '../../pages/Dashboard/Dashboard.jsx';
import { RiskMap } from '../../pages/RiskMap/RiskMap.jsx';
import { Reports } from '../../pages/Reports/Reports.jsx';
import { Alerts } from '../../pages/Alerts/Alerts.jsx';
import { Analytics } from '../../pages/Analytics/Analytics.jsx';
import { HistoricalEvents } from '../../pages/HistoricalEvents/HistoricalEvents.jsx';
import { SystemStatus } from '../../pages/SystemStatus/SystemStatus.jsx';

export function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Dashboard />} />
      <Route path="/risk-map" element={<RiskMap />} />
      <Route path="/reports" element={<Reports />} />
      <Route path="/alerts" element={<Alerts />} />
      <Route path="/analytics" element={<Analytics />} />
      <Route path="/historical-events" element={<HistoricalEvents />} />
      <Route path="/system-status" element={<SystemStatus />} />
    </Routes>
  );
}
