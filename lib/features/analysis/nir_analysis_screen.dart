import 'package:flutter/material.dart';

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

  String _selectedFeed = 'Maize Silage';
  bool _isScanning = false;
  bool _showResult = false;
  DeviceReading? _reading;

  String _text(String english, String hindi) {
    return widget.isHindi ? hindi : english;
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
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _isScanning ? null : _startScan,
        style: FilledButton.styleFrom(
          backgroundColor: ParakhColors.forestGreen,
          disabledBackgroundColor: const Color(0xFF9DB5A5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: _isScanning
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.sensors_rounded),
        label: Text(
          _isScanning
              ? _text('Analysing sample...', 'नमूने की जाँच हो रही है...')
              : _text('Start NIR scan', 'NIR स्कैन शुरू करें'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
    return Row(
      children: [
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
            color: const Color(0xFFE3F1E6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Color(0xFF32834C),
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
