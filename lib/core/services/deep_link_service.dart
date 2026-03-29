import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deep Link Service
///
/// Handles incoming deep links from SMS.
/// Parses URLs like: https://vvistech.com/shipment/DEMO.17002
/// and extracts the shipment ID for navigation.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Uri? _initialUri;

  /// Get the initial URI that launched the app
  Future<Uri?> getInitialLink() async {
    if (_initialUri != null) return _initialUri;

    try {
      final uri = await _appLinks.getInitialLink();
      _initialUri = uri;
      log('=== Initial Deep Link ===');
      log('URI: $uri');
      return uri;
    } catch (e) {
      log('Error getting initial link: $e');
      return null;
    }
  }

  /// Start listening for incoming deep links
  void startListening(Function(Uri) onLink) {
    _linkSubscription?.cancel();

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        log('=== Received Deep Link ===');
        log('URI: $uri');
        onLink(uri);
      },
      onError: (Object error) {
        log('Error listening to deep link: $error');
      },
    );
  }

  /// Stop listening for deep links
  void stopListening() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  /// Parse shipment ID from URI
  /// Supports: https://vvistech.com/shipment/DEMO.17002
  String? parseShipmentId(Uri uri) {
    log('=== Parsing URI ===');
    log('Host: ${uri.host}');
    log('Path: ${uri.path}');
    log('Segments: ${uri.pathSegments}');

    if (uri.host != 'vvistech.com') {
      log('Invalid host: ${uri.host}');
      return null;
    }

    if (uri.pathSegments.isEmpty || uri.pathSegments[0] != 'shipment') {
      log('Invalid path: ${uri.path}');
      return null;
    }

    if (uri.pathSegments.length < 2) {
      log('No shipment ID found in path');
      return null;
    }

    final shipmentId = uri.pathSegments[1];
    log('Extracted Shipment ID: $shipmentId');
    return shipmentId;
  }

  /// Check if a URI is a valid shipment deep link
  bool isShipmentLink(Uri uri) {
    return uri.host == 'vvistech.com' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'shipment' &&
        uri.pathSegments.length >= 2;
  }

  /// Extract domain from shipment ID
  /// Example: "DEMO.17002" -> "DEMO"
  String? extractDomainFromShipmentId(String shipmentId) {
    final parts = shipmentId.split('.');
    if (parts.isEmpty) return null;
    return parts[0];
  }

  /// Save domain to SharedPreferences
  Future<void> saveDomain(String domain) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_domain', domain);
      log('✅ Domain saved: $domain');
    } catch (e) {
      log('❌ Error saving domain: $e');
    }
  }

  /// Get saved domain from SharedPreferences
  static Future<String?> getSavedDomain() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('driver_domain');
    } catch (e) {
      log('❌ Error getting saved domain: $e');
      return null;
    }
  }

  /// Parse shipment ID and save domain from deep link
  Future<String?> parseAndSaveShipmentData(Uri uri) async {
    final shipmentId = parseShipmentId(uri);
    if (shipmentId == null) return null;

    final domain = extractDomainFromShipmentId(shipmentId);
    if (domain != null) {
      await saveDomain(domain);
    }

    return shipmentId;
  }

  void dispose() {
    stopListening();
  }
}

/// Deep Link Handler Widget
///
/// Wraps the app to handle initial and ongoing deep link events.
class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  final Function(String shipmentId)? onShipmentDeepLink;

  const DeepLinkHandler({
    super.key,
    required this.child,
    this.onShipmentDeepLink,
  });

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _deepLinkService.getInitialLink();
      if (uri != null && mounted) {
        _processDeepLink(uri);
      }
    } catch (e) {
      log('Error handling initial link: $e');
    }
  }

  void _handleIncomingLinks() {
    _deepLinkService.startListening((uri) {
      if (mounted) {
        _processDeepLink(uri);
      }
    });
  }

  Future<void> _processDeepLink(Uri uri) async {
    log('=== Processing Deep Link ===');
    log('URI: $uri');

    if (_deepLinkService.isShipmentLink(uri)) {
      final shipmentId =
          await _deepLinkService.parseAndSaveShipmentData(uri);
      if (shipmentId != null) {
        log('✅ Valid shipment link: $shipmentId');
        widget.onShipmentDeepLink?.call(shipmentId);
      }
    } else {
      log('⚠️ Not a shipment link');
    }
  }

  @override
  void dispose() {
    _deepLinkService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}