import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:leapdriver/config/app_config.dart';

/// SupabaseService
///
/// ALL API calls go through here — never directly to OTM.
/// The app only knows the Supabase URL and anon key.
/// OTM credentials live in Supabase — never in the app.
class SupabaseService {
  SupabaseService._();

  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _anonKey = AppConfig.supabaseAnonKey;
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_anonKey',
        'apikey': _anonKey,
      };

  // ─── Logger ────────────────────────────────────────────────────────────────

  static void _logRequest(String method, String url, Map<String, dynamic>? body) {
    log('');
    log('┌─────────────────────────────────────────');
    log('│ 🌐 REQUEST: $method $url');
    if (body != null) {
      log('│ 📤 Body: ${const JsonEncoder.withIndent('  ').convert(body)}');
    }
    log('└─────────────────────────────────────────');
  }

  static void _logResponse(String url, http.Response res) {
    final isSuccess = res.statusCode >= 200 && res.statusCode < 300;
    final icon = isSuccess ? '✅' : '❌';
    log('');
    log('┌─────────────────────────────────────────');
    log('│ $icon RESPONSE: ${res.statusCode} $url');
    try {
      final pretty = const JsonEncoder.withIndent('  ').convert(jsonDecode(res.body));
      log('│ 📥 Body: $pretty');
    } catch (_) {
      log('│ 📥 Body: ${res.body}');
    }
    log('└─────────────────────────────────────────');
  }

  // ─── Get Shipment ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getShipment(String shipmentXid) async {
    const url = '$_baseUrl/functions/v1/get-shipment';
    final body = {'shipmentXid': shipmentXid};

    _logRequest('POST', url, body);

    final res = await http
        .post(Uri.parse(url), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);

    _logResponse(url, res);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    final error = _parseError(res);
    throw Exception('Failed to fetch shipment: $error');
  }

  // ─── Post Event ────────────────────────────────────────────────────────────

  static Future<void> postEvent(
    String shipmentXid,
    Map<String, dynamic> eventPayload,
  ) async {
    const url = '$_baseUrl/functions/v1/post-event';
    final body = {'shipmentXid': shipmentXid, ...eventPayload};

    _logRequest('POST', url, body);

    final res = await http
        .post(Uri.parse(url), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);

    _logResponse(url, res);

    if (res.statusCode != 200 && res.statusCode != 201) {
      final error = _parseError(res);
      throw Exception('Failed to post event: $error');
    }
  }

  // ─── Patch Status ──────────────────────────────────────────────────────────

  static Future<void> patchStatus(String shipmentXid, String status) async {
    const url = '$_baseUrl/functions/v1/patch-status';
    final body = {'shipmentXid': shipmentXid, 'statusValue': status};

    _logRequest('POST', url, body);

    final res = await http
        .post(Uri.parse(url), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);

    _logResponse(url, res);

    if (res.statusCode != 200 && res.statusCode != 201) {
      final error = _parseError(res);
      throw Exception('Failed to patch status: $error');
    }
  }

  // ─── Upload Document ───────────────────────────────────────────────────────

  static Future<void> uploadDocument({
    required String shipmentXid,
    required String docKey,
    required String fileName,
    required String mimeType,
    required String base64Content,
  }) async {
    const url = '$_baseUrl/functions/v1/upload-document';
    final body = {
      'shipmentXid': shipmentXid,
      'docKey': docKey,
      'fileName': fileName,
      'mimeType': mimeType,
      'base64Content': '*** base64 content hidden ***', // don't log full base64
    };

    _logRequest('POST', url, body);

    final res = await http
        .post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode({
            'shipmentXid': shipmentXid,
            'docKey': docKey,
            'fileName': fileName,
            'mimeType': mimeType,
            'base64Content': base64Content, // actual value sent to API
          }),
        )
        .timeout(_timeout);

    _logResponse(url, res);

    if (res.statusCode != 200 && res.statusCode != 201) {
      final error = _parseError(res);
      throw Exception('Failed to upload document: $error');
    }
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  static String _parseError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      return body['error'] ?? 'HTTP ${res.statusCode}';
    } catch (_) {
      return 'HTTP ${res.statusCode}';
    }
  }
}