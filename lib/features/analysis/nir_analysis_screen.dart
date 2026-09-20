import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _animalType = 'cow';
  String _animalBreed = 'Not sure';
  String _animalStage = 'lactating';
  String _productionGoal = 'maintenance';
  double? _animalWeight;
  double? _dailyMilkYield;
  double? _milkFatPercent;
  String _text(String english, String hindi) {
    return widget.isHindi ? hindi : english;
  }

  @override
  void initState() {
    super.initState();
    _configureVoice();
    _loadAnimalProfile();
  }

  Future<void> _loadAnimalProfile() async {
    final preferences = await SharedPreferences.getInstance();

    final animalType = preferences.getString('animalType') ?? 'cow';
    final animalBreed = preferences.getString('animalBreed') ?? 'Not sure';
    final animalStage = preferences.getString('animalStage') ?? 'lactating';
    final productionGoal =
        preferences.getString('productionGoal') ?? 'maintenance';

    final animalWeight = double.tryParse(
      preferences.getString('animalWeight') ?? '',
    );
    final dailyMilkYield = double.tryParse(
      preferences.getString('dailyMilkYield') ?? '',
    );
    final milkFatPercent = double.tryParse(
      preferences.getString('milkFatPercent') ?? '',
    );

    if (!mounted) return;

    setState(() {
      _animalType = animalType;
      _animalBreed = animalBreed;
      _animalStage = animalStage;
      _productionGoal = productionGoal;
      _animalWeight = animalWeight;
      _dailyMilkYield = dailyMilkYield;
      _milkFatPercent = milkFatPercent;
    });
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
    _flutterTts.stop();
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

  int _riskLevel({
    required double value,
    required double goodMin,
    required double goodMax,
    required double cautionMin,
    required double cautionMax,
  }) {
    if (value >= goodMin && value <= goodMax) return 0;
    if (value >= cautionMin && value <= cautionMax) return 1;
    return 2;
  }

  List<int> _readingRiskLevels(DeviceReading reading) {
    return [
      _riskLevel(
        value: reading.moisture,
        goodMin: 60,
        goodMax: 70,
        cautionMin: 55,
        cautionMax: 75,
      ),
      _riskLevel(
        value: reading.protein,
        goodMin: 7,
        goodMax: 10,
        cautionMin: 5,
        cautionMax: 12,
      ),
      _riskLevel(
        value: reading.fiber,
        goodMin: 20,
        goodMax: 30,
        cautionMin: 15,
        cautionMax: 35,
      ),
      _riskLevel(
        value: reading.fat,
        goodMin: 2,
        goodMax: 5,
        cautionMin: 1,
        cautionMax: 6,
      ),
      _riskLevel(
        value: reading.ash,
        goodMin: 4,
        goodMax: 8,
        cautionMin: 3,
        cautionMax: 10,
      ),
    ];
  }

  int _overallRisk(DeviceReading reading) {
    final levels = _readingRiskLevels(reading);

    if (levels.contains(2)) return 2;
    if (levels.contains(1)) return 1;
    return 0;
  }

  int _goalSuitabilityScore(DeviceReading reading) {
    final levels = _readingRiskLevels(reading);

    var penalty = levels.fold<int>(
      0,
      (total, level) =>
          total +
          (level == 2
              ? 20
              : level == 1
              ? 8
              : 0),
    );

    // Prototype goal-fit rules using only the currently available readings.
    switch (_productionGoal) {
      case 'weight_gain':
        if (reading.protein < 9) penalty += 8;
        if (reading.fat < 3) penalty += 5;
        if (reading.fiber > 30) penalty += 5;
        break;

      case 'milk_yield':
        if (reading.protein < 9) penalty += 10;
        if (reading.fat < 3) penalty += 4;
        break;

      case 'milk_fat':
        if (reading.fiber < 25) penalty += 10;
        if (reading.fat < 3) penalty += 5;
        break;

      case 'maintenance':
        break;
    }

    if (_animalStage == 'lactating' && reading.protein < 8) {
      penalty += 5;
    }

    return (100 - penalty).clamp(0, 100);
  }

  String _productionGoalLabel() {
    switch (_productionGoal) {
      case 'weight_gain':
        return _text('Weight gain', 'वजन बढ़ाना');
      case 'milk_yield':
        return _text('Milk yield', 'दूध उत्पादन');
      case 'milk_fat':
        return _text('Milk fat and SNF', 'दूध वसा और SNF');
      default:
        return _text('Maintenance', 'सामान्य रखरखाव');
    }
  }

  String _animalLabel() {
    return _animalType == 'buffalo'
        ? _text('Buffalo', 'भैंस')
        : _text('Cow', 'गाय');
  }

  String _stageLabel() {
    switch (_animalStage) {
      case 'growing':
        return _text('Growing', 'बढ़ता पशु');
      case 'pregnant':
        return _text('Pregnant', 'गर्भित');
      case 'dry':
        return _text('Dry period', 'शुष्क अवधि');
      default:
        return _text('Lactating', 'दूध देने वाला');
    }
  }

  Widget _profileChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ParakhColors.forestGreen),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF355743),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets_rounded, color: ParakhColors.forestGreen),
              const SizedBox(width: 9),
              Text(
                _text('Animal context', 'पशु की जानकारी'),
                style: const TextStyle(
                  color: Color(0xFF26372D),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${_animalLabel()} • $_animalBreed',
            style: const TextStyle(color: Color(0xFF667269), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _profileChip(Icons.flag_rounded, _productionGoalLabel()),
              _profileChip(Icons.timeline_rounded, _stageLabel()),
              if (_animalWeight != null)
                _profileChip(
                  Icons.monitor_weight_outlined,
                  '${_animalWeight!.toStringAsFixed(0)} kg',
                ),
              if (_animalStage == 'lactating' && _dailyMilkYield != null)
                _profileChip(
                  Icons.water_drop_outlined,
                  '${_dailyMilkYield!.toStringAsFixed(1)} L/day',
                ),
              if (_animalStage == 'lactating' && _milkFatPercent != null)
                _profileChip(
                  Icons.percent_rounded,
                  '${_milkFatPercent!.toStringAsFixed(1)}% milk fat',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final reading = _reading;

    if (reading == null) {
      return const SizedBox.shrink();
    }

    final risk = _overallRisk(reading);
    final score = _goalSuitabilityScore(reading);

    final List<Color> resultColors;
    final Color resultAccent;
    final IconData resultIcon;
    final String resultLabel;

    if (risk == 2) {
      resultColors = const [Color(0xFF7A2E27), Color(0xFFB54435)];
      resultAccent = const Color(0xFFFFC2B8);
      resultIcon = Icons.dangerous_rounded;
      resultLabel = _text(
        'Poor quality • High risk',
        'खराब गुणवत्ता • अधिक जोखिम',
      );
    } else if (risk == 1) {
      resultColors = const [Color(0xFF795315), Color(0xFFB47B20)];
      resultAccent = const Color(0xFFFFE0A3);
      resultIcon = Icons.warning_rounded;
      resultLabel = _text(
        'Moderate quality • Check values',
        'मध्यम गुणवत्ता • मान जाँचें',
      );
    } else {
      resultColors = const [Color(0xFF174D35), Color(0xFF2F7650)];
      resultAccent = const Color(0xFFBCE4C4);
      resultIcon = Icons.verified_rounded;
      resultLabel = _text(
        'Good quality • Low risk',
        'अच्छी गुणवत्ता • कम जोखिम',
      );
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: resultColors),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Icon(resultIcon, color: resultAccent, size: 45),
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
                '$score/100',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _text('Goal Suitability Index', 'लक्ष्य उपयुक्तता सूचकांक'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _productionGoalLabel(),
                style: TextStyle(
                  color: resultAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resultLabel,
                style: TextStyle(
                  color: resultAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildAnimalContextCard(),
        const SizedBox(height: 14),
        _buildScreeningNotice(),
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

  String _metricStatus({
    required double value,
    required double goodMin,
    required double goodMax,
    required double cautionMin,
    required double cautionMax,
  }) {
    if (value >= goodMin && value <= goodMax) {
      return _text('Good', 'अच्छा');
    }

    if (value >= cautionMin && value <= cautionMax) {
      return _text('Caution', 'सावधानी');
    }

    return _text('Poor', 'खराब');
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
            _metricStatus(
              value: reading.moisture,
              goodMin: 60,
              goodMax: 70,
              cautionMin: 55,
              cautionMax: 75,
            ),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Crude protein', 'कच्चा प्रोटीन'),
            '${reading.protein.toStringAsFixed(1)}%',
            _metricStatus(
              value: reading.protein,
              goodMin: 7,
              goodMax: 10,
              cautionMin: 5,
              cautionMax: 12,
            ),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Fibre', 'फाइबर'),
            '${reading.fiber.toStringAsFixed(1)}%',
            _metricStatus(
              value: reading.fiber,
              goodMin: 20,
              goodMax: 30,
              cautionMin: 15,
              cautionMax: 35,
            ),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Fat', 'वसा'),
            '${reading.fat.toStringAsFixed(1)}%',
            _metricStatus(
              value: reading.fat,
              goodMin: 2,
              goodMax: 5,
              cautionMin: 1,
              cautionMax: 6,
            ),
          ),
          const Divider(height: 25),
          _metricRow(
            _text('Ash', 'राख'),
            '${reading.ash.toStringAsFixed(1)}%',
            _metricStatus(
              value: reading.ash,
              goodMin: 4,
              goodMax: 8,
              cautionMin: 3,
              cautionMax: 10,
            ),
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

  Widget _buildScreeningNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8C979)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF8A6418),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _text(
                'Estimated screening guidance based on the available sensor readings and animal profile. This is not a laboratory-certified result or a complete ration formulation.',
                'यह उपलब्ध सेंसर रीडिंग और पशु प्रोफाइल पर आधारित अनुमानित स्क्रीनिंग मार्गदर्शन है। यह प्रयोगशाला-प्रमाणित परिणाम या पूर्ण राशन निर्माण नहीं है।',
              ),
              style: const TextStyle(
                color: Color(0xFF74591E),
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _goalGuidance(DeviceReading reading) {
    switch (_productionGoal) {
      case 'weight_gain':
        if (reading.protein < 9 && reading.fat < 3) {
          return _text(
            'For the weight-gain goal, protein and energy indicators need attention. Discuss balancing the ration with suitable protein-rich fodder or oilseed cake and locally available energy sources. Confirm ingredients and quantities with a livestock nutrition expert.',
            'वजन बढ़ाने के लक्ष्य के लिए प्रोटीन और ऊर्जा संकेतकों पर ध्यान देने की आवश्यकता है। उपयुक्त प्रोटीन युक्त चारा या खली और स्थानीय ऊर्जा स्रोतों से राशन संतुलित करने पर पशु पोषण विशेषज्ञ से चर्चा करें। सामग्री और मात्रा विशेषज्ञ से सुनिश्चित करें।',
          );
        }

        if (reading.protein < 9) {
          return _text(
            'For weight gain, the protein indicator is below the prototype target. Ask an expert whether protein-rich green fodder, legumes or a suitable oilseed cake can help balance the complete ration.',
            'वजन बढ़ाने के लिए प्रोटीन संकेतक प्रोटोटाइप लक्ष्य से कम है। विशेषज्ञ से पूछें कि प्रोटीन युक्त हरा चारा, दलहनी चारा या उपयुक्त खली पूरे राशन को संतुलित करने में मदद कर सकती है या नहीं।',
          );
        }

        return _text(
          'The available indicators broadly support the weight-gain goal. Maintain a balanced energy, protein, fibre and mineral supply; confirm the complete ration with an expert.',
          'उपलब्ध संकेतक वजन बढ़ाने के लक्ष्य के लिए सामान्य रूप से उपयुक्त हैं। ऊर्जा, प्रोटीन, फाइबर और खनिजों का संतुलन बनाए रखें तथा पूर्ण राशन विशेषज्ञ से सुनिश्चित करें।',
        );

      case 'milk_yield':
        if (reading.protein < 9) {
          return _text(
            'For milk production, the protein indicator needs attention. Discuss balancing protein and energy sources and using an appropriate mineral mixture with a livestock nutrition expert.',
            'दूध उत्पादन के लिए प्रोटीन संकेतक पर ध्यान देने की आवश्यकता है। प्रोटीन और ऊर्जा स्रोतों को संतुलित करने तथा उपयुक्त खनिज मिश्रण के उपयोग पर पशु पोषण विशेषज्ञ से चर्चा करें।',
          );
        }

        return _text(
          'The available indicators broadly support the milk-yield goal. Continue monitoring milk output, body condition and feed intake because this scan alone cannot determine the complete ration.',
          'उपलब्ध संकेतक दूध उत्पादन के लक्ष्य के लिए सामान्य रूप से उपयुक्त हैं। दूध उत्पादन, शरीर की स्थिति और चारा सेवन की निगरानी जारी रखें क्योंकि केवल यह स्कैन पूर्ण राशन निर्धारित नहीं कर सकता।',
        );

      case 'milk_fat':
        if (reading.fiber < 25) {
          return _text(
            'For milk fat and SNF, the fibre indicator needs attention. Discuss adequate effective fibre and good-quality roughage with an expert before changing the ration.',
            'दूध वसा और SNF के लिए फाइबर संकेतक पर ध्यान देने की आवश्यकता है। राशन बदलने से पहले पर्याप्त प्रभावी फाइबर और अच्छी गुणवत्ता वाले सूखे चारे पर विशेषज्ञ से चर्चा करें।',
          );
        }

        return _text(
          'The fibre indicator broadly supports the milk-fat goal. Avoid sudden ration changes and have the full ration, milk yield and milk-fat trend reviewed by an expert.',
          'फाइबर संकेतक दूध वसा के लक्ष्य के लिए सामान्य रूप से उपयुक्त है। राशन में अचानक बदलाव न करें और पूर्ण राशन, दूध उत्पादन तथा दूध वसा की प्रवृत्ति की विशेषज्ञ से समीक्षा कराएँ।',
        );

      default:
        return _text(
          'For maintenance, keep the complete ration balanced and monitor body condition, appetite and health. Use expert advice before adding supplements.',
          'सामान्य रखरखाव के लिए पूर्ण राशन संतुलित रखें और शरीर की स्थिति, भूख तथा स्वास्थ्य की निगरानी करें। पूरक आहार जोड़ने से पहले विशेषज्ञ की सलाह लें।',
        );
    }
  }

  Widget _buildRecommendationCard() {
    final reading = _reading;

    if (reading == null) {
      return const SizedBox.shrink();
    }

    final risk = _overallRisk(reading);
    final concerns = <String>[];

    if (_riskLevel(
          value: reading.moisture,
          goodMin: 60,
          goodMax: 70,
          cautionMin: 55,
          cautionMax: 75,
        ) >
        0) {
      concerns.add(_text('moisture', 'नमी'));
    }

    if (_riskLevel(
          value: reading.protein,
          goodMin: 7,
          goodMax: 10,
          cautionMin: 5,
          cautionMax: 12,
        ) >
        0) {
      concerns.add(_text('protein', 'प्रोटीन'));
    }

    if (_riskLevel(
          value: reading.fiber,
          goodMin: 20,
          goodMax: 30,
          cautionMin: 15,
          cautionMax: 35,
        ) >
        0) {
      concerns.add(_text('fibre', 'फाइबर'));
    }

    if (_riskLevel(
          value: reading.fat,
          goodMin: 2,
          goodMax: 5,
          cautionMin: 1,
          cautionMax: 6,
        ) >
        0) {
      concerns.add(_text('fat', 'वसा'));
    }

    if (_riskLevel(
          value: reading.ash,
          goodMin: 4,
          goodMax: 8,
          cautionMin: 3,
          cautionMax: 10,
        ) >
        0) {
      concerns.add(_text('ash', 'राख'));
    }

    final String recommendation;
    final Color backgroundColor;
    final Color foregroundColor;
    final IconData icon;

    if (risk == 2) {
      recommendation = _text(
        'Keep this feed sample separate. Retest it and consult a livestock nutrition expert before feeding. Check: ${concerns.join(', ')}.',
        'इस चारे के नमूने को अलग रखें। दोबारा जाँच करें और पशु को खिलाने से पहले पशु पोषण विशेषज्ञ से सलाह लें। जाँचें: ${concerns.join(', ')}।',
      );
      backgroundColor = const Color(0xFFFBE8E4);
      foregroundColor = const Color(0xFF8F352C);
      icon = Icons.report_problem_rounded;
    } else if (risk == 1) {
      recommendation = _text(
        'Some values need attention. Review ${concerns.join(', ')} and test the sample again before regular use.',
        'कुछ मानों पर ध्यान देने की आवश्यकता है। ${concerns.join(', ')} की समीक्षा करें और नियमित उपयोग से पहले नमूने की दोबारा जाँच करें।',
      );
      backgroundColor = const Color(0xFFFFF1CF);
      foregroundColor = const Color(0xFF795315);
      icon = Icons.warning_amber_rounded;
    } else {
      recommendation = _text(
        'The tested values are within the expected range. Continue normal use and follow your livestock nutrition plan.',
        'जाँचे गए मान अपेक्षित सीमा में हैं। सामान्य उपयोग जारी रखें और अपनी पशु पोषण योजना का पालन करें।',
      );
      backgroundColor = const Color(0xFFE3F1E6);
      foregroundColor = const Color(0xFF286B3E);
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor, size: 27),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('Recommendation', 'सुझाव'),
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  recommendation,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                Divider(
                  height: 24,
                  color: foregroundColor.withValues(alpha: 0.25),
                ),
                Text(
                  _text('Goal-based guidance', 'लक्ष्य आधारित मार्गदर्शन'),
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _goalGuidance(reading),
                  style: TextStyle(
                    color: foregroundColor,
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
