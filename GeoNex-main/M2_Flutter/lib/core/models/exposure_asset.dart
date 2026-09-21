import 'package:flutter/material.dart';

enum AssetType {
  road,
  village,
  bridge,
  hospital,
  powerGrid,
  school,
  telecomTower,
}

extension AssetTypeExt on AssetType {
  String get displayName {
    switch (this) {
      case AssetType.road:
        return 'Highway / Road';
      case AssetType.village:
        return 'Village / Settlement';
      case AssetType.bridge:
        return 'Bridge';
      case AssetType.hospital:
        return 'Hospital / Clinic';
      case AssetType.powerGrid:
        return 'Power Grid / Substation';
      case AssetType.school:
        return 'School / Community Shelter';
      case AssetType.telecomTower:
        return 'Telecom Tower';
    }
  }

  IconData get icon {
    switch (this) {
      case AssetType.road:
        return Icons.alt_route;
      case AssetType.village:
        return Icons.holiday_village_outlined;
      case AssetType.bridge:
        return Icons.polyline_outlined;
      case AssetType.hospital:
        return Icons.local_hospital_outlined;
      case AssetType.powerGrid:
        return Icons.electric_bolt_outlined;
      case AssetType.school:
        return Icons.school_outlined;
      case AssetType.telecomTower:
        return Icons.cell_tower;
    }
  }
}

class ExposureAsset {
  final String assetId;
  final String locationId;
  final AssetType type;
  final String name;
  final double latitude;
  final double longitude;
  final double connectivityImpact; // 0 to 100 (e.g. 95 if primary artery)
  final double exposureLevel; // 0 to 100
  final int estimatedPopulationAtRisk;
  final bool isBlocked;
  final String notes;

  const ExposureAsset({
    required this.assetId,
    required this.locationId,
    required this.type,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.connectivityImpact,
    required this.exposureLevel,
    required this.estimatedPopulationAtRisk,
    this.isBlocked = false,
    this.notes = '',
  });

  ExposureAsset copyWith({
    String? assetId,
    String? locationId,
    AssetType? type,
    String? name,
    double? latitude,
    double? longitude,
    double? connectivityImpact,
    double? exposureLevel,
    int? estimatedPopulationAtRisk,
    bool? isBlocked,
    String? notes,
  }) {
    return ExposureAsset(
      assetId: assetId ?? this.assetId,
      locationId: locationId ?? this.locationId,
      type: type ?? this.type,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      connectivityImpact: connectivityImpact ?? this.connectivityImpact,
      exposureLevel: exposureLevel ?? this.exposureLevel,
      estimatedPopulationAtRisk: estimatedPopulationAtRisk ?? this.estimatedPopulationAtRisk,
      isBlocked: isBlocked ?? this.isBlocked,
      notes: notes ?? this.notes,
    );
  }
}
