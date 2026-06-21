import 'dart:async';

import 'package:admin_ott/app/ui/pages/network%20handler/LowNetworkPage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkHandler extends StatefulWidget {
  final Widget mainPage;

  const NetworkHandler({super.key, required this.mainPage});

  @override
  _NetworkHandlerState createState() => _NetworkHandlerState();
}

class _NetworkHandlerState extends State<NetworkHandler> {
  bool isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_updateConnectionState);
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionState);
  }

  void _updateConnectionState(List<ConnectivityResult> results) {
    if (!mounted) return;
    setState(() {
      isConnected =
          results.isNotEmpty && results.first != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isConnected ? widget.mainPage : LowNetworkPage();
  }
}
