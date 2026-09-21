import { apiFetch } from '../apiClient.js';
import { MOCK_ALERTS, ALERT_HISTORY } from '../../data/mock/alertsData.js';

function transformBackendAlert(alert) {
  // M3's AlertResponse / M5's alert state machine already emit
  // NORMAL/WATCH/WARNING/CRITICAL directly - the LOW->NORMAL / HIGH->WARNING
  // translation here was compensating for RiskBadge/MapLibreViewer's old
  // LOW/MODERATE/HIGH/CRITICAL vocabulary (see audit §3.9/5.8). Now that
  // those read the real vocabulary directly, re-translating here would
  // just be relabeling values that were never LOW/HIGH to begin with.
  const sev = (alert.severity || alert.current_severity || 'NORMAL').toUpperCase();
  const priority = sev === 'CRITICAL' ? 'P1' : sev === 'WARNING' ? 'P2' : sev === 'WATCH' ? 'P3' : 'P4';

  return {
    id: alert.id || alert.alert_id,
    area_id: alert.area_id || 'papum_pare',
    priority: priority,
    severity: sev,
    status: alert.status || alert.lifecycle_status || 'ACTIVE',
    title: alert.title || `Landslide ${sev} Alert`,
    message: alert.message || `Landslide risk evaluated at ${sev} for monitoring zone ${alert.area_id || 'Papum Pare'}.`,
    location_name: alert.location_name || (alert.area_id ? `Monitoring Sector ${alert.area_id}` : 'Papum Pare District, NER'),
    // alert.coordinates now comes from M3's AlertResponse.coordinates
    // (populated from the area's most recent risk_predictions row - see
    // audit §5.9); the [93.65, 27.20] fallback only fires when the backend
    // genuinely has no coordinate for this alert, not as a silent default.
    coordinates: alert.coordinates || [93.65, 27.20],
    risk_score: alert.last_risk_score ?? alert.risk_score ?? (sev === 'CRITICAL' ? 0.92 : sev === 'WARNING' ? 0.72 : sev === 'WATCH' ? 0.45 : 0.15),
    confidence: alert.confidence ?? 0.88,
    rainfall_24h: alert.rainfall_24h || 125.0,
    soil_saturation: alert.soil_saturation || 82.0,
    created_at: alert.created_at || new Date().toISOString(),
    acknowledged_at: alert.acknowledged_at || null,
    affected_infrastructure: alert.affected_infrastructure || ['NER Transport Corridor'],
    recommended_action: alert.recommended_action || (sev === 'CRITICAL' ? 'Immediate road closure and evacuation of vulnerable slopes.' : 'Review slope risk telemetry and alert field squads.'),
  };
}

export const alertService = {
  async getActiveAlerts(statusFilter = null) {
    try {
      const url = statusFilter ? `/alerts?status=${statusFilter}` : '/alerts';
      const data = await apiFetch(url);
      // A successful response - including a genuinely empty array, which
      // just means "no active alerts right now" - is live data. Only an
      // actual fetch failure (network error, non-2xx) below falls back to
      // mock; treating an empty-but-successful response as a failure was
      // masking real "all clear" states behind fabricated mock alerts
      // (audit §5.10).
      if (Array.isArray(data)) {
        return { data: data.map(transformBackendAlert), source: 'live' };
      }
      return { data: MOCK_ALERTS, source: 'mock' };
    } catch {
      return { data: MOCK_ALERTS, source: 'mock' };
    }
  },

  async getAlertHistory() {
    try {
      const data = await apiFetch('/alerts?status=RESOLVED');
      if (Array.isArray(data)) {
        return { data: data.map(transformBackendAlert), source: 'live' };
      }
      return { data: ALERT_HISTORY, source: 'mock' };
    } catch {
      return { data: ALERT_HISTORY, source: 'mock' };
    }
  },

  async acknowledgeAlert(alertId, remarks = 'Acknowledged by operational officer') {
    try {
      const result = await apiFetch(`/alerts/${alertId}/acknowledge`, {
        method: 'POST',
        body: JSON.stringify({ remarks }),
      });
      return { data: transformBackendAlert(result), source: 'live' };
    } catch {
      // Local fallback update for offline mode
      const alert = MOCK_ALERTS.find(a => a.id === alertId);
      if (alert) {
        alert.status = 'ACKNOWLEDGED';
        alert.acknowledged_at = new Date().toISOString();
      }
      return { data: alert || { id: alertId, status: 'ACKNOWLEDGED', acknowledged_at: new Date().toISOString() }, source: 'mock' };
    }
  }
};
