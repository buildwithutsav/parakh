import 'package:flutter/material.dart';

import '../../core/theme/parakh_colors.dart';

class CompleteTestScreen extends StatefulWidget {
  const CompleteTestScreen({
    required this.isHindi,
    required this.isDeviceConnected,
    super.key,
  });

  final bool isHindi;
  final bool isDeviceConnected;

  @override
  State<CompleteTestScreen> createState() => _CompleteTestScreenState();
}

class _CompleteTestScreenState extends State<CompleteTestScreen> {
  String _selectedFeed = 'Maize Silage';
  int _activeStep = -1;
  bool _isRunning = false;
  bool _showResult = false;
  final List<bool> _completedSteps = [false, false, false, false];

  String _text(String english, String hindi) {
    return widget.isHindi ? hindi : english;
  }

  Future<void> _startCompleteTest() async {
    if (!widget.isDeviceConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Connect the Parakh device before starting the complete test.',
              'संपूर्ण जाँच शुरू करने से पहले परख डिवाइस कनेक्ट करें।',
            ),
          ),
          backgroundColor: const Color(0xFFB75B4A),
        ),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _showResult = false;
      _activeStep = 0;

      for (var i = 0; i < _completedSteps.length; i++) {
        _completedSteps[i] = false;
      }
    });

    for (var i = 0; i < _completedSteps.length; i++) {
      if (!mounted) return;

      setState(() {
        _activeStep = i;
      });

      await Future<void>.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        _completedSteps[i] = true;
      });
    }

    if (!mounted) return;

    setState(() {
      _activeStep = -1;
      _isRunning = false;
      _showResult = true;
    });
  }

  void _resetTest() {
    setState(() {
      _activeStep = -1;
      _isRunning = false;
      _showResult = false;

      for (var i = 0; i < _completedSteps.length; i++) {
        _completedSteps[i] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F2),
        surfaceTintColor: Colors.transparent,
        title: Text(
          _text('Complete Feed Test', 'संपूर्ण चारा जाँच'),
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
                _buildHeader(),
                const SizedBox(height: 18),
                if (!_showResult) ...[
                  _buildFeedSelector(),
                  const SizedBox(height: 18),
                  _buildTestSteps(),
                  const SizedBox(height: 21),
                  _buildStartButton(),
                ],
                if (_showResult) _buildFinalResult(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E386C), Color(0xFF8063A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0x24FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFF0D98C),
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    'Combined quality analysis',
                    'संयुक्त गुणवत्ता विश्लेषण',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _text(
                    'NIR, camera and pH findings are combined into one result.',
                    'NIR, कैमरा और pH परिणामों को एक संयुक्त नतीजे में बदला जाता है।',
                  ),
                  style: const TextStyle(
                    color: Color(0xFFE6DCEF),
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

  Widget _buildFeedSelector() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedFeed,
        decoration: InputDecoration(
          labelText: _text('Feed type', 'चारे का प्रकार'),
          prefixIcon: const Icon(Icons.grass_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        items: const [
          DropdownMenuItem(value: 'Maize Silage', child: Text('Maize Silage')),
          DropdownMenuItem(
            value: 'Sorghum Silage',
            child: Text('Sorghum Silage'),
          ),
          DropdownMenuItem(value: 'Green Fodder', child: Text('Green Fodder')),
          DropdownMenuItem(value: 'Mixed Feed', child: Text('Mixed Feed')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
        ],
        onChanged: _isRunning
            ? null
            : (value) {
                if (value == null) return;

                setState(() {
                  _selectedFeed = value;
                });
              },
      ),
    );
  }

  Widget _buildTestSteps() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        children: [
          _testStep(
            index: 0,
            icon: Icons.sensors_rounded,
            title: _text('NIR nutrient scan', 'NIR पोषक तत्व स्कैन'),
            subtitle: _text(
              'Moisture, protein, fibre, fat and ash',
              'नमी, प्रोटीन, फाइबर, वसा और राख',
            ),
            color: const Color(0xFF2F7650),
          ),
          _stepDivider(),
          _testStep(
            index: 1,
            icon: Icons.camera_alt_rounded,
            title: _text('Visual impurity check', 'दृश्य अशुद्धता जाँच'),
            subtitle: _text(
              'Sand, stones, mould and foreign material',
              'रेत, पत्थर, फफूंद और बाहरी पदार्थ',
            ),
            color: const Color(0xFFD17B3F),
          ),
          _stepDivider(),
          _testStep(
            index: 2,
            icon: Icons.science_rounded,
            title: _text('pH estimation', 'pH अनुमान'),
            subtitle: _text(
              'Camera-based strip colour reading',
              'कैमरा आधारित स्ट्रिप रंग जाँच',
            ),
            color: const Color(0xFF3D70A8),
          ),
          _stepDivider(),
          _testStep(
            index: 3,
            icon: Icons.hub_rounded,
            title: _text('Data fusion', 'डेटा फ्यूजन'),
            subtitle: _text(
              'Score, risk and recommendation',
              'स्कोर, जोखिम और सुझाव',
            ),
            color: const Color(0xFF8063A6),
          ),
        ],
      ),
    );
  }

  Widget _stepDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 22),
      child: Divider(height: 25),
    );
  }

  Widget _testStep({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final completed = _completedSteps[index];
    final active = _activeStep == index;

    return Row(
      children: [
        Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF26342B),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF7B847D), fontSize: 11),
              ),
            ],
          ),
        ),
        if (active)
          const SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              color: ParakhColors.forestGreen,
              strokeWidth: 3,
            ),
          )
        else
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: completed
                ? const Color(0xFF32834C)
                : const Color(0xFFB7C0B8),
          ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _isRunning ? null : _startCompleteTest,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF8063A6),
          disabledBackgroundColor: const Color(0xFFB4A5C4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(
          _isRunning
              ? _text('Running complete test...', 'संपूर्ण जाँच जारी है...')
              : _text('Start complete test', 'संपूर्ण जाँच शुरू करें'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildFinalResult() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF174D35), Color(0xFF2F7650)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.shield_rounded,
                color: Color(0xFFF0D98C),
                size: 47,
              ),
              const SizedBox(height: 10),
              Text(
                _text('FeedGuard Result', 'फीडगार्ड परिणाम'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _selectedFeed,
                style: const TextStyle(color: Color(0xFFDDEBE1)),
              ),
              const SizedBox(height: 17),
              const Text(
                '87/100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9560),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _text('LOW RISK', 'कम जोखिम'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildSummaryCard(),
        const SizedBox(height: 18),
        _buildRecommendation(),
        const SizedBox(height: 14),
        _buildOfflineSavedCard(),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _resetTest,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(_text('Start another test', 'नई जाँच शुरू करें')),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        children: [
          _summaryRow(
            _text('NIR nutrition', 'NIR पोषण'),
            _text('Good', 'अच्छा'),
            const Color(0xFF32834C),
          ),
          const Divider(height: 25),
          _summaryRow(
            _text('Visible impurities', 'दृश्य अशुद्धियाँ'),
            _text('Low', 'कम'),
            const Color(0xFF32834C),
          ),
          const Divider(height: 25),
          _summaryRow(
            _text('Estimated pH', 'अनुमानित pH'),
            '4.3',
            const Color(0xFF3D70A8),
          ),
          const Divider(height: 25),
          _summaryRow(
            _text('Overall quality', 'कुल गुणवत्ता'),
            _text('Suitable', 'उपयुक्त'),
            const Color(0xFF32834C),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
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
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildRecommendation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFFC48526)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('Farmer recommendation', 'किसान के लिए सुझाव'),
                  style: const TextStyle(
                    color: Color(0xFF735B2E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _text(
                    'The sample appears suitable for feeding. Remove any visible soil, store it in a dry covered area, and use a balanced mineral mixture according to expert advice.',
                    'नमूना खिलाने के लिए उपयुक्त दिखाई देता है। दिखाई देने वाली मिट्टी हटाएँ, इसे सूखी ढकी जगह पर रखें और विशेषज्ञ की सलाह के अनुसार संतुलित खनिज मिश्रण दें।',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF735B2E),
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

  Widget _buildOfflineSavedCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_pin_rounded, color: Color(0xFF3D70A8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _text(
                'Result prepared for offline storage',
                'परिणाम ऑफलाइन सुरक्षित करने के लिए तैयार है',
              ),
              style: const TextStyle(
                color: Color(0xFF3D5E7C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
