import { INITIAL_REPORTS } from '../../data/mock/reportsData.js';
import { apiFetch } from '../apiClient.js';

let mockReportsStore = [...INITIAL_REPORTS];

function transformBackendReport(report) {
  const isVerified = report.status === 'VERIFIED';
  const isPending = report.status === 'PENDING';
  
  let mediaList = Array.isArray(report.media) ? [...report.media] : [];
  if (mediaList.length === 0) {
    if (report.photo_url) {
      mediaList.push({
        id: `MED-${report.id}-P1`,
        type: 'photo',
        title: 'Report Incident Photograph',
        caption: report.photo_caption || report.description || 'Uploaded incident photo',
        url: report.photo_url,
        thumbnail: report.photo_url,
        source: 'CITIZEN_UPLOAD',
        source_label: 'Citizen Mobile App',
        captured_at: report.capture_timestamp || new Date().toISOString(),
        coordinates: [report.longitude, report.latitude]
      });
    }
    if (report.video_url) {
      mediaList.push({
        id: `MED-${report.id}-V1`,
        type: 'video',
        title: 'Report Video Capture',
        caption: 'Citizen or field recorded video stream',
        url: report.video_url,
        source: 'CITIZEN_UPLOAD',
        source_label: 'Mobile Video Capture',
        captured_at: report.capture_timestamp || new Date().toISOString(),
        coordinates: [report.longitude, report.latitude]
      });
    }
  }

  const photoCount = report.photo_count ?? mediaList.filter(m => m.type === 'photo').length;
  const videoCount = report.video_count ?? mediaList.filter(m => m.type === 'video').length;

  return {
    id: String(report.id),
    location_name: report.location_name || (report.description ? report.description.slice(0, 35) : `Sector [${report.latitude?.toFixed(2)}, ${report.longitude?.toFixed(2)}]`),
    district: report.district || 'Papum Pare',
    coordinates: [report.longitude, report.latitude],
    severity: report.severity || (report.report_type === 'LANDSLIDE' ? 'CRITICAL' : 'HIGH'),
    verification_status: isVerified ? 'VERIFIED' : (isPending ? 'UNVERIFIED' : report.status),
    status: isVerified ? 'UNDER_MONITORING' : (report.status === 'REJECTED' ? 'REJECTED' : 'PENDING_VERIFICATION'),
    reporter_type: report.reporter_type || 'CITIZEN',
    reporter_name: report.reporter_name || 'Field Contributor',
    reported_at: report.capture_timestamp || report.reported_at || report.created_at || new Date().toISOString(),
    description: report.description || 'Ground observation report',
    media_available: Boolean(mediaList.length > 0 || report.media_available),
    media: mediaList,
    photo_count: photoCount,
    video_count: videoCount,
    photo_caption: report.photo_caption,
    verification_notes: report.verification_notes || report.remarks,
    verified_by: report.verified_by,
    verified_at: report.verified_at,
    checklist: report.checklist || []
  };
}

export const reportService = {
  /**
   * Fetch field reports standard GeoJSON FeatureCollection (M4 GIS Dashboard layer)
   */
  async getReportsGeoJSON(statusFilter = null) {
    try {
      const url = statusFilter ? `/reports/geojson?status=${statusFilter}` : '/reports/geojson';
      const data = await apiFetch(url);
      // A real empty FeatureCollection (no reports yet) is live data, not a
      // failure - only a fetch exception should return null here (audit
      // §5.10; also see M3's own §5.12 fix for the matching backend bug).
      if (data && data.type === 'FeatureCollection' && Array.isArray(data.features)) {
        return { data, source: 'live' };
      }
      return { data: null, source: 'mock' };
    } catch {
      return { data: null, source: 'mock' };
    }
  },

  async getReports(filters = {}) {
    let backendReachable = true;
    try {
      const params = {};
      if (filters.verification_status && filters.verification_status !== 'ALL') {
        params.status = filters.verification_status === 'VERIFIED' ? 'VERIFIED' : 'PENDING';
      }
      const query = new URLSearchParams(params).toString();
      const data = await apiFetch(`/reports${query ? `?${query}` : ''}`);
      if (Array.isArray(data)) {
        // A successful, empty array means "no reports match this filter" -
        // real live data - not a reason to fall back to the mock store
        // (audit §5.10).
        let transformed = data.map(transformBackendReport);
        if (filters.severity && filters.severity !== 'ALL') {
          transformed = transformed.filter(r => r.severity === filters.severity);
        }
        if (filters.search) {
          const q = filters.search.toLowerCase();
          transformed = transformed.filter(r =>
            r.location_name.toLowerCase().includes(q) ||
            r.description.toLowerCase().includes(q) ||
            r.id.toLowerCase().includes(q)
          );
        }
        return { data: transformed, source: 'live' };
      }
      backendReachable = false;
    } catch {
      backendReachable = false;
    }
    if (!backendReachable) {
      let filtered = [...mockReportsStore];
      if (filters.verification_status && filters.verification_status !== 'ALL') {
        filtered = filtered.filter(r => r.verification_status === filters.verification_status);
      }
      if (filters.severity && filters.severity !== 'ALL') {
        filtered = filtered.filter(r => r.severity === filters.severity);
      }
      if (filters.search) {
        const q = filters.search.toLowerCase();
        filtered = filtered.filter(r =>
          r.location_name.toLowerCase().includes(q) ||
          r.description.toLowerCase().includes(q) ||
          r.id.toLowerCase().includes(q)
        );
      }
      return { data: filtered, source: 'mock' };
    }
  },

  async verifyReport(reportId, status = 'VERIFIED', remarks = 'Verified by operational officer') {
    try {
      const decision = status === 'VERIFIED' ? 'VERIFY' : (status === 'REJECTED' ? 'REJECT' : 'NEEDS_INFORMATION');
      const result = await apiFetch(`/reports/${reportId}/verify`, {
        method: 'POST',
        body: JSON.stringify({ decision, remarks })
      });
      return result;
    } catch {
      mockReportsStore = mockReportsStore.map(r => {
        if (r.id === reportId) {
          return {
            ...r,
            verification_status: status,
            verified_by: 'DDMO Duty Officer (Local Verification)',
            verified_at: new Date().toISOString(),
            verification_notes: remarks,
            status: status === 'VERIFIED' ? 'UNDER_MONITORING' : 'REJECTED'
          };
        }
        return r;
      });
      return mockReportsStore.find(r => r.id === reportId);
    }
  },

  async submitReport(newReportData) {
    try {
      const payload = {
        report_type: newReportData.report_type || 'LANDSLIDE',
        description: newReportData.description || 'Landslide observed',
        latitude: newReportData.coordinates ? newReportData.coordinates[1] : (newReportData.latitude || 27.20),
        longitude: newReportData.coordinates ? newReportData.coordinates[0] : (newReportData.longitude || 93.65),
        capture_timestamp: newReportData.capture_timestamp || new Date().toISOString(),
      };
      const result = await apiFetch('/reports', {
        method: 'POST',
        body: JSON.stringify(payload)
      });
      return transformBackendReport(result);
    } catch {
      const created = {
        id: `REP-2026-${Math.floor(100 + Math.random() * 900)}`,
        reported_at: new Date().toISOString(),
        reporter_type: 'CITIZEN',
        verification_status: 'UNVERIFIED',
        status: 'PENDING_VERIFICATION',
        media_available: Boolean(newReportData.photo_url),
        ...newReportData
      };
      mockReportsStore.unshift(created);
      return created;
    }
  }
};
