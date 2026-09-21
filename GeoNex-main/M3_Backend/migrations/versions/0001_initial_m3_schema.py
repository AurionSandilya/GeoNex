"""0001_initial_m3_schema

Revision ID: 0001_initial_m3_schema
Revises:
Create Date: 2026-09-20 11:15:00.000000

M3 Authoritative Schema Migration (PS ID: 26001 - SIH 2026).
Creates ALL M3-owned tables in dependency order:
  1.  users
  2.  risk_predictions   (M5 re-reads via shared DB; PostGIS GIST index)
  3.  field_reports      (PostGIS GIST index)
  4.  field_verifications
  5.  media
  6.  rainfall_observations
  7.  soil_moisture_observations
  8.  sar_observations
  9.  earthquake_events
  10. roads              (PostGIS GIST index)
  11. villages           (PostGIS GIST index)
  12. infrastructure     (PostGIS GIST index)
  13. model_versions
  14. audit_logs

Note: alerts and alert_deliveries are exclusively M5-owned.
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import geoalchemy2

revision: str = '0001_initial_m3_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto;")
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis;")

    # 1. Users
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('full_name', sa.String(length=255), nullable=False),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('role', sa.String(length=50), server_default='CITIZEN', nullable=False),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_users_email', 'users', ['email'], unique=True)

    # 2. Risk Predictions (M3 schema authority; M5 re-reads this)
    op.create_table(
        'risk_predictions',
        sa.Column('prediction_id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('area_id', sa.String(length=64), nullable=False),
        sa.Column('risk_score', sa.Float(), nullable=False),
        sa.Column('risk_band', sa.String(length=30), nullable=False),
        sa.Column('confidence', sa.Float(), nullable=True),
        sa.Column('prediction_timestamp', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('model_version', sa.String(length=50), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=False),
        sa.Column('longitude', sa.Float(), nullable=False),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326), nullable=True),
        sa.Column('feature_snapshot', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_risk_predictions_area_id', 'risk_predictions', ['area_id'])
    op.create_index('ix_risk_predictions_created_at', 'risk_predictions', ['created_at'])
    op.create_index('ix_risk_predictions_risk_band', 'risk_predictions', ['risk_band'])
    op.execute("CREATE INDEX IF NOT EXISTS idx_risk_predictions_location ON risk_predictions USING GIST (location);")

    # 3. Field Reports
    op.create_table(
        'field_reports',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('client_report_id', sa.String(length=100), nullable=True),
        sa.Column('report_type', sa.String(length=50), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('latitude', sa.Float(), nullable=False),
        sa.Column('longitude', sa.Float(), nullable=False),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326), nullable=False),
        sa.Column('capture_timestamp', sa.DateTime(timezone=True), nullable=False),
        sa.Column('status', sa.String(length=50), server_default='PENDING', nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_field_reports_client_report_id', 'field_reports', ['client_report_id'], unique=True)
    op.create_index('ix_field_reports_status', 'field_reports', ['status'])
    op.execute("CREATE INDEX IF NOT EXISTS idx_field_reports_location ON field_reports USING GIST (location);")

    # 4. Field Verifications
    op.create_table(
        'field_verifications',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('report_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('field_reports.id', ondelete='CASCADE'), nullable=False),
        sa.Column('officer_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('decision', sa.String(length=50), nullable=False),
        sa.Column('remarks', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_field_verifications_report_id', 'field_verifications', ['report_id'])

    # 5. Media
    op.create_table(
        'media',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('report_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('field_reports.id', ondelete='CASCADE'), nullable=False),
        sa.Column('media_type', sa.String(length=30), nullable=False),
        sa.Column('url', sa.String(length=2048), nullable=False),
        sa.Column('thumbnail_url', sa.String(length=2048), nullable=True),
        sa.Column('file_size_bytes', sa.Integer(), nullable=True),
        sa.Column('mime_type', sa.String(length=100), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_media_report_id', 'media', ['report_id'])

    # 6. Rainfall Observations
    op.create_table(
        'rainfall_observations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('station_id', sa.String(length=100), nullable=False),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('observed_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('rainfall_mm', sa.Float(), nullable=False),
        sa.Column('window_hours', sa.Integer(), server_default='1', nullable=False),
        sa.Column('source', sa.String(length=50), nullable=True),
        sa.Column('quality_flag', sa.String(length=20), server_default='GOOD', nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_rainfall_observations_station_id', 'rainfall_observations', ['station_id'])
    op.create_index('ix_rainfall_observations_observed_at', 'rainfall_observations', ['observed_at'])

    # 7. Soil Moisture Observations
    op.create_table(
        'soil_moisture_observations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('station_id', sa.String(length=100), nullable=False),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('observed_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('moisture_ratio', sa.Float(), nullable=False),
        sa.Column('depth_cm', sa.Integer(), nullable=True),
        sa.Column('source', sa.String(length=50), nullable=True),
        sa.Column('quality_flag', sa.String(length=20), server_default='GOOD', nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_soil_moisture_observations_station_id', 'soil_moisture_observations', ['station_id'])
    op.create_index('ix_soil_moisture_observations_observed_at', 'soil_moisture_observations', ['observed_at'])

    # 8. SAR Observations
    op.create_table(
        'sar_observations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('scene_id', sa.String(length=150), nullable=False),
        sa.Column('satellite', sa.String(length=50), nullable=True),
        sa.Column('acquisition_date', sa.DateTime(timezone=True), nullable=False),
        sa.Column('processing_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('displacement_mm', sa.Float(), nullable=True),
        sa.Column('coherence', sa.Float(), nullable=True),
        sa.Column('bounding_box', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('source', sa.String(length=50), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_sar_observations_scene_id', 'sar_observations', ['scene_id'])
    op.create_index('ix_sar_observations_acquisition_date', 'sar_observations', ['acquisition_date'])

    # 9. Earthquake Events
    op.create_table(
        'earthquake_events',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('event_id', sa.String(length=100), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=False),
        sa.Column('longitude', sa.Float(), nullable=False),
        sa.Column('depth_km', sa.Float(), nullable=True),
        sa.Column('magnitude', sa.Float(), nullable=False),
        sa.Column('magnitude_type', sa.String(length=10), server_default='Mw', nullable=True),
        sa.Column('occurred_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('region_name', sa.String(length=200), nullable=True),
        sa.Column('source_agency', sa.String(length=50), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_earthquake_events_occurred_at', 'earthquake_events', ['occurred_at'])
    op.create_index('ix_earthquake_events_magnitude', 'earthquake_events', ['magnitude'])

    # 10. Roads
    op.create_table(
        'roads',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('road_name', sa.String(length=255), nullable=False),
        sa.Column('road_type', sa.String(length=50), nullable=True),
        sa.Column('road_number', sa.String(length=30), nullable=True),
        sa.Column('geometry', geoalchemy2.types.Geometry(geometry_type='LINESTRING', srid=4326), nullable=True),
        sa.Column('length_km', sa.Float(), nullable=True),
        sa.Column('surface_type', sa.String(length=50), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.execute("CREATE INDEX IF NOT EXISTS idx_roads_geometry ON roads USING GIST (geometry);")

    # 11. Villages
    op.create_table(
        'villages',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('village_name', sa.String(length=255), nullable=False),
        sa.Column('district', sa.String(length=100), nullable=True),
        sa.Column('block', sa.String(length=100), nullable=True),
        sa.Column('population', sa.Integer(), nullable=True),
        sa.Column('households', sa.Integer(), nullable=True),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326), nullable=True),
        sa.Column('boundary', geoalchemy2.types.Geometry(geometry_type='POLYGON', srid=4326), nullable=True),
        sa.Column('landslide_hazard_zone', sa.String(length=30), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_villages_district', 'villages', ['district'])
    op.execute("CREATE INDEX IF NOT EXISTS idx_villages_location ON villages USING GIST (location);")

    # 12. Infrastructure
    op.create_table(
        'infrastructure',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('category', sa.String(length=50), nullable=False),
        sa.Column('sub_category', sa.String(length=100), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326), nullable=True),
        sa.Column('district', sa.String(length=100), nullable=True),
        sa.Column('capacity_persons', sa.Integer(), nullable=True),
        sa.Column('vulnerability_score', sa.Float(), nullable=True),
        sa.Column('operational_status', sa.String(length=30), server_default='OPERATIONAL', nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_infrastructure_category', 'infrastructure', ['category'])
    op.create_index('ix_infrastructure_district', 'infrastructure', ['district'])
    op.execute("CREATE INDEX IF NOT EXISTS idx_infrastructure_location ON infrastructure USING GIST (location);")

    # 13. Model Versions
    op.create_table(
        'model_versions',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('model_name', sa.String(length=100), nullable=False),
        sa.Column('version_tag', sa.String(length=50), nullable=False),
        sa.Column('model_type', sa.String(length=50), nullable=True),
        sa.Column('algorithm', sa.String(length=100), nullable=True),
        sa.Column('training_data_hash', sa.String(length=64), nullable=True),
        sa.Column('accuracy_metrics', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('feature_names', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('artifact_path', sa.String(length=1024), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='false', nullable=False),
        sa.Column('deployed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
    )
    op.create_index('ix_model_versions_model_name', 'model_versions', ['model_name'])
    op.create_index('ix_model_versions_is_active', 'model_versions', ['is_active'])

    # 14. Audit Logs
    op.create_table(
        'audit_logs',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('actor_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('actor_role', sa.String(length=50), nullable=True),
        sa.Column('action', sa.String(length=100), nullable=False),
        sa.Column('resource_type', sa.String(length=50), nullable=True),
        sa.Column('resource_id', sa.String(length=100), nullable=True),
        sa.Column('ip_address', sa.String(length=45), nullable=True),
        sa.Column('user_agent', sa.String(length=512), nullable=True),
        sa.Column('details', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_audit_logs_actor_id', 'audit_logs', ['actor_id'])
    op.create_index('ix_audit_logs_action', 'audit_logs', ['action'])
    op.create_index('ix_audit_logs_created_at', 'audit_logs', ['created_at'])


def downgrade() -> None:
    op.drop_table('audit_logs')
    op.drop_table('model_versions')
    op.execute("DROP INDEX IF EXISTS idx_infrastructure_location;")
    op.drop_table('infrastructure')
    op.execute("DROP INDEX IF EXISTS idx_villages_location;")
    op.drop_table('villages')
    op.execute("DROP INDEX IF EXISTS idx_roads_geometry;")
    op.drop_table('roads')
    op.drop_table('earthquake_events')
    op.drop_table('sar_observations')
    op.drop_table('soil_moisture_observations')
    op.drop_table('rainfall_observations')
    op.drop_table('media')
    op.drop_table('field_verifications')
    op.execute("DROP INDEX IF EXISTS idx_field_reports_location;")
    op.drop_table('field_reports')
    op.execute("DROP INDEX IF EXISTS idx_risk_predictions_location;")
    op.drop_table('risk_predictions')
    op.drop_table('users')
