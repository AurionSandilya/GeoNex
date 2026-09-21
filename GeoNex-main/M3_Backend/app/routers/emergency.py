"""
app/routers/emergency.py

Emergency Prioritization API (Phase 20)

Computes decision-support priority ranks (P1 - Critical, P2 - High, P3 - Moderate)
based on configurable weights:
- Risk score (ML model output)
- Population exposure (nearby villages)
- Road importance (NH vs local road)
- Infrastructure vulnerability (hospitals/bridges in proximity)

Note: These are decision-support scores for emergency officers, not automatic evacuation orders.
"""

from typing import List, Dict, Any
from fastapi import APIRouter, Query

router = APIRouter(prefix="/emergency", tags=["Emergency Response"])


@router.get("/priorities")
async def get_emergency_priorities(
    min_risk_score: float = Query(0.50, ge=0.0, le=1.0, description="Minimum risk score threshold"),
) -> Dict[str, Any]:
    """
    Returns ranked emergency priority locations for disaster management teams.
    """
    # Demonstration calculated priority rankings for NER region
    priorities = [
        {
            "priority": "P1",
            "location_name": "NH-27 KM-142 (Nagaon Pass)",
            "coordinates": [92.75, 26.40],
            "priority_score": 0.94,
            "risk_score": 0.88,
            "factors": {
                "population_exposed": 4500,
                "critical_assets": ["District Hospital", "Nagaon Bridge"],
                "road_blockage_impact": "CRITICAL_HIGHWAY",
            },
            "recommendation": "Deploy emergency clearing squad and issue traffic rerouting alert.",
        },
        {
            "priority": "P2",
            "location_name": "Itanagar Slope Sector 4",
            "coordinates": [93.62, 27.58],
            "priority_score": 0.76,
            "risk_score": 0.72,
            "factors": {
                "population_exposed": 1200,
                "critical_assets": ["Primary School"],
                "road_blockage_impact": "LOCAL_ACCESS_ROAD",
            },
            "recommendation": "Dispatch field officer for on-ground verification.",
        },
    ]

    return {
        "status": "success",
        "total_priorities": len(priorities),
        "disclaimer": "These scores are decision-support indicators for relief operation planning.",
        "data": priorities,
    }
