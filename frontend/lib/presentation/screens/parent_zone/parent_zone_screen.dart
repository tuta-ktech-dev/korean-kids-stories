import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'parent_zone_view.dart';

@RoutePage()
class ParentZoneScreen extends StatelessWidget {
  const ParentZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentZoneView();
  }
}
