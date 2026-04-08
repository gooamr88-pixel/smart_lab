import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/huggingface_service.dart';

/// Provider for managing AI-generated images with caching state
class ImageGenProvider extends ChangeNotifier {
  final HuggingFaceService _hfService = HuggingFaceService();

  // LRU memory cache — keeps at most _maxCacheSize entries
  // LinkedHashMap maintains insertion order for LRU eviction
  static const int _maxCacheSize = 8;
  final Map<String, Uint8List> _memoryCache = {};
  final List<String> _accessOrder = []; // tracks LRU order
  final Map<String, bool> _loadingStates = {};
  final Map<String, bool> _errorStates = {};

  /// Check if an image is currently being generated
  bool isLoading(String key) => _loadingStates[key] ?? false;

  /// Check if an image generation failed
  bool hasError(String key) => _errorStates[key] ?? false;

  /// Get a cached image by key (also marks as recently used)
  Uint8List? getImage(String key) {
    if (_memoryCache.containsKey(key)) {
      // Move to end of access order (most recently used)
      _accessOrder.remove(key);
      _accessOrder.add(key);
    }
    return _memoryCache[key];
  }

  /// Check if HF service is available
  bool get isConfigured => _hfService.isConfigured;

  /// Evict oldest entries if cache exceeds max size
  void _evictIfNeeded() {
    while (_memoryCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.removeAt(0);
      _memoryCache.remove(oldest);
    }
  }

  /// Generate (or retrieve cached) image for a given prompt key and prompt text.
  /// [key] is a short identifier like 'welcome', 'chemistry', 'physics'
  /// [prompt] is the full text prompt for image generation
  Future<void> generateImage(String key, String prompt) async {
    // Already cached in memory
    if (_memoryCache.containsKey(key)) return;

    // Already loading
    if (_loadingStates[key] == true) return;

    _loadingStates[key] = true;
    _errorStates[key] = false;
    notifyListeners();

    final bytes = await _hfService.generateImage(prompt);

    if (bytes != null) {
      _memoryCache[key] = bytes;
      _accessOrder.remove(key);
      _accessOrder.add(key);
      _evictIfNeeded();
      _errorStates[key] = false;
    } else {
      _errorStates[key] = true;
    }

    _loadingStates[key] = false;
    notifyListeners();
  }

  /// Preload multiple images at once (e.g., on app start)
  Future<void> preloadImages(Map<String, String> keyPromptPairs) async {
    final futures = keyPromptPairs.entries.map((entry) {
      return generateImage(entry.key, entry.value);
    });
    await Future.wait(futures);
  }

  /// Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
    _loadingStates.clear();
    _errorStates.clear();
    notifyListeners();
  }

  /// Clear disk cache
  Future<void> clearDiskCache() async {
    await _hfService.clearCache();
    clearMemoryCache();
  }
}
