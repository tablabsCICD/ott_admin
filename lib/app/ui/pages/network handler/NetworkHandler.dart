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

  @override
  void initState() {
    super.initState();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        isConnected =
            results.isNotEmpty && results.first != ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isConnected ? widget.mainPage : LowNetworkPage();
  }
}
