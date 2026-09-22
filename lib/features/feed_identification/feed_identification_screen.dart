import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/feed_identification_result.dart';
import '../../core/services/feed_identification_ai_service.dart';
import '../../core/theme/parakh_colors.dart';
import '../../core/services/ai_error_handler.dart';

class FeedIdentificationScreen extends StatefulWidget {
  const FeedIdentificationScreen({required this.isHindi, super.key});

  final bool isHindi;

  @override
  State<FeedIdentificationScreen> createState() =>
      _FeedIdentificationScreenState();
}

class _FeedIdentificationScreenState extends State<FeedIdentificationScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final FeedIdentificationAiService _aiService = FeedIdentificationAiService();

  static const List<String> _feedTypes = [
    'Maize Silage',
    'Wheat Straw',
    'Green Fodder',
    'Concentrate Feed',
    'Cattle Feed Pellets',
  ];

  Uint8List? _imageBytes;
  FeedIdentificationResult? _result;
  String _imageSource = 'unknown';
  String _confirmedFeed = 'Maize Silage';
  bool _isAnalysing = false;

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
        _imageSource = source == ImageSource.camera ? 'camera' : 'gallery';
        _result = null;
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
    final imageBytes = _imageBytes;

    if (imageBytes == null) {
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
      _result = null;
    });

    try {
      final result = await _aiService.analyse(
        imageBytes: imageBytes,
        imageSource: _imageSource,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
        _isAnalysing = false;

        final bestPrediction = result.bestPrediction;

        if (bestPrediction != null &&
            bestPrediction.feedType != 'Unknown' &&
            _feedTypes.contains(bestPrediction.feedType)) {
          _confirmedFeed = bestPrediction.feedType;
        }
      });
    } catch (error) {
      debugPrint('Feed identification failed: $error');
      final failure = AiFailure.fromError(error);
      if (!mounted) return;

      setState(() {
        _result = FeedIdentificationResult.modelNotConnected(
          imageSource: _imageSource,
        );
        _isAnalysing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.localizedMessage(isHindi: widget.isHindi)),
          backgroundColor: const Color(0xFFB75B4A),
        ),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageSource = 'unknown';
      _result = null;
      _isAnalysing = false;
    });
  }

  void _confirmFeed() {
    Navigator.of(context).pop(_confirmedFeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F2),
        surfaceTintColor: Colors.transparent,
        title: Text(
          _text('Identify Feed', 'चारा पहचानें'),
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
                if (_result != null) ...[
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
        color: const Color(0xFFEAF3EC),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.camera_alt_rounded, color: ParakhColors.forestGreen),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _text(
                'Take a clear, close photo of the feed in natural light. Keep only one feed type visible.',
                'प्राकृतिक रोशनी में चारे की साफ और पास से तस्वीर लें। तस्वीर में केवल एक प्रकार का चारा रखें।',
              ),
              style: const TextStyle(
                color: Color(0xFF355743),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 270,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: _imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_search_rounded,
                    size: 58,
                    color: Color(0xFF8B968E),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _text('Add a feed image', 'चारे की तस्वीर जोड़ें'),
                    style: const TextStyle(
                      color: Color(0xFF667169),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(_imageBytes!, fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton.filled(
                      onPressed: _isAnalysing ? null : _clearImage,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalysing
                ? null
                : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_rounded),
            label: Text(_text('Camera', 'कैमरा')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalysing
                ? null
                : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded),
            label: Text(_text('Gallery', 'गैलरी')),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyseButton() {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: _isAnalysing ? null : _analyseImage,
        style: FilledButton.styleFrom(
          backgroundColor: ParakhColors.forestGreen,
        ),
        icon: _isAnalysing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.image_search_rounded),
        label: Text(
          _isAnalysing
              ? _text('Checking image...', 'तस्वीर की जाँच हो रही है...')
              : _text('Identify feed type', 'चारे का प्रकार पहचानें'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _result;

    if (result == null) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFC48526),
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _text(
                    'Feed identification model not connected',
                    'चारा पहचान मॉडल कनेक्ट नहीं है',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF735B2E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _text(
              'Automatic identification will be enabled after the trained offline AI model is added. Select and confirm the feed manually for now.',
              'प्रशिक्षित ऑफलाइन AI मॉडल जोड़ने के बाद स्वचालित पहचान उपलब्ध होगी। अभी चारे का प्रकार स्वयं चुनकर पुष्टि करें।',
            ),
            style: const TextStyle(
              color: Color(0xFF667169),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _confirmedFeed,
            decoration: InputDecoration(
              labelText: _text(
                'Confirm feed type',
                'चारे के प्रकार की पुष्टि करें',
              ),
              prefixIcon: const Icon(Icons.grass_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: _feedTypes
                .map((feed) => DropdownMenuItem(value: feed, child: Text(feed)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _confirmedFeed = value;
              });
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _confirmFeed,
              style: FilledButton.styleFrom(
                backgroundColor: ParakhColors.forestGreen,
              ),
              icon: const Icon(Icons.check_rounded),
              label: Text(
                _text('Use this feed type', 'इस चारे के प्रकार का उपयोग करें'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
