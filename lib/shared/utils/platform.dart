import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

bool isSmartwatch(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  bool isSmallScreen = screenWidth < 250 && screenHeight < 250;

  bool isAndroid = UniversalPlatform.isAndroid;

  return isSmallScreen && isAndroid;
}

bool shouldUseDesktopLayout(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  bool isLargeScreen = screenWidth > 1000 && screenHeight > 1000;

  bool isLandscape = screenWidth > screenHeight;

  bool isDesktop = UniversalPlatform.isDesktop;

  return isLargeScreen || isDesktop || isLandscape;
}

bool shouldUseMobileLayout(BuildContext context) {
  return !shouldUseDesktopLayout(context);
}
