class DetectedTranslation {
  const DetectedTranslation({
    required this.originalText,
    required this.translatedText,
    required this.confidence,
  });

  final String originalText;
  final String translatedText;
  final double confidence;
}
