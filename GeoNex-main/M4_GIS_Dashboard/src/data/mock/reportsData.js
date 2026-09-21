/**
 * Citizen & Field Verification Reports Data for Arunachal Pradesh
 * Includes rich photographic evidence and inspection video footage
 * from both Citizen mobile app uploads and Official Field Verification teams.
 */

export const INITIAL_REPORTS = [
  {
    id: "REP-2026-092",
    location_name: "Sela Tunnel Approach Road km 136",
    district: "Tawang",
    coordinates: [92.1050, 27.5020],
    reported_at: "2026-09-09T18:10:00Z",
    reporter_type: "FIELD_OFFICER",
    reporter_name: "BRO Detachment Supervisor C. Sharma",
    severity: "CRITICAL",
    verification_status: "VERIFIED",
    verified_by: "DDMO Tawang & BRO Cell (Major K. Rathore)",
    verified_at: "2026-09-09T18:30:00Z",
    description: "Active rock fragments rolling down upper cliff onto Tawang arterial highway. Slope toe destabilized after torrential rainfall.",
    current_risk: "CRITICAL",
    media_available: true,
    photo_caption: "Debris blockage near Sela portal and high-angle slope fracture",
    photo_count: 2,
    video_count: 1,
    status: "ACTION_REQUIRED",
    verification_notes: "Ground inspection confirmed active tension crack propagating 45m along cliff face. Traffic redirected via Balipara-Charduar diversion.",
    checklist: [
      { label: "Road Carriageway Obstructed", status: "YES" },
      { label: "Active Rockfall Detected", status: "YES" },
      { label: "InSAR Displacement Correlation", status: "CONFIRMED (-18.4 mm/yr)" },
      { label: "Heavy Earthmoving Machinery Dispatched", status: "DEPLOYED" }
    ],
    media: [
      {
        id: "MED-092-P1",
        type: "photo",
        title: "Upper Ridge Rock Fracture & Debris Toe",
        caption: "Rock mass detachment with boulders spilling across 12m of northern carriageway.",
        url: "https://images.unsplash.com/photo-1547683905-f686c993aae5?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1547683905-f686c993aae5?auto=format&fit=crop&w=400&q=75",
        source: "FIELD_VERIFICATION",
        source_label: "Field Inspection Team (BRO 42 BRTF)",
        captured_at: "2026-09-09T18:22:00Z",
        device: "Nikon D780 Geotagged • 24-70mm",
        coordinates: [92.1050, 27.5020],
        resolution: "24.5 MP (6048x4024)",
        file_size: "6.4 MB"
      },
      {
        id: "MED-092-V1",
        type: "video",
        title: "Aerial Drone Scan — Sela Approach Ridge",
        caption: "UAV reconnaissance recording slope scarp destabilization and rolling scree trajectory.",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        thumbnail: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=75",
        source: "FIELD_VERIFICATION",
        source_label: "BRO Aerial Survey Drone (DJI Matrice 300 RTK)",
        captured_at: "2026-09-09T18:26:00Z",
        device: "Zenmuse H20T Thermal/RGB Sensor",
        coordinates: [92.1052, 27.5023],
        duration: "0:45",
        resolution: "4K UHD (3840x2160 @ 30fps)",
        file_size: "38.2 MB"
      },
      {
        id: "MED-092-P2",
        type: "photo",
        title: "Tension Crack on Highway Embankment",
        caption: "35mm asphalt fissure widening near drainage culvert outlet 200m ahead of tunnel mouth.",
        url: "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=400&q=75",
        source: "FIELD_VERIFICATION",
        source_label: "BRO Geotechnical Engineer",
        captured_at: "2026-09-09T18:28:00Z",
        device: "Geotechnical Crack Scope & Fluke Imager",
        coordinates: [92.1048, 27.5018],
        resolution: "16 MP (4608x3456)",
        file_size: "4.1 MB"
      }
    ]
  },
  {
    id: "REP-2026-089",
    location_name: "Sagalee Trans-Arunachal Highway km 43",
    district: "Papum Pare",
    coordinates: [93.4285, 27.2380],
    reported_at: "2026-09-09T16:45:00Z",
    reporter_type: "CITIZEN",
    reporter_name: "Taba Taku (Local Commuter)",
    severity: "CRITICAL",
    verification_status: "VERIFIED",
    verified_by: "DDMO Papum Pare (Yupia HQ - Officer M. Dolo)",
    verified_at: "2026-09-09T17:15:00Z",
    description: "Major soil collapse and tree debris fall blocking both lanes near Pare bridge bypass.",
    current_risk: "CRITICAL",
    media_available: true,
    photo_caption: "Debris blockage across two-lane highway carriageway",
    photo_count: 2,
    video_count: 1,
    status: "ACTION_REQUIRED",
    verification_notes: "Dispatched PWD Sagalee rapid response division. Excavators active on site. Citizen photo verified by field inspection officer.",
    checklist: [
      { label: "Both Highway Lanes Blocked", status: "YES" },
      { label: "Electricity / Utility Cables Snapped", status: "YES" },
      { label: "Emergency Ambulance Escort Organized", status: "ACTIVE" },
      { label: "Estimated Clearance Time", status: "2.5 Hours" }
    ],
    media: [
      {
        id: "MED-089-P1",
        type: "photo",
        title: "Citizen Ground Capture — Mud & Uprooted Trees",
        caption: "Slope mudslide overwhelmed downhill retaining wall, stranding 8 commercial vehicles.",
        url: "https://images.unsplash.com/photo-1542332213-31f87348057f?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1542332213-31f87348057f?auto=format&fit=crop&w=400&q=75",
        source: "CITIZEN_UPLOAD",
        source_label: "Citizen Mobile App Upload (Taba Taku)",
        captured_at: "2026-09-09T16:43:00Z",
        device: "Xiaomi Redmi Note 12 Pro • GPS Active (±4m)",
        coordinates: [93.4285, 27.2380],
        resolution: "12 MP (4000x3000)",
        file_size: "3.2 MB"
      },
      {
        id: "MED-089-V1",
        type: "video",
        title: "Citizen Video — Active Mud Slurry Inflow",
        caption: "Video recording continuous mud slurry pouring off the road cutting edge following storm.",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        thumbnail: "https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=600&q=75",
        source: "CITIZEN_UPLOAD",
        source_label: "Citizen Live Clip (App Ingestion)",
        captured_at: "2026-09-09T16:44:00Z",
        device: "Smartphone Video • Geotagged",
        coordinates: [93.4286, 27.2381],
        duration: "0:30",
        resolution: "1080p (1920x1080 @ 30fps)",
        file_size: "18.5 MB"
      },
      {
        id: "MED-089-P2",
        type: "photo",
        title: "Field Officer Inspection — PWD Earthmover Clearance",
        caption: "Verification team confirming JCB earthmover clearing root balls and saturated silt.",
        url: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=75",
        source: "FIELD_VERIFICATION",
        source_label: "PWD Highway Verification Officer (M. Dolo)",
        captured_at: "2026-09-09T17:12:00Z",
        device: "Official Tablet Samsung Tab Active 4 Pro",
        coordinates: [93.4284, 27.2378],
        resolution: "13 MP (4128x3096)",
        file_size: "3.9 MB"
      }
    ]
  },
  {
    id: "REP-2026-091",
    location_name: "Hunli-Anini NH-313 km 162",
    district: "Dibang Valley",
    coordinates: [95.9450, 28.3180],
    reported_at: "2026-09-09T15:50:00Z",
    reporter_type: "CITIZEN",
    reporter_name: "Mipi Gram Burah",
    severity: "HIGH",
    verification_status: "UNVERIFIED",
    verified_by: null,
    verified_at: null,
    description: "Mud slurry accumulation restricting movement to single lane for light motor vehicles. Hill cutting unstable.",
    current_risk: "HIGH",
    media_available: true,
    photo_caption: "Highland mud seepage on road surface",
    photo_count: 1,
    video_count: 1,
    status: "PENDING_VERIFICATION",
    verification_notes: null,
    checklist: [
      { label: "Passable by Heavy Trucks", status: "NO" },
      { label: "Light 4x4 Passage", status: "MARGINAL" },
      { label: "Field Team Dispatched", status: "EN ROUTE (DDMO Anini)" }
    ],
    media: [
      {
        id: "MED-091-P1",
        type: "photo",
        title: "Citizen Slope Photograph — Waterlogging & Silt",
        caption: "Hill cutting runoff depositing 0.4m mud on the river-side road corridor.",
        url: "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=400&q=75",
        source: "CITIZEN_UPLOAD",
        source_label: "Citizen Mobile App (Mipi Gram Burah)",
        captured_at: "2026-09-09T15:48:00Z",
        device: "Vivo Y200 • Geo-stamped",
        coordinates: [95.9450, 28.3180],
        resolution: "12 MP (4000x3000)",
        file_size: "2.8 MB"
      },
      {
        id: "MED-091-V1",
        type: "video",
        title: "Citizen Video — Vehicles Navigating Mud Slip",
        caption: "Citizen video showing local Bolero pickup negotiating muddy slope slip under heavy mist.",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        thumbnail: "https://images.unsplash.com/photo-1542332213-31f87348057f?auto=format&fit=crop&w=600&q=75",
        source: "CITIZEN_UPLOAD",
        source_label: "Citizen Smartphone Clip",
        captured_at: "2026-09-09T15:49:00Z",
        device: "Smartphone Video Cam (720p)",
        coordinates: [95.9451, 28.3182],
        duration: "0:25",
        resolution: "720p (1280x720 @ 30fps)",
        file_size: "12.4 MB"
      }
    ]
  },
  {
    id: "REP-2026-088",
    location_name: "Karsingsa S-Bend NH-415",
    district: "Papum Pare",
    coordinates: [93.7430, 27.1260],
    reported_at: "2026-09-09T15:20:00Z",
    reporter_type: "FIELD_OFFICER",
    reporter_name: "PWD Highway Inspector R. Nabam",
    severity: "HIGH",
    verification_status: "VERIFIED",
    verified_by: "PWD Highway Division II (Er. T. Koyu)",
    verified_at: "2026-09-09T15:50:00Z",
    description: "Fissures observed along outer asphalt slope shoulder following morning heavy rainfall. Continuous creep detected.",
    current_risk: "HIGH",
    media_available: true,
    photo_caption: "Tension cracks along highway embankment edge",
    photo_count: 2,
    video_count: 1,
    status: "UNDER_MONITORING",
    verification_notes: "Geological survey team installed glass tell-tales and strain pegs. Embankment stabilization netting scheduled.",
    checklist: [
      { label: "Shoulder Subsidence", status: "15 cm" },
      { label: "Pre-stressed Gabion Wall", status: "DISTORTION OBSERVED" },
      { label: "Warning Signboards Placed", status: "COMPLETED" }
    ],
    media: [
      {
        id: "MED-088-P1",
        type: "photo",
        title: "Field Geologist Measurement — Shoulder Fissure",
        caption: "Detailed inspection showing tensile shear cracking parallel to asphalt road edge.",
        url: "https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=75",
        source: "FIELD_VERIFICATION",
        source_label: "PWD Highway Inspection Division",
        captured_at: "2026-09-09T15:35:00Z",
        device: "Sony Alpha 6400 (Official Issue)",
        coordinates: [93.7430, 27.1260],
        resolution: "24 MP (6000x4000)",
        file_size: "5.8 MB"
      },
      {
        id: "MED-088-V1",
        type: "video",
        title: "Field Verification Video — S-Bend Creep Zone",
        caption: "Ground officer walkthrough video showing continuous road depression and water piping under culvert.",
        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
        thumbnail: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=600&q=75",
        source: "FIELD_VERIFICATION",
        source_label: "Field Inspection Bodycam (Inspector R. Nabam)",
        captured_at: "2026-09-09T15:40:00Z",
        device: "Axon Body 3 Geotagged Camera",
        coordinates: [93.7432, 27.1262],
        duration: "0:40",
        resolution: "1080p (1920x1080 @ 60fps)",
        file_size: "24.1 MB"
      },
      {
        id: "MED-088-P2",
        type: "photo",
        title: "Gabion Wall Bulging Inspection",
        caption: "Retaining structure wire mesh distortion under lateral soil pressure.",
        url: "https://images.unsplash.com/photo-1547683905-f686c993aae5?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1547683905-f686c993aae5?auto=format&fit=crop&w=400&q=75",
        source: "FIELD_VERIFICATION",
        source_label: "Field Geotechnical Team",
        captured_at: "2026-09-09T15:45:00Z",
        device: "Tablet Field Sensor",
        coordinates: [93.7428, 27.1258],
        resolution: "12 MP (4032x3024)",
        file_size: "3.4 MB"
      }
    ]
  },
  {
    id: "REP-2026-090",
    location_name: "Pasighat Ranaghat Hill Slope Cut",
    district: "East Siang",
    coordinates: [95.3280, 28.0580],
    reported_at: "2026-09-09T13:40:00Z",
    reporter_type: "CITIZEN",
    reporter_name: "Oken Tayeng",
    severity: "MODERATE",
    verification_status: "UNVERIFIED",
    verified_by: null,
    verified_at: null,
    description: "Minor rock tumbling near water pipeline alignment on hillside cut.",
    current_risk: "MODERATE",
    media_available: true,
    photo_caption: "Rock debris beside municipal water main",
    photo_count: 1,
    video_count: 0,
    status: "PENDING_VERIFICATION",
    verification_notes: null,
    checklist: [
      { label: "Municipal Water Pipeline Intact", status: "YES (SURFACE SCRATCHES)" },
      { label: "Immediate Evacuation Required", status: "NO" },
      { label: "Field Verification Officer Assigned", status: "DISPATCHED" }
    ],
    media: [
      {
        id: "MED-090-P1",
        type: "photo",
        title: "Citizen Photo — Loose Rocks along Pipeline Track",
        caption: "Boulders rolled down 8 meters onto the pipeline maintenance path.",
        url: "https://images.unsplash.com/photo-1542332213-31f87348057f?auto=format&fit=crop&w=1400&q=80",
        thumbnail: "https://images.unsplash.com/photo-1542332213-31f87348057f?auto=format&fit=crop&w=400&q=75",
        source: "CITIZEN_UPLOAD",
        source_label: "Citizen Smartphone (Oken Tayeng)",
        captured_at: "2026-09-09T13:38:00Z",
        device: "OnePlus Nord CE 3 • Geo-tagged",
        coordinates: [95.3280, 28.0580],
        resolution: "12 MP (4000x3000)",
        file_size: "3.1 MB"
      }
    ]
  }
];

export const CITIZEN_REPORTS_GEOJSON = {
  type: "FeatureCollection",
  features: INITIAL_REPORTS
    .filter(r => r.verification_status !== 'VERIFIED')
    .map(r => ({
      type: "Feature",
      id: r.id,
      properties: { ...r, layer_type: 'citizen-report' },
      geometry: { type: "Point", coordinates: r.coordinates }
    }))
};

export const VERIFIED_REPORTS_GEOJSON = {
  type: "FeatureCollection",
  features: INITIAL_REPORTS
    .filter(r => r.verification_status === 'VERIFIED')
    .map(r => ({
      type: "Feature",
      id: r.id,
      properties: { ...r, layer_type: 'verified-report' },
      geometry: { type: "Point", coordinates: r.coordinates }
    }))
};
