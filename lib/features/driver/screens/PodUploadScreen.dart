import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:leapdriver/core/theme/app_colors.dart';
import 'package:leapdriver/core/theme/app_theme.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';
import 'package:leapdriver/core/services/supabase_service.dart';


/// PodUploadScreen
///
/// Simple 3-step flow:
///   1. Camera opens immediately
///   2. Driver previews photo — Retake or Use Photo
///   3. Upload with spinner → success → back
///
/// No forms, no dropdowns, no event ID needed.
/// Document POST only needs shipmentXid, domain, and the file.
class PodUploadScreen extends StatefulWidget {
  final String shipmentXid;
  final String docKey;    // 'pod', 'eway', 'invoice', 'damage'
  final String docLabel;  // display name e.g. "POD (Signed)"

  const PodUploadScreen({
    super.key,
    required this.shipmentXid,
    required this.docKey,
    required this.docLabel,
  });

  @override
  State<PodUploadScreen> createState() => _PodUploadScreenState();
}

class _PodUploadScreenState extends State<PodUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  File?   _photo;
  bool    _uploading = false;
  String? _error;

  // Convenience — safe to call in any widget method after first build
  AppThemeData get _c => context.colors;

  @override
  void initState() {
    super.initState();
    // Open camera immediately on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
  }

  // ── Step 1: Camera ──────────────────────────────────────────────────────────
  Future<void> _openCamera() async {
    final picked = await _picker.pickImage(
      source:       ImageSource.camera,
      imageQuality: 85,
      maxWidth:     1920,
      maxHeight:    1080,
    );
    if (picked != null) {
      setState(() { _photo = File(picked.path); _error = null; });
    } else {
      // Driver cancelled camera — go back
      if (mounted) Navigator.pop(context, false);
    }
  }

  Future<void> _openGallery() async {
    final picked = await _picker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 85,
      maxWidth:     1920,
      maxHeight:    1080,
    );
    if (picked != null) {
      setState(() { _photo = File(picked.path); _error = null; });
    }
  }

  // ── Step 2: Retake ──────────────────────────────────────────────────────────
  void _retake() {
    setState(() { _photo = null; _error = null; });
    _openCamera();
  }

  // ── Step 3: Upload ──────────────────────────────────────────────────────────
  Future<void> _upload() async {
    if (_photo == null) return;
    setState(() { _uploading = true; _error = null; });

    try {
      final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      final extension = _photo!.path.split('.').last.toLowerCase();
      final fileName  = '${widget.docKey}_$timestamp.$extension';
      final bytes     = await _photo!.readAsBytes();
      final b64       = base64Encode(bytes);

      await SupabaseService.uploadDocument(
        shipmentXid:   widget.shipmentXid,
        docKey:        widget.docKey,
        fileName:      fileName,
        mimeType:      'image/$extension',
        base64Content: b64,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _uploading = false;
        _error = 'Network error. Please check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>(); // rebuild on theme change
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _photo == null
            ? _buildWaiting()
            : _buildPreview(),
      ),
    );
  }

  // ── Waiting for camera ──────────────────────────────────────────────────────
  Widget _buildWaiting() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        const SizedBox(height: 20),
        Text('Opening camera...',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
      ]),
    );
  }

  // ── Photo preview ───────────────────────────────────────────────────────────
  Widget _buildPreview() {
    return Column(
      children: [

        // ── Top bar ──────────────────────────────────────────────────────────
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.docLabel,
                style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Gallery option
            GestureDetector(
              onTap: _uploading ? null : _openGallery,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.photo_library, color: Colors.white, size: 16),
                  SizedBox(width: 5),
                  Text('Gallery', style: TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ),
          ]),
        ),

        // ── Photo preview ─────────────────────────────────────────────────────
        Expanded(
          child: InteractiveViewer(
            child: Image.file(
              _photo!,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ),

        // ── Error message ─────────────────────────────────────────────────────
        if (_error != null)
          Container(
            width: double.infinity,
            color: _c.danger,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!,
                  style: const TextStyle(color: Colors.white, fontSize: 13))),
            ]),
          ),

        // ── Action buttons ────────────────────────────────────────────────────
        Container(
          color: Colors.black,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: _uploading
              ? _buildUploadingState()
              : _buildActionButtons(),
        ),
      ],
    );
  }

  // ── Uploading spinner ───────────────────────────────────────────────────────
  Widget _buildUploadingState() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
            LinearProgressIndicator(
        backgroundColor: Colors.white24,
        valueColor: AlwaysStoppedAnimation<Color>(_c.success),
      ),
      const SizedBox(height: 16),
      Text(
        'Uploading ${widget.docLabel}...',
        style: const TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  // ── Retake + Use Photo buttons ──────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(children: [
      // Retake
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _retake,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Retake', overflow: TextOverflow.ellipsis, maxLines: 1),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
      const SizedBox(width: 12),
      // Use Photo
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: _upload,
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Use Photo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _c.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            minimumSize: const Size(0, 52),
            elevation: 0,
          ),
        ),
      ),
    ]);
  }
}