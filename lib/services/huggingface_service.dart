import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../core/utils/env_config.dart';

/// Service for generating AI images via Hugging Face Inference API
/// with intelligent local disk caching to avoid redundant API calls.
class HuggingFaceService {
  // Using SDXL for high-quality image generation
  static const String _modelId =
      'stabilityai/stable-diffusion-xl-base-1.0';
  static const String _apiUrl =
      'https://api-inference.huggingface.co/models/$_modelId';

  static const Duration _timeout = Duration(seconds: 60);
  static const String _cacheDir = 'hf_image_cache';

  /// Check if HF API key is configured
  bool get isConfigured => EnvConfig.hfKey.isNotEmpty;

  /// Generate an image from a text prompt.
  /// Returns the raw image bytes (PNG).
  /// Uses disk cache — same prompt returns cached image instantly.
  Future<Uint8List?> generateImage(String prompt) async {
    // 1. Check cache first
    final cached = await _getCachedImage(prompt);
    if (cached != null) return cached;

    // 2. Call HF API
    if (!isConfigured) return null;

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer ${EnvConfig.hfKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'inputs': prompt,
              'parameters': {
                'width': 1024,
                'height': 576,
                'num_inference_steps': 30,
                'guidance_scale': 7.5,
              },
              'options': {
                'wait_for_model': true,
              },
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('image') == true) {
        final bytes = response.bodyBytes;
        // Cache the result
        await _cacheImage(prompt, bytes);
        return bytes;
      }

      // Model might be loading — return null gracefully
      return null;
    } catch (e) {
      debugPrint('[HuggingFaceService] Image generation failed: $e');
      return null;
    }
  }

  /// Get the cache directory path
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDir');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Generate a deterministic filename from the prompt
  String _hashPrompt(String prompt) {
    final bytes = utf8.encode(prompt.trim().toLowerCase());
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  /// Check if a cached image exists for this prompt
  Future<Uint8List?> _getCachedImage(String prompt) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/${_hashPrompt(prompt)}.png');
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('[HuggingFaceService] Cache read error: $e');
    }
    return null;
  }

  /// Save image bytes to disk cache
  Future<void> _cacheImage(String prompt, Uint8List bytes) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/${_hashPrompt(prompt)}.png');
      await file.writeAsBytes(bytes);
    } catch (e) {
      debugPrint('[HuggingFaceService] Cache write error: $e');
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      final dir = await _getCacheDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[HuggingFaceService] Cache clear error: $e');
    }
  }
}

/// Pre-built, curated prompts for stunning lab imagery
class ImagePrompts {
  ImagePrompts._();

  static const String welcome =
      'A breathtaking futuristic virtual science laboratory portal, '
      'holographic displays floating in space, glowing neon blue and cyan particles, '
      'dark background with deep space atmosphere, volumetric lighting, '
      'ultra detailed digital art, 8k resolution, cinematic';

  static const String chemistry =
      'A stunning futuristic chemistry laboratory, glowing beakers with '
      'vibrant neon chemical reactions in cyan and emerald green, '
      'holographic periodic table floating above, dark sleek environment, '
      'volumetric fog, dramatic rim lighting, ultra detailed, 8k, cinematic';

  static const String physics =
      'A breathtaking futuristic physics laboratory, electromagnetic fields '
      'visualized as glowing purple and blue energy arcs, floating particles, '
      'quantum mechanics visualization, dark environment with neon accents, '
      'laser beams, holographic equations, ultra detailed, 8k, cinematic';

  static const String labEnvironment =
      'Interior of a high-tech virtual science lab, sleek dark metallic surfaces, '
      'holographic tool displays on glass panels, glowing workbench with '
      'scientific instruments, neon cyan accent lighting, moody atmosphere, '
      'ultra detailed 3D render, 8k, cinematic composition';

  /// Generate a dynamic prompt for a specific experiment
  static String forExperiment(String name, String subject) {
    return 'A stunning visualization of the scientific experiment "$name" '
        'in $subject, photorealistic rendering of lab equipment in action, '
        'dramatic lighting with glowing reactions, dark futuristic lab environment, '
        'volumetric light rays, ultra detailed, 8k, cinematic';
  }
}
