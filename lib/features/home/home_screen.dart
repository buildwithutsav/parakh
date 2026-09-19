import 'package:flutter/material.dart';

import '../../core/theme/parakh_colors.dart';
import '../device/device_connection_screen.dart';
import '../analysis/nir_analysis_screen.dart';
import '../camera_analysis/camera_analysis_screen.dart';
import '../ph_analysis/ph_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.isHindi, super.key});

  final bool isHindi;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isHindi;
  bool _isDeviceConnected = false;

  @override
  void initState() {
    super.initState();
    _isHindi = widget.isHindi;
  }

  String _text(String english, String hindi) {
    return _isHindi ? hindi : english;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildWelcomeCard(),
                const SizedBox(height: 22),
                _buildSectionTitle(_text('Device status', 'डिवाइस की स्थिति')),
                const SizedBox(height: 12),
                _buildDeviceCard(),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  _text('Start an analysis', 'जाँच शुरू करें'),
                ),
                const SizedBox(height: 12),
                _buildAnalysisGrid(),
                const SizedBox(height: 24),
                _buildRecentTests(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ParakhColors.forestGreen,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 27),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PARAKH',
                style: TextStyle(
                  color: ParakhColors.forestGreen,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                _text(
                  'Better Feed, Healthier Herds',
                  'बेहतर चारा, स्वस्थ पशुधन',
                ),
                style: const TextStyle(
                  color: Color(0xFF667268),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _isHindi = !_isHindi;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDE5DA)),
            ),
            child: Text(
              _isHindi ? 'EN' : 'हिं',
              style: const TextStyle(
                color: ParakhColors.forestGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174D35), Color(0xFF2F7650)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24174D35),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('Namaste, Farmer!', 'नमस्ते, किसान!'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _text(
                    'Check your feed quality and receive useful recommendations.',
                    'चारे की गुणवत्ता जाँचें और उपयोगी सुझाव प्राप्त करें।',
                  ),
                  style: const TextStyle(
                    color: Color(0xFFE4F0E7),
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0x24FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              size: 38,
              color: Color(0xFFF1C75B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1B2B21),
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildDeviceCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE2E9DF)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bluetooth_rounded,
              color: ParakhColors.forestGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('Parakh portable device', 'परख पोर्टेबल डिवाइस'),
                  style: const TextStyle(
                    color: Color(0xFF243128),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isDeviceConnected
                      ? _text('Connected', 'कनेक्टेड')
                      : _text('Not connected', 'कनेक्ट नहीं है'),
                  style: TextStyle(
                    color: _isDeviceConnected
                        ? const Color(0xFF32834C)
                        : const Color(0xFF8A6257),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _isDeviceConnected
                ? null
                : () async {
                    final connected = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) =>
                            DeviceConnectionScreen(isHindi: _isHindi),
                      ),
                    );

                    if (!mounted || connected != true) return;

                    setState(() {
                      _isDeviceConnected = true;
                    });
                  },
            style: FilledButton.styleFrom(
              backgroundColor: ParakhColors.forestGreen,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            ),
            child: Text(
              _isDeviceConnected
                  ? _text('Connected', 'कनेक्टेड')
                  : _text('Connect', 'कनेक्ट करें'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 13,
      mainAxisSpacing: 13,
      mainAxisExtent: 155,
      children: [
        _analysisCard(
          icon: Icons.sensors_rounded,
          title: _text('NIR Scan', 'NIR स्कैन'),
          subtitle: _text('Nutrient analysis', 'पोषक तत्व जाँच'),
          color: const Color(0xFF2F7650),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NirAnalysisScreen(
                  isHindi: _isHindi,
                  isDeviceConnected: _isDeviceConnected,
                ),
              ),
            );
          },
        ),
        _analysisCard(
          icon: Icons.camera_alt_rounded,
          title: _text('Camera Test', 'कैमरा जाँच'),
          subtitle: _text('Detect impurities', 'अशुद्धियाँ पहचानें'),
          color: const Color(0xFFD17B3F),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CameraAnalysisScreen(isHindi: _isHindi),
              ),
            );
          },
        ),
        _analysisCard(
          icon: Icons.science_rounded,
          title: _text('pH Test', 'pH जाँच'),
          subtitle: _text('Scan test strip', 'टेस्ट स्ट्रिप स्कैन करें'),
          color: const Color(0xFF3D70A8),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PhAnalysisScreen(isHindi: _isHindi),
              ),
            );
          },
        ),
        _analysisCard(
          icon: Icons.auto_awesome_rounded,
          title: _text('Complete Test', 'संपूर्ण जाँच'),
          subtitle: _text('Combined result', 'संयुक्त परिणाम'),
          color: const Color(0xFF8063A6),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _analysisCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE2E9DF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF243128),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF788079), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTests() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE2E9DF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle(_text('Recent tests', 'हाल की जाँच')),
              ),
              Text(
                _text('View all', 'सभी देखें'),
                style: const TextStyle(
                  color: ParakhColors.forestGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(Icons.history_rounded, color: Color(0xFFAAB4AA), size: 35),
          const SizedBox(height: 8),
          Text(
            _text('No tests recorded yet', 'अभी कोई जाँच दर्ज नहीं है'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF747E76), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFDDEDE1),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: _text('Home', 'होम'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_rounded),
          label: _text('History', 'इतिहास'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.lightbulb_outline_rounded),
          label: _text('Advice', 'सुझाव'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          label: _text('Settings', 'सेटिंग्स'),
        ),
      ],
    );
  }
}
