import 'package:flutter/material.dart';
import '../models/experiment.dart';
import '../services/model_assets.dart';

/// Provider managing the 3D virtual lab state
class LabProvider extends ChangeNotifier {
  Experiment? _experiment;
  final List<LabTool> _placedTools = [];
  String? _selectedModelUrl;
  int _selectedToolIndex = -1;

  // Getters
  Experiment? get experiment => _experiment;
  List<LabTool> get placedTools => List.unmodifiable(_placedTools);
  String get selectedModelUrl => _selectedModelUrl ?? ModelAssets.labTable;
  int get selectedToolIndex => _selectedToolIndex;
  bool get allToolsPlaced =>
      _experiment != null && _placedTools.length == _experiment!.tools.length;

  /// Load an experiment into the lab
  void loadExperiment(Experiment experiment) {
    _experiment = experiment;
    _placedTools.clear();
    _selectedModelUrl = ModelAssets.labTable;
    _selectedToolIndex = -1;
    notifyListeners();
  }

  /// Select a tool to view its 3D model
  void selectTool(int index) {
    if (_experiment == null || index < 0 || index >= _experiment!.tools.length) return;

    _selectedToolIndex = index;
    final tool = _experiment!.tools[index];
    _selectedModelUrl = ModelAssets.getModelForTool(tool.name);
    notifyListeners();
  }

  /// Place a tool on the lab table
  void placeTool(LabTool tool) {
    if (!_placedTools.contains(tool)) {
      _placedTools.add(tool);
      notifyListeners();
    }
  }

  /// Check if a specific tool has been placed
  bool isToolPlaced(LabTool tool) => _placedTools.contains(tool);

  /// Show the lab table model
  void showLabTable() {
    _selectedModelUrl = ModelAssets.labTable;
    _selectedToolIndex = -1;
    notifyListeners();
  }

  /// Reset the lab state
  void resetLab() {
    _experiment = null;
    _placedTools.clear();
    _selectedModelUrl = null;
    _selectedToolIndex = -1;
    notifyListeners();
  }
}
