

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'result.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isLoading = false;

  Future<void> _analyzeImage() async {
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('https://kuiper-sun-sariwai-api.hf.space/predict');

    try {
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          widget.imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Increased timeout for "cold starts"
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));

      if (streamedResponse.statusCode == 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);



        // Extract all the data from the response
        String status = decodedResponse['status'] ?? 'Error';
        String eyePrediction = decodedResponse['eye_prediction'] ?? 'Not Found';
        String gillPrediction = decodedResponse['gill_prediction'] ?? 'Not Found';
        // Use ?? 0.0 to provide a default value if the score is missing
        double eyeScore = (decodedResponse['eye_score'] as num?)?.toDouble() ?? 0.0;
        double gillScore = (decodedResponse['gill_score'] as num?)?.toDouble() ?? 0.0;

        if (mounted) {
          Navigator.pushReplacement( // Use pushReplacement for better navigation flow
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                imagePath: widget.imagePath,
                status: status,
                // Pass the new data to the ResultScreen
                eyePrediction: eyePrediction,
                gillPrediction: gillPrediction,
                eyeScore: eyeScore,
                gillScore: gillScore,
              ),
            ),
          );
        }
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        print("Server Error [${streamedResponse.statusCode}]: $errorBody");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error: Could not get a valid response.')),
          );
        }
      }
    } catch (e, stacktrace) {
      print("================== HTTP REQUEST FAILED ==================");
      print("URL: $uri");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: $e");
      print("Stacktrace: $stacktrace");
      print("=========================================================");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection failed. Please check your internet and try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: Image.file(File(widget.imagePath), fit: BoxFit.contain)),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () =>
                    Navigator.popUntil(context, ModalRoute.withName('/')),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A3332),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: const Color(0xFF0A3332).withOpacity(0.5),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  'Analyze Image',
                  style: TextStyle(
                    fontFamily: 'CovikSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}