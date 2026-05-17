import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AllergenDetectionScreen extends StatefulWidget {
  const AllergenDetectionScreen({super.key});

  @override
  State<AllergenDetectionScreen> createState() =>
      _AllergenDetectionScreenState();
}

class _AllergenDetectionScreenState extends State<AllergenDetectionScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  final _labelController = TextEditingController();
  Map<String, dynamic>? _scanResult;
  List<dynamic> _history = [];
  bool _scanning = false;
  bool _loadingHistory = true;
  late AnimationController _resultAnimCtrl;
  late Animation<double> _resultScale;
  late StreamSubscription _historySub;

  @override
  void initState() {
    super.initState();
    _resultAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _resultScale = CurvedAnimation(
      parent: _resultAnimCtrl,
      curve: Curves.elasticOut,
    );

    _historySub = ApiService.allergenHistoryChanged.stream.listen((_) {
      _loadHistory();
    });

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await _api.getScanHistory();
      if (mounted) {
        setState(() {
          _history = data;
          _loadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _scan() async {
    if (_labelController.text.trim().isEmpty) return;
    setState(() {
      _scanning = true;
      _scanResult = null;
    });
    _resultAnimCtrl.reset();
    try {
      final result = await _api.scanLabel(_labelController.text.trim());
      if (mounted) {
        setState(() {
          _scanResult = result;
          _scanning = false;
        });
        _resultAnimCtrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
  }

  Future<void> _scanFromImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _scanning = true;
      _scanResult = null;
    });
    _resultAnimCtrl.reset();

    try {
      final result = await _api.scanImage(File(pickedFile.path));
      if (mounted) {
        setState(() {
          _scanResult = result;
          _scanning = false;
        });
        _resultAnimCtrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image scan failed: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
  }

  Color _resultColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SAFE':
        return context.appColors.successColor;
      case 'WARNING':
        return context.appColors.warningColor;
      case 'DANGER':
        return context.appColors.dangerColor;
      default:
        return context.appColors.textSecondary;
    }
  }

  IconData _resultIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'SAFE':
        return Icons.check_circle_rounded;
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'DANGER':
        return Icons.dangerous_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'SAFE':
        return 'SAFE TO CONSUME';
      case 'WARNING':
        return 'POTENTIAL ALLERGENS';
      case 'DANGER':
        return 'DANGER - AVOID';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  void _showScanDetails(Map<String, dynamic> item) {
    final status = item['status'] ?? 'SAFE';
    final color = _resultColor(status);
    final allergens = item['allergensFound'] as List<dynamic>? ?? [];
    final message = item['message'] as String?;
    final labelText = item['labelText'] as String? ?? 'No text extracted';
    final dateStr = item['date'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.appColors.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: context.appColors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_resultIcon(status), color: color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(status),
                          style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (dateStr != null)
                          Text(
                            _formatDate(dateStr),
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (message != null && message.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: context.appColors.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (allergens.isNotEmpty) ...[
                Text(
                  'Allergens Found',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allergens.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        a.toString(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                'Extracted Ingredient Text',
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.appColors.bgColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: context.appColors.accentColor.withValues(alpha: 0.08),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      labelText,
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AccentButton(
                label: 'Close Analysis Report',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _historySub.cancel();
    _resultAnimCtrl.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(title: const Text('Allergen Detection')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderColor: context.appColors.accentColor.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.appColors.accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.insights_rounded,
                        color: context.appColors.accentColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI Diagnostic Guide',
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StepRow(
                  number: '1',
                  text: 'Place ingredient label inside camera target',
                ),
                const SizedBox(height: 10),
                _StepRow(
                  number: '2',
                  text: 'Take photo or paste label text below',
                ),
                const SizedBox(height: 10),
                _StepRow(
                  number: '3',
                  text: 'Inspect the customized allergen report instantly',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _labelController,
            maxLines: 4,
            style: TextStyle(color: context.appColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Paste or type ingredient list here…',
              hintStyle: TextStyle(color: context.appColors.textHint),
              filled: true,
              fillColor: context.appColors.surfaceColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.appColors.accentColor.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.appColors.accentColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AccentButton(
            label: 'Analyze Ingredients',
            icon: Icons.biotech_rounded,
            isLoading: _scanning,
            onPressed: _scan,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanning
                      ? null
                      : () => _scanFromImage(ImageSource.camera),
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: context.appColors.accentColor,
                    size: 18,
                  ),
                  label: Text(
                    'Camera OCR',
                    style: TextStyle(
                      color: context.appColors.accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.appColors.accentColor.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanning
                      ? null
                      : () => _scanFromImage(ImageSource.gallery),
                  icon: Icon(
                    Icons.photo_library_rounded,
                    color: context.appColors.accentColor,
                    size: 18,
                  ),
                  label: Text(
                    'Upload Photo',
                    style: TextStyle(
                      color: context.appColors.accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.appColors.accentColor.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_scanResult != null)
            ScaleTransition(scale: _resultScale, child: _buildResultCard()),

          const SizedBox(height: 28),
          const SectionHeader(title: 'Diagnostic Scan Logs'),
          const SizedBox(height: 12),
          if (_loadingHistory)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(
                  color: context.appColors.accentColor,
                ),
              ),
            )
          else if (_history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    Icon(
                      Icons.manage_search_rounded,
                      color: context.appColors.textSecondary.withValues(alpha: 0.4),
                      size: 54,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No diagnosis records found',
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_history.length.clamp(0, 10), (i) {
              final item = _history[i];
              final status = item['status'] ?? 'SAFE';
              final dateStr = item['date'];
              final allergensFound =
                  item['allergensFound'] as List<dynamic>? ?? [];
              final rawText = item['labelText'] ?? '';
              final shortText = rawText.replaceAll('\n', ' ').trim();
              final color = _resultColor(status);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _showScanDetails(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.appColors.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: 5,
                            child: Container(color: color),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _resultIcon(status),
                                        color: color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            shortText.isEmpty
                                                ? 'Image Scan'
                                                : shortText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: context.appColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          if (dateStr != null) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              _formatDate(dateStr),
                                              style: TextStyle(
                                                color: context.appColors.textSecondary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status.toString().toUpperCase(),
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (allergensFound.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 38),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: allergensFound.map<Widget>((a) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: color.withValues(alpha: 0.15),
                                            ),
                                          ),
                                          child: Text(
                                            a.toString(),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 38),
                                  child: Row(
                                    children: [
                                      Text(
                                        'View complete report',
                                        style: TextStyle(
                                          color: context.appColors.accentColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 12,
                                        color: context.appColors.accentColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final status = _scanResult!['status'] ?? 'SAFE';
    final color = _resultColor(status);
    final allergens = _scanResult!['allergensFound'] ?? [];
    final message = _scanResult!['message'] as String?;

    return GlassCard(
      borderColor: color.withValues(alpha: 0.35),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_resultIcon(status), color: color, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          if (message != null && message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.1)),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (allergens is List && allergens.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Detected Allergens:',
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergens.map<Widget>((a) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    a.toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (status.toString().toUpperCase() == 'SAFE' &&
              (message == null || message.isEmpty)) ...[
            const SizedBox(height: 10),
            Text(
              'No allergens detected – safe to consume!',
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;
  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: context.appColors.accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: context.appColors.accentColor.withValues(alpha: 0.15)),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: context.appColors.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
