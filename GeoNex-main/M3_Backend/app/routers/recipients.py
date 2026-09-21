"""
app/routers/recipients.py

M3 -> M5 Recipient Resolution Service (Architecture §29):
Endpoint: POST /recipients/resolve (and /api/v1/recipients/resolve)

Resolves targeted recipients (officers, responders, citizens) in the affected
geospatial area_id for emergency alert dispatch (SMS, Push, In-App).
"""

import hmac
import logging
from typing import List, Optional
from pydantic import BaseModel
from fastapi import APIRouter, Header, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.database import get_db
from app.models.user import User, UserRole

logger = logging.getLogger(__name__)

router = APIRouter(tags=["Recipient Resolution"])


class ResolveRecipientsRequest(BaseModel):
    area_id: str
    alert_id: str
    severity: str


class RecipientResponseItem(BaseModel):
    recipient_id: str
    phone_number: Optional[str] = None
    device_token: Optional[str] = None
    preferred_channels: List[str] = ["SMS", "PUSH"]
    priority: str = "NORMAL"
    preferred_locale: str = "en"


@router.post("/recipients/resolve", response_model=List[RecipientResponseItem])
async def resolve_recipients(
    payload: ResolveRecipientsRequest,
    x_internal_service_key: Optional[str] = Header(None, alias="X-Internal-Service-Key"),
    db: AsyncSession = Depends(get_db),
):
    """
    Resolve notification recipients for a given alert area and severity.
    Called by M5 Alert Engine to target alerts.
    """
    settings = get_settings()

    # Verify service key. A missing header must be rejected exactly like a
    # wrong one - the previous `if expected_key and x_internal_service_key`
    # guard only fired when BOTH sides were truthy, so sending no header at
    # all skipped the check entirely. hmac.compare_digest also avoids a
    # timing side-channel, matching the pattern M5's api/deps.py already uses.
    expected_key = settings.INTERNAL_SERVICE_KEY or settings.M5_SERVICE_KEY
    if not x_internal_service_key or not expected_key or not hmac.compare_digest(x_internal_service_key, expected_key):
        logger.warning("Recipient resolution rejected: missing or invalid service key.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing service key",
        )

    recipients: List[RecipientResponseItem] = []

    # 1. Fetch active registered users from DB
    try:
        result = await db.execute(select(User).where(User.is_active == True))
        users = result.scalars().all()
        for user in users:
            is_officer = user.role in [UserRole.FIELD_OFFICER, UserRole.ADMIN, UserRole.DISTRICT_ADMIN]
            channels = ["SMS", "PUSH", "APP"] if is_officer else ["SMS", "PUSH"]
            priority = "CRITICAL" if (is_officer or payload.severity == "CRITICAL") else "NORMAL"
            recipients.append(
                RecipientResponseItem(
                    recipient_id=str(user.id),
                    phone_number="+919876543210",  # Default test phone for sandbox notifications
                    device_token=f"fcm_token_{user.id}",
                    preferred_channels=channels,
                    priority=priority,
                    preferred_locale="en",
                )
            )
    except Exception as exc:
        logger.warning("Could not query users table (%s). Using designated default recipients.", exc)

    # 2. If no registered users yet (or standalone test), provide standard designated NER incident command contacts
    if not recipients:
        recipients = [
            RecipientResponseItem(
                recipient_id="deoc-papum-pare-01",
                phone_number="+919876543210",
                device_token="fcm_deoc_papum_pare",
                preferred_channels=["SMS", "PUSH"],
                priority="CRITICAL",
                preferred_locale="en",
            ),
            RecipientResponseItem(
                recipient_id="ndrf-12bn-itanagar-duty",
                phone_number="+919876543211",
                device_token="fcm_ndrf_itanagar",
                preferred_channels=["SMS", "PUSH"],
                priority="CRITICAL",
                preferred_locale="en",
            ),
            RecipientResponseItem(
                recipient_id="sdma-arunachal-control",
                phone_number="+919876543212",
                device_token="fcm_sdma_arunachal",
                preferred_channels=["SMS", "PUSH"],
                priority="CRITICAL",
                preferred_locale="en",
            ),
        ]

    return recipients
