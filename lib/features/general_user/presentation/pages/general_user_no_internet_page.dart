import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/network/network_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralUserNoInternetPage extends StatefulWidget {
  const GeneralUserNoInternetPage({super.key});

  @override
  State<GeneralUserNoInternetPage> createState() =>
      _GeneralUserNoInternetPageState();
}

class _GeneralUserNoInternetPageState extends State<GeneralUserNoInternetPage> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _connectivitySub = NetworkConnectionChecker.onConnectivityChanged.listen((
      _,
    ) async {
      await _navigateIfConnected();
    });
    _navigateIfConnected();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _navigateIfConnected() async {
    if (_isNavigating) return;

    final connected = await NetworkConnectionChecker.hasInternetConnection();
    if (!connected || !mounted) return;

    _isNavigating = true;
    context.go(AppRoutes.dashboardPath);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 76,
                  color: Color(0xFF4C5A67),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF262C31),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please check your network and try again. '
                  'The app will automatically continue to dashboard once internet is available.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF5C6670),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

