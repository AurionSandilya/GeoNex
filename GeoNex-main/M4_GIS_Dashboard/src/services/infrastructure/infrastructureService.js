import { INFRASTRUCTURE_GEOJSON, VILLAGES_GEOJSON } from '../../data/geojson/infrastructure.js';
import { ROAD_NETWORK_GEOJSON } from '../../data/geojson/roadNetwork.js';
import { apiFetch } from '../apiClient.js';

export const infrastructureService = {
  /**
   * Fetch critical facilities list or GeoJSON
   */
  async getFacilities() {
    try {
      const data = await apiFetch('/infrastructure');
      // A successful, empty list is real live data (no facilities match),
      // not a failure - only a fetch exception falls back to demo data
      // (audit §5.10).
      if (Array.isArray(data)) {
        return {
          data: {
            type: 'FeatureCollection',
            features: data.map(item => ({
              type: 'Feature',
              geometry: {
                type: 'Point',
                coordinates: [item.longitude, item.latitude]
              },
              properties: item
            }))
          },
          source: 'live',
        };
      }
      return { data: INFRASTRUCTURE_GEOJSON, source: 'mock' };
    } catch {
      return { data: INFRASTRUCTURE_GEOJSON, source: 'mock' };
    }
  },

  /**
   * Fetch road network LineString GeoJSON
   */
  async getRoadNetwork() {
    try {
      const data = await apiFetch('/roads/geojson');
      // /roads/geojson now returns 200 with real (possibly empty) feature
      // data instead of a 500 (audit §5.11) - an empty collection is live
      // data, not a failure.
      if (data && Array.isArray(data.features)) {
        return { data, source: 'live' };
      }
      return { data: ROAD_NETWORK_GEOJSON, source: 'mock' };
    } catch {
      return { data: ROAD_NETWORK_GEOJSON, source: 'mock' };
    }
  },

  /**
   * Fetch villages data
   */
  async getVillages() {
    try {
      const data = await apiFetch('/villages');
      if (Array.isArray(data)) {
        return {
          data: {
            type: 'FeatureCollection',
            features: data.map(item => ({
              type: 'Feature',
              geometry: {
                type: 'Point',
                coordinates: [item.longitude, item.latitude]
              },
              properties: item
            }))
          },
          source: 'live',
        };
      }
      return { data: VILLAGES_GEOJSON, source: 'mock' };
    } catch {
      return { data: VILLAGES_GEOJSON, source: 'mock' };
    }
  }
};

