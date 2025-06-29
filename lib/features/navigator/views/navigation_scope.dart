import 'package:flutter/material.dart';
import 'package:pumpkin_app/features/navigator/components/navigation_bar.dart';

class NavigationScope extends StatefulWidget {
  final Widget child;
  const NavigationScope({super.key, required this.child});

  @override
  State<NavigationScope> createState() => _NavigationScopeState();
}

class _NavigationScopeState extends State<NavigationScope> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 8,
            left: 8,
            right: 8,
            child: GlobalNavigationBar(),
          ),
        ],
      ),
    );
  }
}
