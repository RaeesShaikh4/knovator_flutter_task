enum SortOption {
  nameAscending,
  nameDescending,
  valueAscending,
  valueDescending,
  symbolAscending,
  symbolDescending,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.nameAscending:
        return 'Name (A-Z)';
      case SortOption.nameDescending:
        return 'Name (Z-A)';
      case SortOption.valueAscending:
        return 'Value (Low-High)';
      case SortOption.valueDescending:
        return 'Value (High-Low)';
      case SortOption.symbolAscending:
        return 'Symbol (A-Z)';
      case SortOption.symbolDescending:
        return 'Symbol (Z-A)';
    }
  }
}

