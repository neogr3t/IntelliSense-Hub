// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';

// class NetworkChecker extends ChangeNotifier {
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
//   bool _isConnected = true;

//   bool get isConnected => _isConnected;

//   NetworkChecker() {
//     _initConnectivity();
//     _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }

//   Future<void> _initConnectivity() async {
//     try {
//       final result = await _connectivity.checkConnectivity();
//       _updateConnectionStatus([result]);
//     } catch (e) {
//       _isConnected = false;
//       notifyListeners();
//     }
//   }

//   void _updateConnectionStatus(List<ConnectivityResult> results) {
//     // Check if there is any connectivity result that is not `none`
//     _isConnected = results.any((result) => result != ConnectivityResult.none);
//     notifyListeners();
//   }

//   Future<void> checkConnectivity() async {
//     final result = await _connectivity.checkConnectivity();
//     _updateConnectionStatus([result]);
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }
// }
