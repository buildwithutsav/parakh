import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/models/device_reading.dart';
import '../../core/services/device_data_service.dart';

import '../../core/theme/parakh_colors.dart';

class NirAnalysisScreen extends StatefulWidget {
  const NirAnalysisScreen({
    required this.isHindi,
    required this.isDeviceConnected,
    super.key,
  });

  final bool isHindi;
  final bool isDeviceConnected;

  @override
  State<NirAnalysisScreen> createState() => _NirAnalysisScreenState();
}

class _NirAnalysisScreenState extends State<NirAnalysisScreen> {
  final TextEditingController _sampleIdController = TextEditingController();
  final DeviceDataService _deviceDataService = DeviceDataService();
  final FlutterTts _flutterTts = FlutterTts();

  String _selectedFeed = 'Maize Silage';
  bool _isScanning = false;
  bool _showResult = false;
  DeviceReading? _reading;

  String _text(String english, String hindi) {
    return widget.isHindi ? hindi : english;
  }

  @override
  void initState() {
    super.initState();
    _configureVoice();
  }

  Future<void> _configureVoice() async {
    await _flutterTts.setLanguage(widget.isHindi ? 'hi-IN' : 'en-IN');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String english, String hindi) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage(widget.isHindi ? 'hi-IN' : 'en-IN');
    await _flutterTts.speak(_text(english, hindi));
  }

  Future<void> _startScan() async {
    if (!widget.isDeviceConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Connect the Parakh device before starting.',
              'जाँच शुरू करने से पहले परख डिवाइस कनेक्ट करें।',
            ),
          ),
          backgroundColor: const Color(0xFFB75B4A),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isScanning = true;
      _showResult = false;
      _reading = null;
    });
    await HapticFeedback.heavyImpact();
    final enteredSampleId = _sampleIdController.text.trim();

    final reading = await _deviceDataService.generateDemoReading(
      sampleId: enteredSampleId.isEmpty ? 'S001' : enteredSampleId,
      feedType: _selectedFeed,
    );

    if (!mounted) return;

    setState(() {
      _reading = reading;
      _isScanning = false;
      _showResult = true;
    });
  }

  void _resetScan() {
    setState(() {
      _showResult = false;
      _reading = null;
    });
  }

  @override
  void dispose() {
    _sampleIdController.dispose();
    _deviceDataService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F2),
        surfaceTintColor: Colors.transparent,
        title: Text(
          _text('NIR Analysis', 'NIR विश्लेषण'),
          style: const TextStyle(
            color: Color(0xFF1B2B21),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _text('Hear instructions', 'निर्देश सुनें'),
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              _speak(
                'Place the feed sample inside the chamber. Close the chamber, then press and hold the scan button.',
                'चारे का नमूना चैम्बर में रखें। चैम्बर बंद करें, फिर स्कैन बटन को दबाकर रखें।',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                _buildDeviceStatus(),
                const SizedBox(height: 18),
                if (!_showResult) ...[
                  _buildSampleForm(),
                  const SizedBox(height: 18),
                  _buildPreparationCard(),
                  const SizedBox(height: 22),
                  _buildScanButton(),
                ],
                if (_showResult) _buildResult(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceStatus() {
    final connected = widget.isDeviceConnected;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: connected ? const Color(0xFFE3F1E6) : const Color(0xFFFFECE7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            connected
                ? Icons.bluetooth_connected_rounded
                : Icons.bluetooth_disabled_rounded,
            color: connected
                ? const Color(0xFF32834C)
                : const Color(0xFFB75B4A),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              connected
                  ? _text(
                      'PARAKH-01 is ready for scanning',
                      'PARAKH-01 स्कैन के लिए तैयार है',
                    )
                  : _text(
                      'Parakh device is not connected',
                      'परख डिवाइस कनेक्ट नहीं है',
                    ),
              style: TextStyle(
                color: connected
                    ? const Color(0xFF28653B)
                    : const Color(0xFF8F493B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleForm() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _text('Sample details', 'नमूने का विवरण'),
            style: const TextStyle(
              color: Color(0xFF1B2B21),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _sampleIdController,
            decoration: InputDecoration(
              labelText: _text('Sample ID (optional)', 'नमूना आईडी (वैकल्पिक)'),
              hintText: 'Example: FEED-001',
              prefixIcon: const Icon(Icons.qr_code_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedFeed,
            decoration: InputDecoration(
              labelText: _text('Feed type', 'चारे का प्रकार'),
              prefixIcon: const Icon(Icons.grass_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Maize Silage',
                child: Text('Maize Silage'),
              ),
              DropdownMenuItem(
                value: 'Wheat Straw',
                child: Text('Wheat Straw'),
              ),
              DropdownMenuItem(
                value: 'Green Fodder',
                child: Text('Green Fodder'),
              ),
              DropdownMenuItem(
                value: 'Concentrate Feed',
                child: Text('Concentrate Feed'),
              ),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedFeed = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFC48526)),
              const SizedBox(width: 9),
              Text(
                _text('Before scanning', 'स्कैन से पहले'),
                style: const TextStyle(
                  color: Color(0xFF735B2E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _preparationStep(
            _text(
              'Spread the sample evenly in the test chamber.',
              'नमूने को टेस्ट चैम्बर में समान रूप से फैलाएँ।',
            ),
          ),
          _preparationStep(
            _text(
              'Keep the sample surface clean and still.',
              'नमूने की सतह साफ और स्थिर रखें।',
            ),
          ),
          _preparationStep(
            _text(
              'Close the chamber before starting.',
              'जाँच शुरू करने से पहले चैम्बर बंद करें।',
            ),
          ),
        ],
      ),
    );
  }

  Widget _preparationStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: CircleAvatar(radius: 3, backgroundColor: Color(0xFFC48526)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF735B2E),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    final buttonColor = _isScanning
        ? const Color(0xFF9DB5A5)
        : ParakhColors.forestGreen;

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _isScanning
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _text(
                          'Press and hold to start scanning.',
                          'स्कैन शुरू करने के लिए दबाकर रखें।',
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
          onLongPress: _isScanning
              ? null
              : () async {
                  await HapticFeedback.mediumImpact();
                  await _startScan();
                },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isScanning)
                  const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  const Icon(Icons.touch_app_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  _isScanning
                      ? _text(
                          'Analysing sample...',
                          'नमूने की जाँच हो रही है...',
                        )
                      : _text(
                          'Hold to start NIR scan',
                          'NIR स्कैन के लिए दबाकर रखें',
                        ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF174D35), Color(0xFF2F7650)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF90E09F),
                size: 45,
              ),
              const SizedBox(height: 10),
              Text(
                _text('Analysis complete', 'विश्लेषण पूरा हुआ'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _selectedFeed,
                style: const TextStyle(color: Color(0xFFDDEBE1), fontSize: 13),
              ),
              const SizedBox(height: 17),
              Text(
                '87/100',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _text('Good quality • Low risk', 'अच्छी गुणवत्ता • कम जोखिम'),
                style: const TextStyle(
                  color: Color(0xFFBCE4C4),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildMetricsCard(),
        const SizedBox(height: 18),
        _buildRecommendationCard(),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _resetScan,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              _text('Test another sample', 'दूसरे नमूने की जाँच करें'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCard() {
    final reading = _reading;

    if (reading == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        children: [
          _metricRow(
            _text('Moisture', 'नमी'),
            '${reading.moisture.toStringAsFixed(1)}%',
            _text('Normal', 'सामान्य'),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Crude protein', 'कच्चा प्रोटीन'),
            '${reading.protein.toStringAsFixed(1)}%',
            _text('Good', 'अच्छा'),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Fibre', 'फाइबर'),
            '${reading.fiber.toStringAsFixed(1)}%',
            _text('Normal', 'सामान्य'),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Fat', 'वसा'),
            '${reading.fat.toStringAsFixed(1)}%',
            _text('Good', 'अच्छा'),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Ash', 'राख'),
            '${reading.ash.toStringAsFixed(1)}%',
            _text('Normal', 'सामान्य'),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value, String status) {
    final normalizedStatus = status.toLowerCase();

    final bool isDanger =
        normalizedStatus.contains('poor') ||
        normalizedStatus.contains('high') ||
        normalizedStatus.contains('low') ||
        normalizedStatus.contains('खराब') ||
        normalizedStatus.contains('अधिक') ||
        normalizedStatus.contains('कम');

    final bool isWarning =
        normalizedStatus.contains('caution') ||
        normalizedStatus.contains('check') ||
        normalizedStatus.contains('review') ||
        normalizedStatus.contains('सावधानी') ||
        normalizedStatus.contains('जाँच');

    final Color statusColor;
    final Color statusBackground;

    if (isDanger) {
      statusColor = const Color(0xFFB54435);
      statusBackground = const Color(0xFFFBE8E4);
    } else if (isWarning) {
      statusColor = const Color(0xFF9A6815);
      statusBackground = const Color(0xFFFFF1CF);
    } else {
      statusColor = const Color(0xFF32834C);
      statusBackground = const Color(0xFFE3F1E6);
    }

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.25),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF566158),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1B2B21),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFF3D70A8),
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('Recommendation', 'सुझाव'),
                  style: const TextStyle(
                    color: Color(0xFF294F78),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _text(
                    'The feed quality is suitable. Add a balanced mineral mixture as advised by a livestock nutrition expert.',
                    'चारे की गुणवत्ता उपयुक्त है। पशु पोषण विशेषज्ञ की सलाह के अनुसार संतुलित खनिज मिश्रण मिलाएँ।',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF3D5E7C),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
