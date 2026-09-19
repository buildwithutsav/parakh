import 'package:flutter/material.dart';

import '../../core/theme/parakh_colors.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({required this.isHindi, super.key});

  final bool isHindi;

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  bool _isScanning = false;
  bool _deviceFound = false;
  bool _isConnecting = false;
  bool _isConnected = false;

  String _text(String english, String hindi) {
    return widget.isHindi ? hindi : english;
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
      _deviceFound = false;
      _isConnected = false;
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _deviceFound = true;
    });
  }

  Future<void> _connectDevice() async {
    setState(() {
      _isConnecting = true;
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isConnecting = false;
      _isConnected = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _text(
            'Parakh device connected successfully.',
            'परख डिवाइस सफलतापूर्वक कनेक्ट हो गया।',
          ),
        ),
        backgroundColor: ParakhColors.forestGreen,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  void _disconnectDevice() {
    setState(() {
      _isConnected = false;
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
          _text('Connect device', 'डिवाइस कनेक्ट करें'),
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
                _buildConnectionIllustration(),
                const SizedBox(height: 24),
                Text(
                  _text(
                    'Connect your Parakh device',
                    'अपने परख डिवाइस को कनेक्ट करें',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1B2B21),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  _text(
                    'Turn on the portable device and keep it close to your phone.',
                    'पोर्टेबल डिवाइस चालू करें और इसे अपने फोन के पास रखें।',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6F796F),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                _buildInstructionCard(),
                const SizedBox(height: 22),
                _buildScanButton(),
                const SizedBox(height: 18),
                if (_isScanning) _buildScanningCard(),
                if (_deviceFound && !_isScanning) _buildDeviceCard(),
                const SizedBox(height: 20),
                _buildOfflineNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionIllustration() {
    return Center(
      child: Container(
        width: 126,
        height: 126,
        decoration: const BoxDecoration(
          color: Color(0xFFE1EEE4),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.bluetooth_searching_rounded,
              color: ParakhColors.forestGreen,
              size: 62,
            ),
            Positioned(
              right: 13,
              bottom: 15,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _isConnected
                      ? const Color(0xFF49A465)
                      : const Color(0xFFF1C75B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF5F7F2), width: 4),
                ),
                child: Icon(
                  _isConnected ? Icons.check_rounded : Icons.power_settings_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        children: [
          _instructionRow(
            number: '1',
            text: _text(
              'Switch on the Parakh portable device.',
              'परख पोर्टेबल डिवाइस चालू करें।',
            ),
          ),
          const SizedBox(height: 16),
          _instructionRow(
            number: '2',
            text: _text(
              'Enable Bluetooth on your phone.',
              'अपने फोन में ब्लूटूथ चालू करें।',
            ),
          ),
          const SizedBox(height: 16),
          _instructionRow(
            number: '3',
            text: _text(
              'Tap scan and select PARAKH-01.',
              'स्कैन दबाएँ और PARAKH-01 चुनें।',
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionRow({required String number, required String text}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFE1EEE4),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: ParakhColors.forestGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF344039),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: _isScanning || _isConnected ? null : _scanForDevices,
        style: FilledButton.styleFrom(
          backgroundColor: ParakhColors.forestGreen,
          disabledBackgroundColor: const Color(0xFF9DB5A5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: Icon(
          _isScanning ? Icons.bluetooth_searching_rounded : Icons.radar_rounded,
        ),
        label: Text(
          _isScanning
              ? _text('Scanning...', 'स्कैन हो रहा है...')
              : _text('Scan for device', 'डिवाइस खोजें'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildScanningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: ParakhColors.forestGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _text(
                'Searching for nearby Parakh devices...',
                'आस-पास के परख डिवाइस खोजे जा रहे हैं...',
              ),
              style: const TextStyle(
                color: Color(0xFF536058),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: _isConnected
              ? const Color(0xFF69A77B)
              : const Color(0xFFE0E8DD),
          width: _isConnected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: const Color(0xFFE1EEE4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isConnected
                  ? Icons.bluetooth_connected_rounded
                  : Icons.bluetooth_rounded,
              color: ParakhColors.forestGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARAKH-01',
                  style: TextStyle(
                    color: Color(0xFF243128),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isConnected
                      ? _text('Connected', 'कनेक्टेड')
                      : _text('Parakh device found', 'परख डिवाइस मिल गया'),
                  style: TextStyle(
                    color: _isConnected
                        ? const Color(0xFF32834C)
                        : const Color(0xFF707A72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_isConnecting)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: ParakhColors.forestGreen,
                strokeWidth: 3,
              ),
            )
          else
            OutlinedButton(
              onPressed: _isConnected ? _disconnectDevice : _connectDevice,
              style: OutlinedButton.styleFrom(
                foregroundColor: _isConnected
                    ? const Color(0xFFB45545)
                    : ParakhColors.forestGreen,
                side: BorderSide(
                  color: _isConnected
                      ? const Color(0xFFD9A49C)
                      : ParakhColors.forestGreen,
                ),
              ),
              child: Text(
                _isConnected
                    ? _text('Disconnect', 'डिस्कनेक्ट')
                    : _text('Connect', 'कनेक्ट'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfflineNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.offline_bolt_rounded,
            color: Color(0xFFC48526),
            size: 23,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _text(
                'Internet is not required. Device readings will be received and saved offline.',
                'इंटरनेट की आवश्यकता नहीं है। डिवाइस की रीडिंग ऑफलाइन प्राप्त और सुरक्षित की जाएगी।',
              ),
              style: const TextStyle(
                color: Color(0xFF735B2E),
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
}
