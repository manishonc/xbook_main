import 'package:flutter/material.dart';
import 'app.dart';
import 'utils/constants.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await supabaseService.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(MyApp());
}
