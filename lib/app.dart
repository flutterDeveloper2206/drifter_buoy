import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/navigation_service.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_bloc.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_event.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/pages/items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrifterBuoyApp extends StatelessWidget {
  const DrifterBuoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: BlocProvider<ItemsBloc>(
        create: (_) => sl<ItemsBloc>()..add(const FetchItems()),
        child: const ItemsPage(),
      ),
    );
  }
}
