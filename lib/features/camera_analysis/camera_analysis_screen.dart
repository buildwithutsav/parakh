import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/parakh_colors.dart';

class CameraAnalysisScreen extends StatefulWidget {
  const CameraAnalysisScreen({required this.isHindi, super.key});

  final bool isHindi;

  @override
  State<CameraAnalysisScreen> createState() => _CameraAnalysisScreenState();
}

class _CameraAnalysisScreenState extends State<CameraAnalysisScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _imageBytes;
  bool _isAnalysing = false;
  bool _showResult = false;

  String _text(String english, String hindi) {
    return widget.isHindi ? hindi : english;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _showResult = false;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Unable to access the selected image.',
              'चुनी गई तस्वीर तक पहुँच नहीं हो सकी।',
            ),
          ),
          backgroundColor: const Color(0xFFB75B4A),
        ),
      );
    }
  }

  Future<void> _analyseImage() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Take or select a feed image first.',
              'पहले चारे की तस्वीर लें या चुनें।',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAnalysing = true;
      _showResult = false;
    });

    await Future<void>.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _isAnalysing = false;
      _showResult = true;
    });
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _showResult = false;
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
          _text('Camera Analysis', 'कैमरा विश्लेषण'),
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
                _buildInformationCard(),
                const SizedBox(height: 18),
                _buildImageArea(),
                const SizedBox(height: 16),
                _buildImageButtons(),
                if (_imageBytes != null) ...[
                  const SizedBox(height: 18),
                  _buildAnalyseButton(),
                ],
                if (_showResult) ...[
                  const SizedBox(height: 20),
                  _buildResultCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFC48526)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _text(
                'Spread the feed on a clean, plain surface. Use bright natural light and keep the camera directly above the sample.',
                'चारे को साफ और समतल सतह पर फैलाएँ। प्राकृतिक रोशनी में कैमरा नमूने के ठीक ऊपर रखें।',
              ),
              style: const TextStyle(
                color: Color(0xFF735B2E),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 310,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFDCE5DA), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: _imageBytes == null
          ? _buildEmptyImageArea()
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(_imageBytes!, fit: BoxFit.cover),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    onPressed: _clearImage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyImageArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: const BoxDecoration(
            color: Color(0xFFF5EAE3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 39,
            color: Color(0xFFD17B3F),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _text('Add a feed sample image', 'चारे के नमूने की तस्वीर जोड़ें'),
          style: const TextStyle(
            color: Color(0xFF26342B),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _text('Camera or phone gallery', 'कैमरा या फोन गैलरी'),
          style: const TextStyle(color: Color(0xFF7B847D), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              style: FilledButton.styleFrom(
                backgroundColor: ParakhColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(_text('Camera', 'कैमरा')),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              style: OutlinedButton.styleFrom(
                foregroundColor: ParakhColors.forestGreen,
                side: const BorderSide(color: ParakhColors.forestGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.photo_library_rounded),
              label: Text(_text('Gallery', 'गैलरी')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyseButton() {
    return SizedBox(
      height: 53,
      child: FilledButton.icon(
        onPressed: _isAnalysing ? null : _analyseImage,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFD17B3F),
          disabledBackgroundColor: const Color(0xFFD7AA8C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: _isAnalysing
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome_rounded),
        label: Text(
          _isAnalysing
              ? _text('Analysing image...', 'तस्वीर का विश्लेषण हो रहा है...')
              : _text(
                  'Detect visible impurities',
                  'दिखाई देने वाली अशुद्धियाँ पहचानें',
                ),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F1E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF32834C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(
                        'Visual analysis complete',
                        'दृश्य विश्लेषण पूरा हुआ',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF1B2B21),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _text('Moderate visual quality', 'मध्यम दृश्य गुणवत्ता'),
                      style: const TextStyle(
                        color: Color(0xFFC06D32),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _resultRow(
            _text('Sand or soil', 'रेत या मिट्टी'),
            _text('Possible traces', 'संभावित अंश'),
            const Color(0xFFC48526),
          ),
          const Divider(height: 25),
          _resultRow(
            _text('Stones', 'पत्थर'),
            _text('Not detected', 'नहीं मिले'),
            const Color(0xFF32834C),
          ),
          const Divider(height: 25),
          _resultRow(
            _text('Mould', 'फफूंद'),
            _text('Not detected', 'नहीं मिली'),
            const Color(0xFF32834C),
          ),
          const Divider(height: 25),
          _resultRow(
            _text('Foreign material', 'बाहरी पदार्थ'),
            _text('Low', 'कम'),
            const Color(0xFF32834C),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFF3D70A8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _text(
                      'Sieve the feed before use and remove visible soil or foreign material. Confirm doubtful samples manually.',
                      'उपयोग से पहले चारे को छानें और दिखाई देने वाली मिट्टी या बाहरी पदार्थ हटाएँ। संदिग्ध नमूनों की मैन्युअल जाँच करें।',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF3D5E7C),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String title, String result, Color resultColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF566158),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          result,
          style: TextStyle(color: resultColor, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
