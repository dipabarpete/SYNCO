enum EndometriosisResultLevel {
  low,
  moderate,
  higher,
}

extension EndometriosisResultLevelX on EndometriosisResultLevel {
  String get displayTitle {
    switch (this) {
      case EndometriosisResultLevel.low:
        return 'Low indication of endometriosis-associated features';
      case EndometriosisResultLevel.moderate:
        return 'Moderate indication of endometriosis-associated features';
      case EndometriosisResultLevel.higher:
        return 'Higher indication of endometriosis-associated features';
    }
  }

  String get levelBadgeText {
    switch (this) {
      case EndometriosisResultLevel.low:
        return 'Low indication';
      case EndometriosisResultLevel.moderate:
        return 'Moderate indication';
      case EndometriosisResultLevel.higher:
        return 'Higher indication';
    }
  }
}
