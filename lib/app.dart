import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/utils/app_router.dart';
import 'package:flutter/material.dart';

class DrifterBuoyApp extends StatelessWidget {
  const DrifterBuoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
