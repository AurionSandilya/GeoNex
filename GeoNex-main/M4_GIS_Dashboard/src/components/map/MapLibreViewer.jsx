import { useEffect, useRef, useState, useCallback } from 'react';
import * as maplibregl from 'maplibre-gl';
import { useLayers } from '../../app/providers/LayerContext.jsx';
import { useSelection } from '../../app/providers/SelectionContext.jsx';
import { useRegion } from '../../app/providers/RegionContext.jsx';
import { MapControls } from './MapControls.jsx';
import { MapLegend } from './MapLegend.jsx';
import { LocationDetailsPanel } from './LocationDetailsPanel.jsx';

import { RISK_ZONES_GEOJSON } from '../../data/geojson/riskZones.js';
import { ROAD_NETWORK_GEOJSON } from '../../data/geojson/roadNetwork.js';
import { VILLAGES_GEOJSON, CRITICAL_INFRASTRUCTURE_GEOJSON } from '../../data/geojson/infrastructure.js';
import { CITIZEN_REPORTS_GEOJSON, VERIFIED_REPORTS_GEOJSON } from '../../data/mock/reportsData.js';
import { MOCK_ALERTS } from '../../data/mock/alertsData.js';
import { alertService } from '../../services/alerts/alertService.js';
import { infrastructureService } from '../../services/infrastructure/infrastructureService.js';
import { reportService } from '../../services/reports/reportService.js';
import { riskService } from '../../services/risk/riskService.js';

// Basemap style configurations (OpenStreetMap variants)
const BASEMAP_STYLES = {
  'osm-standard': {
    version: 8,
    sources: {
      'osm-tiles': {
        type: 'raster',
        tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
        tileSize: 256,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      }
    },
    layers: [
      {
        id: 'osm-tiles-layer',
        type: 'raster',
        source: 'osm-tiles',
        minzoom: 0,
        maxzoom: 19
      }
    ]
  },
  'osm-topo': {
    version: 8,
    sources: {
      'topo-tiles': {
        type: 'raster',
        tiles: [
          'https://a.tile.opentopomap.org/{z}/{x}/{y}.png',
          'https://b.tile.opentopomap.org/{z}/{x}/{y}.png',
          'https://c.tile.opentopomap.org/{z}/{x}/{y}.png'
        ],
        tileSize: 256,
        attribution: '&copy; OpenStreetMap contributors, SRTM | OpenTopoMap'
      }
    },
    layers: [
      {
        id: 'topo-tiles-layer',
        type: 'raster',
        source: 'topo-tiles',
        minzoom: 0,
        maxzoom: 17
      }
    ]
  },
  'osm-satellite': {
    version: 8,
    sources: {
      'satellite-tiles': {
        type: 'raster',
        tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'],
        tileSize: 256,
        attribution: 'Esri, Maxar, Earthstar Geographics, OpenStreetMap'
      }
    },
    layers: [
      {
        id: 'satellite-tiles-layer',
        type: 'raster',
        source: 'satellite-tiles',
        minzoom: 0,
        maxzoom: 19
      }
    ]
  },
  'osm-dark': 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json',
  'osm-light': 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'
};

/**
 * Creates animated pulsing pin marker DOM element for tapped location
 */
function createMarkerElement(riskLevel) {
  const colorMap = {
    CRITICAL: { pin: '#e11d48', pulse: 'rgba(225, 29, 72, 0.45)' },
    HIGH: { pin: '#ea580c', pulse: 'rgba(234, 88, 12, 0.45)' },
    MODERATE: { pin: '#d97706', pulse: 'rgba(217, 119, 6, 0.45)' },
    LOW: { pin: '#059669', pulse: 'rgba(5, 150, 105, 0.45)' }
  };
  const color = colorMap[riskLevel] || colorMap.HIGH;

  const container = document.createElement('div');
  container.className = 'tapped-location-marker';

  const pulse = document.createElement('div');
  pulse.className = 'tapped-marker-pulse';
  pulse.style.backgroundColor = color.pulse;
  pulse.style.boxShadow = `0 0 16px ${color.pin}`;

  const pin = document.createElement('div');
  pin.className = 'tapped-marker-pin';
  pin.style.backgroundColor = color.pin;

  const dot = document.createElement('div');
  dot.className = 'tapped-marker-dot';

  pin.appendChild(dot);
  container.appendChild(pulse);
  container.appendChild(pin);

  return container;
}

export function MapLibreViewer() {
  const mapContainerRef = useRef(null);
  const mapRef = useRef(null);
  const tappedMarkerRef = useRef(null);

  const { layers, activeBasemap } = useLayers();
  const { selectFeature, mapViewState, selectedFeature } = useSelection();
  const { selectedState, selectedDistrict, selectedSubdivision } = useRegion();
  const [mapLoaded, setMapLoaded] = useState(false);

  const selectFeatureRef = useRef(selectFeature);
  useEffect(() => {
    selectFeatureRef.current = selectFeature;
  }, [selectFeature]);

  const prevDistrictIdRef = useRef(selectedDistrict?.id);
  const prevSubdivisionIdRef = useRef(selectedSubdivision?.id);
  const prevStateIdRef = useRef(selectedState?.id);

  // Method to render / update marker at given coordinates
  const showPinOnMap = useCallback((map, coordinates, data) => {
    if (!map || !coordinates || coordinates.length !== 2) return;

    // Clean up existing marker
    if (tappedMarkerRef.current) {
      tappedMarkerRef.current.remove();
      tappedMarkerRef.current = null;
    }

    // Add glowing animated target pin marker
    const markerEl = createMarkerElement(data.severity || data.risk_level);
    const marker = new maplibregl.Marker({
      element: markerEl,
      anchor: 'bottom'
    })
      .setLngLat(coordinates)
      .addTo(map);

    tappedMarkerRef.current = marker;
  }, []);

  // Setup GeoJSON Sources, Layers, and Unified Tap/Click Listener
  const setupSourcesAndLayers = useCallback((map) => {
    if (!map) return;

    // 1. RISK ZONES POLYGON LAYER
    if (!map.getSource('source-risk-zones')) {
      map.addSource('source-risk-zones', {
        type: 'geojson',
        data: RISK_ZONES_GEOJSON
      });

      map.addLayer({
        id: 'layer-risk-zones-fill',
        type: 'fill',
        source: 'source-risk-zones',
        paint: {
          'fill-color': [
            'match',
            ['get', 'risk_level'],
            'CRITICAL', '#C62828',
            'HIGH', '#EF6C00',
            'MODERATE', '#F9A825',
            'LOW', '#2E7D32',
            '#64748B'
          ],
          'fill-opacity': 0.45
        }
      });

      map.addLayer({
        id: 'layer-risk-zones-line',
        type: 'line',
        source: 'source-risk-zones',
        paint: {
          'line-color': [
            'match',
            ['get', 'risk_level'],
            'CRITICAL', '#C62828',
            'HIGH', '#EF6C00',
            'MODERATE', '#F9A825',
            'LOW', '#2E7D32',
            '#64748B'
          ],
          'line-width': 2
        }
      });

      map.on('mouseenter', 'layer-risk-zones-fill', () => { map.getCanvas().style.cursor = 'pointer'; });
      map.on('mouseleave', 'layer-risk-zones-fill', () => { map.getCanvas().style.cursor = 'crosshair'; });
    }

    // 2. ROAD NETWORK LINE LAYER
    if (!map.getSource('source-roads')) {
      map.addSource('source-roads', {
        type: 'geojson',
        data: ROAD_NETWORK_GEOJSON
      });

      map.addLayer({
        id: 'layer-roads-line',
        type: 'line',
        source: 'source-roads',
        paint: {
          'line-color': [
            'match',
            ['get', 'hazard_level'],
            'CRITICAL', '#C62828',
            'HIGH', '#EF6C00',
            'MODERATE', '#1F4E79',
            '#475569'
          ],
          'line-width': 4,
          'line-opacity': 0.85
        }
      });

      map.on('mouseenter', 'layer-roads-line', () => { map.getCanvas().style.cursor = 'pointer'; });
      map.on('mouseleave', 'layer-roads-line', () => { map.getCanvas().style.cursor = 'crosshair'; });
    }

    // 3. VILLAGES LAYER
    if (!map.getSource('source-villages')) {
      map.addSource('source-villages', {
        type: 'geojson',
        data: VILLAGES_GEOJSON
      });

      map.addLayer({
        id: 'layer-villages-circle',
        type: 'circle',
        source: 'source-villages',
        paint: {
          'circle-radius': 5,
          'circle-color': '#475569',
          'circle-stroke-color': '#FFFFFF',
          'circle-stroke-width': 1.5
        }
      });

      map.on('mouseenter', 'layer-villages-circle', () => { map.getCanvas().style.cursor = 'pointer'; });
      map.on('mouseleave', 'layer-villages-circle', () => { map.getCanvas().style.cursor = 'crosshair'; });
    }

    // 4. CRITICAL INFRASTRUCTURE LAYER
    if (!map.getSource('source-infra')) {
      map.addSource('source-infra', {
        type: 'geojson',
        data: CRITICAL_INFRASTRUCTURE_GEOJSON
      });

      map.addLayer({
        id: 'layer-infra-circle',
        type: 'circle',
        source: 'source-infra',
        paint: {
          'circle-radius': 8,
          'circle-color': '#7C3AED',
          'circle-stroke-color': '#FFFFFF',
          'circle-stroke-width': 2
        }
      });

      map.on('mouseenter', 'layer-infra-circle', () => { map.getCanvas().style.cursor = 'pointer'; });
      map.on('mouseleave', 'layer-infra-circle', () => { map.getCanvas().style.cursor = 'crosshair'; });
    }

    // 5. ACTIVE WARNINGS MARKER LAYER
    if (!map.getSource('source-alerts')) {
      const alertsGeoJSON = {
        type: 'FeatureCollection',
        features: MOCK_ALERTS.map(alert => ({
          type: 'Feature',
          geometry: { type: 'Point', coordinates: alert.coordinates },
          properties: alert
        }))
      };

      map.addSource('source-alerts', {
        type: 'geojson',
        data: alertsGeoJSON
      });

      map.addLayer({
        id: 'layer-active-alerts-circle',
        type: 'circle',
        source: 'source-alerts',
        paint: {
          'circle-radius': 11,
          'circle-color': [
            'match',
            ['get', 'severity'],
            'CRITICAL', '#C62828',
            'WARNING', '#EF6C00',
            'WATCH', '#F9A825',
            'NORMAL', '#2E7D32',
            '#2E7D32'
          ],
          'circle-stroke-color': '#FFFFFF',
          'circle-stroke-width': 3
        }
      });

      map.on('mouseenter', 'layer-active-alerts-circle', () => { map.getCanvas().style.cursor = 'pointer'; });
      map.on('mouseleave', 'layer-active-alerts-circle', () => { map.getCanvas().style.cursor = 'crosshair'; });
    }

    // 6. CITIZEN REPORTS LAYER (unverified)
    if (!map.getSource('source-citizen-reports')) {
      map.addSource('source-citizen-reports', {
        type: 'geojson',
        data: CITIZEN_REPORTS_GEOJSON
      });

      map.addLayer({
        id: 'layer-citizen-reports-circle',
        type: 'circle',
        source: 'source-citizen-reports',
        paint: {
          'circle-radius': 7,
          'circle-color': '#EF6C00',
          'circle-stroke-color': '#FFFFFF',
          'circle-stroke-width': 2
        }
      });

      map.on('mouseenter', 'layer-citizen-reports-circle', () => { map.getCanvas().style.cursor = 'pointer'; });
      map.on('mouseleave', 'layer-citizen-reports-circle', () => { map.getCanvas().style.cursor = 'crosshair'; });
    }

    // 7. VERIFIED REPORTS LAYER
    if (!map.getSource('source-verified-reports')) {
      map.addSource('source-verified-reports', {
        type: 'geojson',
        data: VERIFIED_REPORTS_GEOJSON
      });

      map.addLayer({
        id: 'layer-verified-reports-circle',
        type: 'circle',
        source: 'source-verified-reports',
        paint: {
          'circle-radius': 7,
          'circle-color': '#2E7D32',
          'circle-stroke-color': '#FFFFFF',
          'circle-stroke-width': 2
        }
      });

      map.on('mouseenter', 'layer-verified-reports-circle', () => { map.getCanvas().style.cursor = 'pointer'; });
      map.on('mouseleave', 'layer-verified-reports-circle', () => { map.getCanvas().style.cursor = 'crosshair'; });
    }

    // 8. UNIVERSAL TAP / CLICK LISTENER ON THE MAP
    // Captures exact coordinates anywhere clicked and shows comprehensive risk assessment
    map.off('click'); // Remove any prior click listeners to prevent duplicates
    map.on('click', (e) => {
      const lng = e.lngLat.lng;
      const lat = e.lngLat.lat;

      const interactiveLayers = [
        'layer-active-alerts-circle',
        'layer-citizen-reports-circle',
        'layer-verified-reports-circle',
        'layer-risk-zones-fill',
        'layer-roads-line',
        'layer-villages-circle',
        'layer-infra-circle'
      ].filter(id => map.getLayer(id));

      const features = map.queryRenderedFeatures(e.point, { layers: interactiveLayers });

      let featurePayload = null;

      if (features && features.length > 0) {
        const topFeature = features[0];
        const props = topFeature.properties || {};

        if (topFeature.layer.id === 'layer-active-alerts-circle') {
          featurePayload = {
            ...props,
            type: 'ALERT',
            coordinates: [lng, lat]
          };
        } else if (topFeature.layer.id === 'layer-risk-zones-fill') {
          featurePayload = {
            type: 'RISK_ZONE',
            id: props.zone_id || 'zone-1',
            title: `Landslide Risk Zone — ${props.name || 'Sector'}`,
            severity: props.risk_level || 'CRITICAL',
            priority: props.risk_level === 'CRITICAL' ? 'P1' : 'P2',
            coordinates: [lng, lat],
            latitude: lat,
            longitude: lng,
            location_name: props.district ? `${props.name || 'Sector'}, ${props.district}` : (props.name || 'Sector'),
            risk_score: props.risk_score || 0.88,
            confidence: props.confidence || 0.92,
            rainfall_24h: props.rainfall_24h_mm || 142.0,
            soil_saturation: props.soil_moisture_pct || 84.0,
            slope_deg: props.slope_deg || 42.0,
            sar_displacement_mm_yr: props.sar_shift_mm_yr || -16.0,
            affected_infrastructure: [props.nearest_road || 'Trans-Arunachal Highway', props.nearest_settlement || 'Local Settlement'],
            recommended_action: props.risk_level === 'CRITICAL'
              ? 'Deploy emergency monitoring team and inspect downslope cuts.'
              : 'Slope watch active. Monitor radar telemetry.',
            status: 'ACTIVE'
          };
        } else if (topFeature.layer.id === 'layer-roads-line') {
          featurePayload = {
            type: 'ROAD_NETWORK',
            id: props.road_id || 'road-1',
            title: props.name || 'Highway Corridor',
            severity: props.hazard_level || 'HIGH',
            priority: props.hazard_level === 'CRITICAL' ? 'P1' : 'P2',
            coordinates: [lng, lat],
            latitude: lat,
            longitude: lng,
            location_name: `${props.name} (${props.district || 'Papum Pare'})`,
            risk_score: props.hazard_level === 'CRITICAL' ? 0.90 : 0.74,
            confidence: 0.89,
            rainfall_24h: 110.0,
            soil_saturation: 76.0,
            slope_deg: 35.0,
            sar_displacement_mm_yr: -12.4,
            affected_infrastructure: [props.name, props.vulnerable_choke_points || 'Active slope choke points'],
            recommended_action: props.status || 'Active traffic advisory. Road clearance teams on alert.',
            status: props.status || 'WATCH'
          };
        } else if (topFeature.layer.id === 'layer-villages-circle') {
          featurePayload = {
            type: 'VILLAGE',
            id: props.infra_id || 'vil-1',
            title: `Village Habitation — ${props.name}`,
            severity: props.risk_exposure || 'MODERATE',
            priority: props.risk_exposure === 'CRITICAL' ? 'P1' : 'P2',
            coordinates: [lng, lat],
            latitude: lat,
            longitude: lng,
            location_name: `${props.name}, ${props.district}`,
            risk_score: props.risk_exposure === 'CRITICAL' ? 0.86 : 0.62,
            confidence: 0.90,
            rainfall_24h: 95.0,
            soil_saturation: 70.0,
            slope_deg: 28.0,
            affected_infrastructure: [`Habitation Population: ${props.population || '—'}`, props.nearest_road || 'Local Access Corridor'],
            recommended_action: `Monitor village perimeter. Community early warning alert: ${props.risk_exposure || 'MODERATE'}.`,
            status: 'HABITATION'
          };
        } else if (topFeature.layer.id === 'layer-infra-circle') {
          featurePayload = {
            type: 'INFRASTRUCTURE',
            id: props.infra_id || 'infra-1',
            title: props.name || 'Critical Facility',
            severity: props.risk_exposure || 'HIGH',
            priority: 'P2',
            coordinates: [lng, lat],
            latitude: lat,
            longitude: lng,
            location_name: `${props.name}, ${props.district}`,
            risk_score: 0.76,
            confidence: 0.91,
            rainfall_24h: 105.0,
            soil_saturation: 74.0,
            slope_deg: 30.0,
            affected_infrastructure: [props.name, props.category || 'Strategic Asset'],
            recommended_action: 'Perform structural integrity inspection and check foundation drainage.',
            status: 'STRATEGIC'
          };
        } else if (topFeature.layer.id === 'layer-citizen-reports-circle') {
          let parsedMedia = props.media;
          if (typeof parsedMedia === 'string') {
            try { parsedMedia = JSON.parse(parsedMedia); } catch {}
          }
          let parsedChecklist = props.checklist;
          if (typeof parsedChecklist === 'string') {
            try { parsedChecklist = JSON.parse(parsedChecklist); } catch {}
          }

          featurePayload = {
            type: 'CITIZEN_REPORT',
            id: props.id,
            title: props.description || `Citizen Report — ${props.location_name || 'Sector'}`,
            severity: props.severity || 'MODERATE',
            priority: props.severity === 'CRITICAL' ? 'P1' : 'P3',
            coordinates: [lng, lat],
            latitude: lat,
            longitude: lng,
            location_name: props.location_name || 'Papum Pare',
            risk_score: 0.65,
            confidence: 0.72,
            rainfall_24h: 95.0,
            soil_saturation: 68.0,
            slope_deg: 32.0,
            affected_infrastructure: [props.description || 'Reported via mobile app'],
            recommended_action: 'Dispatch field officer for ground verification.',
            status: props.verification_status || 'UNVERIFIED',
            verification_status: props.verification_status || 'UNVERIFIED',
            media: parsedMedia || [],
            photo_count: props.photo_count || (parsedMedia?.filter(m => m.type === 'photo')?.length || 0),
            video_count: props.video_count || (parsedMedia?.filter(m => m.type === 'video')?.length || 0),
            reporter_name: props.reporter_name || 'Citizen User',
            reporter_type: props.reporter_type || 'CITIZEN',
            reported_at: props.reported_at || props.created_at,
            description: props.description,
            checklist: parsedChecklist || [],
            verified_by: props.verified_by,
            verified_at: props.verified_at,
            verification_notes: props.verification_notes
          };
        } else if (topFeature.layer.id === 'layer-verified-reports-circle') {
          let parsedMedia = props.media;
          if (typeof parsedMedia === 'string') {
            try { parsedMedia = JSON.parse(parsedMedia); } catch {}
          }
          let parsedChecklist = props.checklist;
          if (typeof parsedChecklist === 'string') {
            try { parsedChecklist = JSON.parse(parsedChecklist); } catch {}
          }

          featurePayload = {
            type: 'VERIFIED_REPORT',
            id: props.id,
            title: props.description || `Verified Report — ${props.location_name || 'Sector'}`,
            severity: props.severity || 'MODERATE',
            priority: props.severity === 'CRITICAL' ? 'P1' : 'P2',
            coordinates: [lng, lat],
            latitude: lat,
            longitude: lng,
            location_name: props.location_name || 'Papum Pare',
            risk_score: 0.80,
            confidence: 0.90,
            rainfall_24h: 120.0,
            soil_saturation: 78.0,
            slope_deg: 36.0,
            affected_infrastructure: [props.description || 'Ground-verified by DDMO'],
            recommended_action: 'Continue monitoring. Report verified by field team.',
            status: 'VERIFIED',
            verification_status: 'VERIFIED',
            media: parsedMedia || [],
            photo_count: props.photo_count || (parsedMedia?.filter(m => m.type === 'photo')?.length || 0),
            video_count: props.video_count || (parsedMedia?.filter(m => m.type === 'video')?.length || 0),
            reporter_name: props.reporter_name || 'Field Officer',
            reporter_type: props.reporter_type || 'FIELD_OFFICER',
            reported_at: props.reported_at || props.created_at,
            description: props.description,
            checklist: parsedChecklist || [],
            verified_by: props.verified_by || 'DDMO Ground Cell',
            verified_at: props.verified_at,
            verification_notes: props.verification_notes
          };
        }
      }

      // If no interactive layer feature was clicked, evaluate exact tapped coordinates
      if (!featurePayload) {
        const spatialEval = riskService.evaluatePointRisk(lat, lng);
        featurePayload = {
          type: 'TAPPED_LOCATION',
          id: `LOC-${lat.toFixed(4)}-${lng.toFixed(4)}`,
          title: `Tapped Location Assessment`,
          severity: spatialEval.risk_level,
          priority: spatialEval.risk_level === 'CRITICAL' ? 'P1' : (spatialEval.risk_level === 'HIGH' ? 'P2' : 'P3'),
          coordinates: [lng, lat],
          latitude: lat,
          longitude: lng,
          location_name: spatialEval.location_name,
          district: spatialEval.district,
          state: spatialEval.state,
          risk_score: spatialEval.risk_score,
          confidence: spatialEval.confidence,
          model_version: spatialEval.model_version,
          rainfall_24h: spatialEval.rainfall_24h,
          soil_saturation: spatialEval.soil_saturation,
          slope_deg: spatialEval.slope_deg,
          sar_displacement_mm_yr: spatialEval.sar_displacement_mm_yr,
          nearest_road: spatialEval.nearest_road,
          nearest_settlement: spatialEval.nearest_settlement,
          distance_to_road_km: spatialEval.distance_to_road_km,
          distance_to_settlement_km: spatialEval.distance_to_settlement_km,
          affected_infrastructure: spatialEval.affected_infrastructure,
          recommended_action: spatialEval.recommended_action,
          status: spatialEval.status,
          timestamp: spatialEval.timestamp
        };
      }

      // Render pulsing marker on map
      showPinOnMap(map, [lng, lat], featurePayload);

      // Select feature so LocationDetailsPanel slides open with full data
      selectFeatureRef.current(featurePayload);
    });

    // Set default canvas crosshair cursor to indicate tap-to-inspect capability
    map.getCanvas().style.cursor = 'crosshair';

    // Dynamic Live Data Sync (Async)
    (async () => {
      try {
        const [liveRoads, liveInfra, liveVillages, liveAlerts, liveReports, liveGeoReports] = await Promise.allSettled([
          infrastructureService.getRoadNetwork(),
          infrastructureService.getFacilities(),
          infrastructureService.getVillages(),
          alertService.getActiveAlerts(),
          reportService.getReports(),
          reportService.getReportsGeoJSON(),
        ]);

        if (mapRef.current && map.isStyleLoaded()) {
          const roads = liveRoads.status === 'fulfilled' ? liveRoads.value?.data : null;
          const infra = liveInfra.status === 'fulfilled' ? liveInfra.value?.data : null;
          const villages = liveVillages.status === 'fulfilled' ? liveVillages.value?.data : null;
          const alerts = liveAlerts.status === 'fulfilled' ? liveAlerts.value?.data : null;
          const reports = liveReports.status === 'fulfilled' ? liveReports.value?.data : null;
          const geoReports = liveGeoReports.status === 'fulfilled' ? liveGeoReports.value?.data : null;

          if (roads && map.getSource('source-roads')) {
            map.getSource('source-roads').setData(roads);
          }
          if (infra && map.getSource('source-infra')) {
            map.getSource('source-infra').setData(infra);
          }
          if (villages && map.getSource('source-villages')) {
            map.getSource('source-villages').setData(villages);
          }
          if (Array.isArray(alerts) && map.getSource('source-alerts')) {
            map.getSource('source-alerts').setData({
              type: 'FeatureCollection',
              features: alerts.map(alert => ({
                type: 'Feature',
                geometry: { type: 'Point', coordinates: alert.coordinates },
                properties: alert
              }))
            });
          }
          if (geoReports?.features?.length > 0) {
            if (map.getSource('source-citizen-reports')) {
              map.getSource('source-citizen-reports').setData(geoReports);
            }
          } else if (Array.isArray(reports)) {
            const citizenFeatures = reports
              .filter(r => r.verification_status !== 'VERIFIED')
              .map(r => ({
                type: 'Feature',
                id: r.id,
                geometry: { type: 'Point', coordinates: r.coordinates },
                properties: r
              }));
            const verifiedFeatures = reports
              .filter(r => r.verification_status === 'VERIFIED')
              .map(r => ({
                type: 'Feature',
                id: r.id,
                geometry: { type: 'Point', coordinates: r.coordinates },
                properties: r
              }));

            if (map.getSource('source-citizen-reports')) {
              map.getSource('source-citizen-reports').setData({
                type: 'FeatureCollection',
                features: citizenFeatures
              });
            }
            if (map.getSource('source-verified-reports')) {
              map.getSource('source-verified-reports').setData({
                type: 'FeatureCollection',
                features: verifiedFeatures
              });
            }
          }
        }
      } catch (err) {
        console.warn('[MapLibreViewer] Live layer sync fallback:', err);
      }
    })();
  }, [showPinOnMap]);

  // Initialize MapLibre GL instance
  useEffect(() => {
    if (!mapContainerRef.current) return;

    const initialCenter = mapViewState?.center || selectedDistrict?.center || selectedState?.center || [93.6166, 27.1000];
    const initialZoom = mapViewState?.zoom || selectedDistrict?.defaultZoom || selectedState?.defaultZoom || 8.2;

    const map = new maplibregl.Map({
      container: mapContainerRef.current,
      style: BASEMAP_STYLES[activeBasemap] || BASEMAP_STYLES['osm-standard'],
      center: initialCenter,
      zoom: initialZoom,
      pitch: 10,
      attributionControl: true
    });

    mapRef.current = map;

    map.on('load', () => {
      setMapLoaded(true);
      setupSourcesAndLayers(map);
    });

    return () => {
      if (tappedMarkerRef.current) {
        tappedMarkerRef.current.remove();
        tappedMarkerRef.current = null;
      }
      map.remove();
      mapRef.current = null;
    };
  }, [setupSourcesAndLayers]); // eslint-disable-line react-hooks/exhaustive-deps

  // Respond to SelectionContext mapViewState flyTo requests (e.g., clicking View on Map from Alerts / Reports)
  useEffect(() => {
    if (mapRef.current && mapLoaded && mapViewState?.center) {
      mapRef.current.flyTo({
        center: mapViewState.center,
        zoom: mapViewState.zoom || 13,
        essential: true,
        duration: 1000
      });
    }
  }, [mapViewState, mapLoaded]);

  // Sync marker with selectedFeature when changed externally or cleared
  useEffect(() => {
    if (!mapRef.current || !mapLoaded) return;
    const map = mapRef.current;

    if (!selectedFeature) {
      if (tappedMarkerRef.current) {
        tappedMarkerRef.current.remove();
        tappedMarkerRef.current = null;
      }
      return;
    }

    const coords = selectedFeature.coordinates || (
      selectedFeature.longitude !== undefined && selectedFeature.latitude !== undefined
        ? [selectedFeature.longitude, selectedFeature.latitude]
        : null
    );

    if (coords && coords.length === 2) {
      const currentLngLat = tappedMarkerRef.current?.getLngLat();
      const isSameLocation = currentLngLat &&
        Math.abs(currentLngLat.lng - coords[0]) < 0.0001 &&
        Math.abs(currentLngLat.lat - coords[1]) < 0.0001;

      if (!isSameLocation) {
        showPinOnMap(map, coords, selectedFeature);
      }
    }
  }, [selectedFeature, mapLoaded, showPinOnMap]);

  // Respond ONLY when District / Subdivision / State dropdown selection actually changes in Header
  useEffect(() => {
    if (!mapRef.current || !mapLoaded) return;

    const districtChanged = prevDistrictIdRef.current !== selectedDistrict?.id;
    const subdivisionChanged = prevSubdivisionIdRef.current !== selectedSubdivision?.id;
    const stateChanged = prevStateIdRef.current !== selectedState?.id;

    prevDistrictIdRef.current = selectedDistrict?.id;
    prevSubdivisionIdRef.current = selectedSubdivision?.id;
    prevStateIdRef.current = selectedState?.id;

    if (subdivisionChanged && selectedSubdivision?.center) {
      mapRef.current.flyTo({
        center: selectedSubdivision.center,
        zoom: 12.5,
        essential: true,
        duration: 1200
      });
    } else if (districtChanged && selectedDistrict?.center) {
      mapRef.current.flyTo({
        center: selectedDistrict.center,
        zoom: selectedDistrict.defaultZoom || 10.5,
        essential: true,
        duration: 1200
      });
    } else if (stateChanged && selectedState?.center) {
      mapRef.current.flyTo({
        center: selectedState.center,
        zoom: selectedState.defaultZoom || 8.2,
        essential: true,
        duration: 1200
      });
    }
  }, [selectedDistrict, selectedSubdivision, selectedState, mapLoaded]);

  // Update basemap style if switched by user
  useEffect(() => {
    if (mapRef.current && mapLoaded) {
      const style = BASEMAP_STYLES[activeBasemap] || BASEMAP_STYLES['osm-standard'];
      mapRef.current.setStyle(style);
      mapRef.current.once('style.load', () => {
        setupSourcesAndLayers(mapRef.current);
      });
    }
  }, [activeBasemap, mapLoaded, setupSourcesAndLayers]);

  // Handle layer toggling from LayerContext
  useEffect(() => {
    if (!mapRef.current || !mapLoaded) return;
    const map = mapRef.current;

    const layerMap = {
      riskZones: ['layer-risk-zones-fill', 'layer-risk-zones-line'],
      roadNetwork: ['layer-roads-line'],
      infrastructure: ['layer-infra-circle'],
      villages: ['layer-villages-circle'],
      activeWarnings: ['layer-active-alerts-circle'],
      fieldReports: ['layer-citizen-reports-circle', 'layer-verified-reports-circle']
    };

    Object.entries(layerMap).forEach(([key, ids]) => {
      const isVisible = layers[key] !== false;
      ids.forEach(id => {
        if (map.getLayer(id)) {
          map.setLayoutProperty(id, 'visibility', isVisible ? 'visible' : 'none');
        }
      });
    });
  }, [layers, mapLoaded]);

  const zoomIn = () => mapRef.current?.zoomIn();
  const zoomOut = () => mapRef.current?.zoomOut();
  const resetView = () => {
    if (selectedDistrict?.center) {
      mapRef.current?.flyTo({ center: selectedDistrict.center, zoom: selectedDistrict.defaultZoom || 10.5, duration: 1000 });
    } else {
      mapRef.current?.flyTo({ center: [93.6166, 27.1000], zoom: 8.2, duration: 1000 });
    }
  };

  return (
    <div id="gis-map-viewport" className="relative w-full h-full bg-slate-100 overflow-hidden">
      {/* MapLibre DOM Target */}
      <div ref={mapContainerRef} className="w-full h-full" />

      {/* Active Basemap Badge */}
      <div className="absolute top-3 right-3 z-10 bg-white/90 backdrop-blur-md border border-slate-200/90 text-slate-700 text-[11px] font-medium px-2.5 py-1 rounded-full shadow-xs flex items-center gap-1.5 pointer-events-none select-none">
        <span className="w-1.5 h-1.5 rounded-full bg-sky-500"></span>
        <span>
          {activeBasemap === 'osm-standard' ? 'OSM Standard' :
            activeBasemap === 'osm-topo' ? 'OpenTopoMap Terrain' :
              activeBasemap === 'osm-satellite' ? 'Esri Satellite' :
                activeBasemap === 'osm-dark' ? 'Carto Dark' : 'Carto Light'}
        </span>
      </div>

      {/* Floating Controls (Top Right) */}
      <div className="absolute top-11 right-3 z-20">
        <MapControls onZoomIn={zoomIn} onZoomOut={zoomOut} onResetView={resetView} />
      </div>

      {/* Floating Legend (Bottom Left) */}
      <div className="absolute bottom-3 left-3 z-20">
        <MapLegend />
      </div>

      {/* Tap Coordinates & Risk Instruction Pill (Bottom Center) */}
      <div className="absolute bottom-3 left-1/2 -translate-x-1/2 z-20 pointer-events-none bg-slate-900/85 backdrop-blur-md text-white border border-slate-700/60 px-3 py-1 rounded-full text-[11px] font-medium shadow-md flex items-center gap-2 select-none">
        <span className="w-2 h-2 rounded-full bg-sky-400 animate-pulse"></span>
        <span>Tap anywhere on map for exact coordinates & risk analysis</span>
      </div>

      {/* Location Detail Panel Overlay (Top Right / Sliding) */}
      <div className="absolute top-3 right-16 z-30">
        <LocationDetailsPanel />
      </div>
    </div>
  );
}
