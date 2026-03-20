import 'package:drifter_buoy/app.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const DrifterBuoyApp());
}
