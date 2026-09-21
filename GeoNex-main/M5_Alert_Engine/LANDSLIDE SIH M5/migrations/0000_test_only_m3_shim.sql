-- TEST/DEV ONLY. Never apply against a real deployment - risk_predictions
-- is M3-owned schema (architecture §7); M3's own migrations create it
-- there. This shim exists purely so M5's pipeline can be exercised
-- end-to-end against a single local Postgres instance.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS risk_predictions (
    prediction_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    area_id             TEXT NOT NULL,
    risk_score          DOUBLE PRECISION NOT NULL,
    risk_band           TEXT NOT NULL,
    confidence          DOUBLE PRECISION,
    prediction_timestamp TIMESTAMPTZ NOT NULL,
    model_version       TEXT,
    -- M3's real risk_predictions table declares these NOT NULL (see
    -- app/models/risk.py) - nullable here only so existing rows created
    -- before this fix don't break, but every insert should set them so the
    -- shim actually matches production and the test suite means what it
    -- claims to mean.
    latitude            DOUBLE PRECISION,
    longitude           DOUBLE PRECISION,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_risk_predictions_area_id ON risk_predictions(area_id);
CREATE INDEX IF NOT EXISTS ix_risk_predictions_created_at ON risk_predictions(created_at);
