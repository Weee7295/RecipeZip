import 'package:flutter/material.dart';

// ============================================================================
// DEVICE TYPE DETECTION
// ============================================================================

enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return DeviceType.mobile;
  if (width < 1200) return DeviceType.tablet;
  return DeviceType.desktop;
}

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= 600 &&
    MediaQuery.of(context).size.width < 1200;

bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

// ============================================================================
// RESPONSIVE SPACING
// ============================================================================

double getPadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 16;   // Mobile
  if (width < 1200) return 24;  // Tablet
  return 32;                     // Desktop
}

double getHorizontalPadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 16;   // Mobile
  if (width < 1200) return 24;  // Tablet
  return 48;                     // Desktop
}

double getVerticalPadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 16;   // Mobile
  if (width < 1200) return 20;  // Tablet
  return 32;                     // Desktop
}

// ============================================================================
// RESPONSIVE FONT SIZES
// ============================================================================

double getHeadingFontSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 28;   // Mobile
  if (width < 1200) return 32;  // Tablet
  return 36;                     // Desktop
}

double getSubheadingFontSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 20;   // Mobile
  if (width < 1200) return 22;  // Tablet
  return 24;                     // Desktop
}

double getBodyFontSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 14;   // Mobile
  if (width < 1200) return 15;  // Tablet
  return 16;                     // Desktop
}

double getSmallFontSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 12;   // Mobile
  if (width < 1200) return 13;  // Tablet
  return 14;                     // Desktop
}

// ============================================================================
// RESPONSIVE DIMENSIONS
// ============================================================================

double getMaxWidth(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return double.infinity;  // Mobile: full width
  if (width < 1200) return double.infinity; // Tablet: full width
  return 1400;                               // Desktop: max width
}

// ============================================================================
// RESPONSIVE GAPS & SPACING
// ============================================================================

double getGapBetweenSections(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 40;   // Mobile
  if (width < 1200) return 40;  // Tablet
  return 60;                     // Desktop
}

double getGapBetweenItems(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 12;   // Mobile
  if (width < 1200) return 16;  // Tablet
  return 20;                     // Desktop
}