enum PcosResultLevel {
  low,
  moderate,
  higher,
}

extension PcosResultLevelX on PcosResultLevel {
  String get displayTitle {
    switch (this) {
      case PcosResultLevel.low:
        return 'Low indication of PCOS-associated features';
      case PcosResultLevel.moderate:
        return 'Moderate indication of PCOS-associated features';
      case PcosResultLevel.higher:
        return 'Higher indication of PCOS-associated features';
    }
  }

  String get levelBadgeText {
    switch (this) {
      case PcosResultLevel.low:
        return 'Low indication';
      case PcosResultLevel.moderate:
        return 'Moderate indication';
      case PcosResultLevel.higher:
        return 'Higher indication';
    }
  }
}
