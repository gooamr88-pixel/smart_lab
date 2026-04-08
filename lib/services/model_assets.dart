/// Registry of 3D model asset paths for lab equipment.
///
/// Each tool name maps to a .glb model URL or local asset path.
/// Replace placeholder URLs with your own .glb files in assets/models/.
class ModelAssets {
  ModelAssets._();

  // ============================================================
  // 🔧 PLACEHOLDER 3D MODEL URLs
  // Replace these URLs with your own .glb files:
  //   1. Add your .glb files to: assets/models/
  //   2. Update the paths below to: 'assets/models/your_file.glb'
  //   3. Make sure pubspec.yaml includes: assets/models/
  // ============================================================

  /// Default lab table / environment model
  static const String labTable =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  /// Beaker (كأس زجاجي)
  static const String beaker =
      'https://modelviewer.dev/shared-assets/models/reflective-sphere.glb';

  /// Bunsen burner (موقد بنسن)
  static const String bunsenBurner =
      'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';

  /// Test tube (أنبوب اختبار)
  static const String testTube =
      'https://modelviewer.dev/shared-assets/models/glTF-Sample-Assets/Models/MaterialsVariantsShoe/glTF-Binary/MaterialsVariantsShoe.glb';

  /// Erlenmeyer flask (دورق مخروطي)
  static const String flask =
      'https://modelviewer.dev/shared-assets/models/glTF-Sample-Assets/Models/SheenChair/glTF-Binary/SheenChair.glb';

  /// Thermometer (ميزان حرارة)
  static const String thermometer =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  /// Sodium metal sample (عينة صوديوم)
  static const String sodium =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  /// Default fallback model
  static const String defaultModel =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  /// Physics models
  static const String physicsModel =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  /// Chemistry models 
  static const String chemistryModel =
      'https://modelviewer.dev/shared-assets/models/reflective-sphere.glb';

  /// Icon mapping for tools (used in chips and UI)
  static const Map<String, String> toolIcons = {
    'beaker': '🧪',
    'كأس': '🧪',
    'bunsen': '🔥',
    'موقد': '🔥',
    'test tube': '🧫',
    'أنبوب': '🧫',
    'flask': '⚗️',
    'دورق': '⚗️',
    'thermometer': '🌡️',
    'ميزان حرارة': '🌡️',
    'sodium': '🧂',
    'صوديوم': '🧂',
    'water': '💧',
    'ماء': '💧',
    'acid': '⚠️',
    'حمض': '⚠️',
    'wire': '🔌',
    'سلك': '🔌',
    'magnet': '🧲',
    'مغناطيس': '🧲',
    'lens': '🔍',
    'عدسة': '🔍',
    'battery': '🔋',
    'بطارية': '🔋',
  };

  /// Get the 3D model URL for a given tool name
  /// Matches against known keywords in the tool name
  static String getModelForTool(String toolName) {
    final lower = toolName.toLowerCase();
    if (lower.contains('beaker') || lower.contains('كأس')) return beaker;
    if (lower.contains('bunsen') || lower.contains('موقد')) return bunsenBurner;
    if (lower.contains('test tube') || lower.contains('أنبوب')) return testTube;
    if (lower.contains('flask') || lower.contains('دورق')) return flask;
    if (lower.contains('thermometer') || lower.contains('حرارة')) return thermometer;
    if (lower.contains('sodium') || lower.contains('صوديوم')) return sodium;
    return defaultModel;
  }

  /// Get the emoji icon for a tool name
  static String getIconForTool(String toolName) {
    final lower = toolName.toLowerCase();
    for (final entry in toolIcons.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '🔬'; // Default science icon
  }
}
