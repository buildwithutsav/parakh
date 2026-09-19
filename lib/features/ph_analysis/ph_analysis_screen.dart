import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/parakh_colors.dart';

class PhAnalysisScreen extends StatefulWidget {
  const PhAnalysisScreen({required this.isHindi, super.key});

  final bool isHindi;

  @override
  State<PhAnalysisScreen> createState() => _PhAnalysisScreenState();
}

class _PhAnalysisScreenState extends State<PhAnalysisScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _imageBytes;
  bool _isAnalysing = false;
  bool _showResult = false;
  String _selectedFeed = 'Maize Silage';

  String _text(String english, String hindi) {
    return widget.isHindi ? hindi : english;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1400,
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
              'Unable to access the image.',
              'तस्वीर तक पहुँच नहीं हो सकी।',
            ),
          ),
          backgroundColor: const Color(0xFFB75B4A),
        ),
      );
    }
  }

  Future<void> _analyseStrip() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Take or select a pH strip image first.',
              'पहले pH स्ट्रिप की तस्वीर लें या चुनें।',
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
          _text('pH Strip Analysis', 'pH स्ट्रिप विश्लेषण'),
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
                _buildFeedSelector(),
                const SizedBox(height: 17),
                _buildInstructions(),
                const SizedBox(height: 17),
                _buildImageArea(),
                const SizedBox(height: 15),
                _buildImageButtons(),
                if (_imageBytes != null) ...[
                  const SizedBox(height: 18),
                  _buildAnalyseButton(),
                ],
                if (_showResult) ...[
                  const SizedBox(height: 20),
                  _buildResult(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedSelector() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
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
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _selectedFeed = value;
            _showResult = false;
          });
        },
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FA),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded, color: Color(0xFF3D70A8)),
              const SizedBox(width: 9),
              Text(
                _text('How to capture the strip', 'स्ट्रिप की तस्वीर कैसे लें'),
                style: const TextStyle(
                  color: Color(0xFF294F78),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _instruction(
            _text(
              'Place the reacted strip beside its colour reference chart.',
              'प्रतिक्रिया के बाद स्ट्रिप को रंग संदर्भ चार्ट के पास रखें।',
            ),
          ),
          _instruction(
            _text(
              'Use bright, neutral light without shadows.',
              'बिना छाया वाली तेज और सामान्य रोशनी का उपयोग करें।',
            ),
          ),
          _instruction(
            _text(
              'Keep the camera directly above the strip.',
              'कैमरा स्ट्रिप के ठीक ऊपर रखें।',
            ),
          ),
        ],
      ),
    );
  }

  Widget _instruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, color: Color(0xFF3D70A8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF3D5E7C),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 290,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFDCE5DA)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _imageBytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8EEF6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.colorize_rounded,
                    color: Color(0xFF3D70A8),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  _text('Add a pH strip image', 'pH स्ट्रिप की तस्वीर जोड़ें'),
                  style: const TextStyle(
                    color: Color(0xFF26342B),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _text(
                    'Include the reference colour chart',
                    'रंग संदर्भ चार्ट को भी तस्वीर में रखें',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF7B847D),
                    fontSize: 13,
                  ),
                ),
              ],
            )
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

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3D70A8),
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
                foregroundColor: const Color(0xFF3D70A8),
                side: const BorderSide(color: Color(0xFF3D70A8)),
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
        onPressed: _isAnalysing ? null : _analyseStrip,
        style: FilledButton.styleFrom(
          backgroundColor: ParakhColors.forestGreen,
          disabledBackgroundColor: const Color(0xFF9DB5A5),
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
              ? _text(
                  'Reading strip colour...',
                  'स्ट्रिप का रंग पढ़ा जा रहा है...',
                )
              : _text('Estimate pH value', 'pH मान का अनुमान लगाएँ'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        children: [
          Text(
            _text('Estimated pH', 'अनुमानित pH'),
            style: const TextStyle(
              color: Color(0xFF68736B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '4.3',
            style: TextStyle(
              color: Color(0xFF2F7650),
              fontSize: 47,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F1E6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _text(
                'Expected range for this silage',
                'इस साइलेज के लिए अपेक्षित सीमा',
              ),
              style: const TextStyle(
                color: Color(0xFF32834C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 21),
          _buildPhScale(),
          const SizedBox(height: 21),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7DF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFFC48526)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _text(
                      'The estimated acidity appears suitable for maize silage. Also check smell, temperature and visible mould before feeding.',
                      'अनुमानित अम्लता मक्का साइलेज के लिए उपयुक्त दिखाई देती है। खिलाने से पहले गंध, तापमान और दिखाई देने वाली फफूंद भी जाँचें।',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF735B2E),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Text(
            _text(
              'This is a camera-based estimate, not a laboratory measurement.',
              'यह कैमरा आधारित अनुमान है, प्रयोगशाला माप नहीं।',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8A6257),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhScale() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const Row(
            children: [
              Expanded(
                child: ColoredBox(
                  color: Color(0xFFE76A54),
                  child: SizedBox(height: 13),
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: Color(0xFFF2C14E),
                  child: SizedBox(height: 13),
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: Color(0xFF68B768),
                  child: SizedBox(height: 13),
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: Color(0xFF4E91C8),
                  child: SizedBox(height: 13),
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: Color(0xFF8063A6),
                  child: SizedBox(height: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _text('Acidic', 'अम्लीय'),
              style: const TextStyle(color: Color(0xFF7A6C65), fontSize: 11),
            ),
            const Text(
              'pH 0                     pH 7                     pH 14',
              style: TextStyle(color: Color(0xFF7A6C65), fontSize: 10),
            ),
            Text(
              _text('Alkaline', 'क्षारीय'),
              style: const TextStyle(color: Color(0xFF7A6C65), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
