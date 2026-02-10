import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'history_view.dart';

@RoutePage()
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HistoryView();
  }
}
