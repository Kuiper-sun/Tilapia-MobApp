

import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final String status;
  final String eyePrediction;
  final String gillPrediction;
  final double eyeScore;
  final double gillScore;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.status,
    this.eyePrediction = 'Not Found',
    this.gillPrediction = 'Not Found',
    this.eyeScore = 0.0,
    this.gillScore = 0.0,
  });

  Color getStatusColor() {
    switch (status) {
      case 'Fresh':
        return const Color(0xFF14A66C);
      case 'Not Fresh':
        return const Color(0xFFD66A4E);
      case 'Old':
        return const Color(0xFF735E59);
      case 'No Fish Detected':
        return Colors.blueGrey;
      case 'Incomplete Detection':
        return Colors.orange.shade700; // A warning color
      default:
        return Colors.grey;
    }
  }

  String getStatusDescription() {
    switch (status) {
      case 'Fresh':
        return 'This tilapia looks fresh and good to eat.';
      case 'Not Fresh':
        return 'This fish isn’t at its best. Use with caution.';
      case 'Old':
        return 'This tilapia appears old. Avoid consuming it.';
      case 'No Fish Detected':
        return 'No tilapia eye and gill was detected. Please use a clear, close-up photo of the fish.';

      case 'Incomplete Detection':
        return 'Warning: Both the eye and gill must be clearly visible for a complete analysis. Please try again with a better photo.';
      default:
        return 'Could not determine freshness. Please try again with a clearer image showing the eye and gill.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();
    final description = getStatusDescription();

    final String eyeScorePercent = eyeScore > 0 ? '(${(eyeScore * 100).toStringAsFixed(1)}%)' : '';
    final String gillScorePercent = gillScore > 0 ? '(${(gillScore * 100).toStringAsFixed(1)}%)' : '';

    final bool showDetails = status == 'Fresh' || status == 'Not Fresh' || status == 'Old';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                  ),
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
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showDetails ? 'The tilapia is' : 'Analysis Result',
                        style: const TextStyle(
                          fontFamily: 'CovikSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF103937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontFamily: 'CovikSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFFF8F8F8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (showDetails)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Analysis Details', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Eye Prediction:', style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
                                  Text('$eyePrediction $eyeScorePercent', style: const TextStyle(fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Gill Prediction:', style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
                                  Text('$gillPrediction $gillScorePercent', style: const TextStyle(fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(description, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF103937))),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: Color(0xFF103937),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A3932),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, ModalRoute.withName('/camera'));
                        },
                        child: const Text(
                          'Analyze Another Fish',
                          style: TextStyle(
                            fontFamily: 'CovikSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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