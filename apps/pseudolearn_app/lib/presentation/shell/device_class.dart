enum DeviceClass {
  compact,
  medium,
  expanded;

  static const double mediumBreakpoint = 600.0;
  static const double expandedBreakpoint = 960.0;

  static DeviceClass fromWidth(double width) {
    if (width < mediumBreakpoint) return DeviceClass.compact;
    if (width < expandedBreakpoint) return DeviceClass.medium;
    return DeviceClass.expanded;
  }
}
