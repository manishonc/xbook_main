import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xbook_main/services/supabase_service.dart';
import 'package:xbook_main/utils/constants.dart';
import '../models/app_info.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  AppInfo? _appInfo;

  @override
  void initState() {
    super.initState();
    _getAppsView();
  }

  Future<void> _getAppsView() async {
    try {
      final result = await supabaseService.getAppsView(AppDomain);
      setState(() {
        _appInfo = result;
      });
      print('Apps view result: $_appInfo');
    } catch (e) {
      print('Error getting apps view: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting apps view: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match app bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _appInfo?.appName ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.indigo),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
