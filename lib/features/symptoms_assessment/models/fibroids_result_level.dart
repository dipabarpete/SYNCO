enum UterineFibroidResultLevel {
  low,
  moderate,
  higher,
}

extension UterineFibroidResultLevelX on UterineFibroidResultLevel {
  String get displayTitle {
    switch (this) {
      case UterineFibroidResultLevel.low:
        return 'Low indication of uterine-fibroid-associated features';
      case UterineFibroidResultLevel.moderate:
        return 'Moderate indication of uterine-fibroid-associated features';
      case UterineFibroidResultLevel.higher:
        return 'Higher indication of uterine-fibroid-associated features';
    }
  }

  String get levelBadgeText {
    switch (this) {
      case UterineFibroidResultLevel.low:
        return 'Low indication';
      case UterineFibroidResultLevel.moderate:
        return 'Moderate indication';
      case UterineFibroidResultLevel.higher:
        return 'Higher indication';
    }
  }
}