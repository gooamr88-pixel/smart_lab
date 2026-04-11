// ═══════════════════════════════════════════════════════════════════
//  PHYSICS EXPERIMENTS DATABASE — 100 Real Physics Experiments
// ═══════════════════════════════════════════════════════════════════
//
//  10 Categories × ~10 experiments each = 100 experiments
//  Each experiment maps to an existing simulation (simType) or 'none'
//  if the simulation is not yet implemented.
//
//  simType values:
//    'inclined_plane' → InclinedPlaneSim (tab 0)
//    'free_fall'      → FreeFallSim      (tab 1)
//    'pendulum'       → PendulumSim      (tab 2)
//    'projectile'     → ProjectileMotionSim (tab 3)
//    'waves'          → WavesSim          (tab 4)
//    'none'           → Not yet implemented (AI says "coming soon")
// ═══════════════════════════════════════════════════════════════════

/// Describes a single physics experiment in the database.
class PhysicsExperimentInfo {
  final String id;
  final String name;
  final String nameAr;
  final String category;
  final String categoryAr;
  final String formula;
  final String description;
  final String descriptionAr;
  /// Which existing simulation this experiment maps to.
  /// 'none' means no simulation is available yet.
  final String simType;
  /// Default parameters to pre-fill the simulation sliders.
  final Map<String, double> defaultParams;

  const PhysicsExperimentInfo({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.category,
    required this.categoryAr,
    required this.formula,
    required this.description,
    required this.descriptionAr,
    required this.simType,
    this.defaultParams = const {},
  });

  /// Whether this experiment has a working simulation
  bool get hasSimulation => simType != 'none';

  /// The tab index in PhysicsSimulationScreen
  int? get simTabIndex {
    switch (simType) {
      case 'inclined_plane': return 0;
      case 'free_fall': return 1;
      case 'pendulum': return 2;
      case 'projectile': return 3;
      case 'waves': return 4;
      default: return null;
    }
  }
}

/// The central physics experiments database.
class PhysicsDB {
  PhysicsDB._();

  /// All experiment names (English) that have working simulations
  static List<String> get supportedExperimentNamesEn =>
      experiments.where((e) => e.hasSimulation).map((e) => e.name).toList();

  /// All experiment names (Arabic) that have working simulations
  static List<String> get supportedExperimentNamesAr =>
      experiments.where((e) => e.hasSimulation).map((e) => e.nameAr).toList();

  /// All experiment names (English) — full list
  static List<String> get allExperimentNamesEn =>
      experiments.map((e) => e.name).toList();

  /// All experiment names (Arabic) — full list
  static List<String> get allExperimentNamesAr =>
      experiments.map((e) => e.nameAr).toList();

  /// Find an experiment by ID
  static PhysicsExperimentInfo? findById(String id) {
    try {
      return experiments.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find the best matching experiment by name (fuzzy)
  static PhysicsExperimentInfo? findByName(String query) {
    final q = query.toLowerCase().trim();
    try {
      // Exact match first
      return experiments.firstWhere(
        (e) => e.name.toLowerCase() == q || e.nameAr == q || e.id == q,
        orElse: () => experiments.firstWhere(
          (e) => e.name.toLowerCase().contains(q) ||
                 e.nameAr.contains(q) ||
                 q.contains(e.name.toLowerCase()) ||
                 q.contains(e.nameAr),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  THE 100 EXPERIMENTS
  // ═══════════════════════════════════════════════════════════════

  static const List<PhysicsExperimentInfo> experiments = [

    // ═══════════════════════════════════════════════════════════════
    //  A · MECHANICS — Forces & Motion  (15 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #1
    PhysicsExperimentInfo(
      id: 'free_fall',
      name: 'Free Fall',
      nameAr: 'السقوط الحر',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'h = ½gt²',
      description: 'An object falls from rest under gravity alone. Demonstrates acceleration due to gravity.',
      descriptionAr: 'جسم يسقط من السكون تحت تأثير الجاذبية فقط. يوضح تسارع الجاذبية الأرضية.',
      simType: 'free_fall',
      defaultParams: {'height': 20, 'mass': 2, 'gravity': 9.81},
    ),

    // #2
    PhysicsExperimentInfo(
      id: 'newtons_second_law',
      name: "Newton's Second Law (F=ma)",
      nameAr: 'قانون نيوتن الثاني',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'F = ma',
      description: 'Demonstrates the relationship between force, mass, and acceleration using a block on a surface.',
      descriptionAr: 'يوضح العلاقة بين القوة والكتلة والتسارع باستخدام جسم على سطح.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 3, 'angle': 0, 'friction': 0},
    ),

    // #3
    PhysicsExperimentInfo(
      id: 'newtons_third_law',
      name: "Newton's Third Law (Action-Reaction)",
      nameAr: 'قانون نيوتن الثالث (الفعل ورد الفعل)',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'F₁₂ = -F₂₁',
      description: 'Every action has an equal and opposite reaction. Demonstrated with two masses on a pulley.',
      descriptionAr: 'لكل فعل رد فعل مساوٍ في المقدار ومعاكس في الاتجاه. يُوضح بكتلتين على بكرة.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 3, 'mass2': 3, 'angle': 30, 'friction': 0},
    ),

    // #4
    PhysicsExperimentInfo(
      id: 'kinetic_friction',
      name: 'Kinetic Friction',
      nameAr: 'الاحتكاك الحركي',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'f = μₖ × N',
      description: 'A block slides down a rough incline. The friction force opposes the motion.',
      descriptionAr: 'جسم ينزلق على سطح مائل خشن. قوة الاحتكاك تعاكس الحركة.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 2, 'angle': 35, 'friction': 0.3, 'mass2': 0.5},
    ),

    // #5
    PhysicsExperimentInfo(
      id: 'static_friction',
      name: 'Static Friction',
      nameAr: 'الاحتكاك السكوني',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'fₛ ≤ μₛ × N',
      description: 'A block on a ramp stays still until the angle exceeds the maximum static friction.',
      descriptionAr: 'جسم على مستوى مائل يبقى ثابتاً حتى تتجاوز الزاوية أقصى احتكاك سكوني.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 2, 'angle': 20, 'friction': 0.5, 'mass2': 0.5},
    ),

    // #6
    PhysicsExperimentInfo(
      id: 'inclined_plane',
      name: 'Inclined Plane',
      nameAr: 'المستوى المائل',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'a = g(sinθ - μcosθ)',
      description: 'Classic inclined plane with adjustable angle, mass, and friction. Foundation of mechanics.',
      descriptionAr: 'المستوى المائل الكلاسيكي بزاوية وكتلة واحتكاك قابلين للتعديل. أساس الميكانيكا.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 2, 'angle': 30, 'friction': 0.2, 'mass2': 1},
    ),

    // #7
    PhysicsExperimentInfo(
      id: 'fixed_pulley',
      name: 'Fixed Pulley',
      nameAr: 'البكرة الثابتة',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'F = mg',
      description: 'A fixed pulley changes the direction of force but not its magnitude.',
      descriptionAr: 'البكرة الثابتة تغير اتجاه القوة لكن لا تغير مقدارها.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 2, 'mass2': 2, 'angle': 90, 'friction': 0},
    ),

    // #8
    PhysicsExperimentInfo(
      id: 'movable_pulley',
      name: 'Movable Pulley',
      nameAr: 'البكرة المتحركة',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'F = mg/2',
      description: 'A movable pulley halves the force needed but doubles the distance.',
      descriptionAr: 'البكرة المتحركة تقلل القوة للنصف لكن تضاعف المسافة.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 4, 'mass2': 2, 'angle': 90, 'friction': 0},
    ),

    // #9
    PhysicsExperimentInfo(
      id: 'atwood_machine',
      name: 'Atwood Machine',
      nameAr: 'ماكينة أتوود',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'a = (m₁-m₂)g / (m₁+m₂)',
      description: 'Two masses connected by string over a pulley. Classic acceleration experiment.',
      descriptionAr: 'كتلتان متصلتان بخيط على بكرة. تجربة كلاسيكية لقياس التسارع.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 3, 'mass2': 1, 'angle': 90, 'friction': 0},
    ),

    // #10
    PhysicsExperimentInfo(
      id: 'incline_with_pulley',
      name: 'Inclined Plane + Pulley System',
      nameAr: 'مستوى مائل مع بكرة',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'a = (m₁gsinθ - m₂g - f) / (m₁+m₂)',
      description: 'A block on a ramp connected to a hanging mass via a pulley — the full Newtonian setup.',
      descriptionAr: 'جسم على مستوى مائل متصل بكتلة معلقة عبر بكرة — النظام النيوتني الكامل.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 3, 'mass2': 1.5, 'angle': 30, 'friction': 0.2},
    ),

    // #11
    PhysicsExperimentInfo(
      id: 'normal_force',
      name: 'Normal Force',
      nameAr: 'القوة العمودية',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'N = mg·cosθ',
      description: 'The surface pushes back with a force perpendicular to the contact surface.',
      descriptionAr: 'السطح يدفع للخلف بقوة عمودية على سطح التلامس.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 5, 'angle': 45, 'friction': 0, 'mass2': 0.1},
    ),

    // #12
    PhysicsExperimentInfo(
      id: 'lever_mechanics',
      name: 'Lever Mechanics',
      nameAr: 'ميكانيكا الرافعة',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'F₁ × d₁ = F₂ × d₂',
      description: 'A lever amplifies force — the basis of all simple machines.',
      descriptionAr: 'الرافعة تضاعف القوة — أساس جميع الآلات البسيطة.',
      simType: 'none',
    ),

    // #13
    PhysicsExperimentInfo(
      id: 'average_velocity',
      name: 'Average Velocity',
      nameAr: 'السرعة المتوسطة',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'v̄ = Δx / Δt',
      description: 'Measure total displacement over total time to find average velocity.',
      descriptionAr: 'قياس الإزاحة الكلية على الزمن الكلي لإيجاد السرعة المتوسطة.',
      simType: 'free_fall',
      defaultParams: {'height': 10, 'mass': 1, 'gravity': 9.81},
    ),

    // #14
    PhysicsExperimentInfo(
      id: 'uniform_acceleration',
      name: 'Uniform Acceleration',
      nameAr: 'التسارع المنتظم',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'v = v₀ + at',
      description: 'Object accelerates at a constant rate. Distance grows quadratically with time.',
      descriptionAr: 'الجسم يتسارع بمعدل ثابت. المسافة تزداد تربيعياً مع الزمن.',
      simType: 'free_fall',
      defaultParams: {'height': 30, 'mass': 1, 'gravity': 9.81},
    ),

    // #15
    PhysicsExperimentInfo(
      id: 'terminal_velocity',
      name: 'Terminal Velocity (Air Resistance)',
      nameAr: 'السرعة الحدية (مقاومة الهواء)',
      category: 'Mechanics', categoryAr: 'الميكانيكا',
      formula: 'vₜ = √(2mg / ρACd)',
      description: 'A falling object reaches a constant speed when drag equals gravity.',
      descriptionAr: 'الجسم الساقط يصل لسرعة ثابتة عندما تتساوى مقاومة الهواء مع الجاذبية.',
      simType: 'free_fall',
      defaultParams: {'height': 50, 'mass': 5, 'gravity': 9.81},
    ),

    // ═══════════════════════════════════════════════════════════════
    //  B · PROJECTILES & CIRCULAR MOTION  (10 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #16
    PhysicsExperimentInfo(
      id: 'horizontal_projectile',
      name: 'Horizontal Projectile',
      nameAr: 'مقذوف أفقي',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'x = v₀t, y = ½gt²',
      description: 'An object launched horizontally falls in a parabolic arc. No initial vertical velocity.',
      descriptionAr: 'جسم مُطلق أفقياً يسقط في مسار قطعي. لا توجد سرعة رأسية ابتدائية.',
      simType: 'projectile',
      defaultParams: {'velocity': 20, 'angle': 0, 'gravity': 9.8},
    ),

    // #17
    PhysicsExperimentInfo(
      id: 'angled_projectile',
      name: 'Angled Projectile',
      nameAr: 'مقذوف بزاوية',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'R = v₀²sin2θ/g',
      description: 'A projectile launched at an angle follows a parabolic trajectory.',
      descriptionAr: 'مقذوف مُطلق بزاوية يتبع مساراً قطعياً مكافئاً.',
      simType: 'projectile',
      defaultParams: {'velocity': 25, 'angle': 45, 'gravity': 9.8},
    ),

    // #18
    PhysicsExperimentInfo(
      id: 'max_range_45',
      name: '45° Maximum Range',
      nameAr: 'أقصى مدى عند 45°',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'R_max = v₀²/g (at θ=45°)',
      description: 'Maximum range is achieved at exactly 45° launch angle (no air resistance).',
      descriptionAr: 'أقصى مدى يُحقق عند زاوية إطلاق 45° بالضبط (بدون مقاومة هواء).',
      simType: 'projectile',
      defaultParams: {'velocity': 30, 'angle': 45, 'gravity': 9.8},
    ),

    // #19
    PhysicsExperimentInfo(
      id: 'projectile_planets',
      name: 'Projectile on Different Planets',
      nameAr: 'مقذوف على كواكب مختلفة',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'R = v₀²sin2θ/g_planet',
      description: 'Compare projectile range on Earth, Moon, Mars, and Jupiter with different g values.',
      descriptionAr: 'مقارنة مدى المقذوف على الأرض والقمر والمريخ والمشتري بقيم جاذبية مختلفة.',
      simType: 'projectile',
      defaultParams: {'velocity': 25, 'angle': 45, 'gravity': 1.62},
    ),

    // #20
    PhysicsExperimentInfo(
      id: 'uniform_circular_motion',
      name: 'Uniform Circular Motion',
      nameAr: 'حركة دائرية منتظمة',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'a = v²/r',
      description: 'An object moves at constant speed in a circle — centripetal acceleration points inward.',
      descriptionAr: 'جسم يتحرك بسرعة ثابتة في مسار دائري — التسارع المركزي يتجه للداخل.',
      simType: 'none',
    ),

    // #21
    PhysicsExperimentInfo(
      id: 'centripetal_force',
      name: 'Centripetal Force',
      nameAr: 'قوة الجذب المركزي',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'F = mv²/r',
      description: 'Force directed toward center of circular path, keeping object in orbit.',
      descriptionAr: 'قوة موجهة نحو مركز المسار الدائري، تحافظ على بقاء الجسم في المدار.',
      simType: 'none',
    ),

    // #22
    PhysicsExperimentInfo(
      id: 'centrifugal_effect',
      name: 'Centrifugal Effect',
      nameAr: 'تأثير الطرد المركزي',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'F_cf = mv²/r (pseudo)',
      description: 'Apparent outward force in a rotating frame — not a real force!',
      descriptionAr: 'قوة ظاهرية للخارج في إطار مرجعي دوار — ليست قوة حقيقية!',
      simType: 'none',
    ),

    // #23
    PhysicsExperimentInfo(
      id: 'escape_velocity',
      name: 'Escape Velocity',
      nameAr: 'سرعة الإفلات',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'vₑ = √(2GM/R)',
      description: 'Minimum speed to escape a planet\'s gravity without further propulsion.',
      descriptionAr: 'أقل سرعة للإفلات من جاذبية كوكب بدون دفع إضافي.',
      simType: 'projectile',
      defaultParams: {'velocity': 50, 'angle': 80, 'gravity': 9.8},
    ),

    // #24
    PhysicsExperimentInfo(
      id: 'circular_orbit',
      name: 'Circular Orbit',
      nameAr: 'المدار الدائري',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'v = √(GM/r)',
      description: 'A satellite orbits at the exact speed where gravity equals centripetal force.',
      descriptionAr: 'قمر صناعي يدور بسرعة محددة حيث تتساوى الجاذبية مع قوة الجذب المركزي.',
      simType: 'none',
    ),

    // #25
    PhysicsExperimentInfo(
      id: 'projectile_air_resistance',
      name: 'Projectile with Air Resistance',
      nameAr: 'مقذوف مع مقاومة الهواء',
      category: 'Projectiles', categoryAr: 'المقذوفات',
      formula: 'F_drag = ½ρv²CdA',
      description: 'Real projectile with drag — range is shorter and trajectory asymmetric.',
      descriptionAr: 'مقذوف حقيقي مع مقاومة هواء — المدى أقصر والمسار غير متماثل.',
      simType: 'projectile',
      defaultParams: {'velocity': 30, 'angle': 45, 'gravity': 9.8},
    ),

    // ═══════════════════════════════════════════════════════════════
    //  C · ENERGY & WORK  (10 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #26
    PhysicsExperimentInfo(
      id: 'pe_to_ke',
      name: 'Potential to Kinetic Energy',
      nameAr: 'تحول طاقة الوضع إلى حركية',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'mgh = ½mv²',
      description: 'A ball dropped from height converts all its PE to KE at the bottom.',
      descriptionAr: 'كرة تُسقط من ارتفاع تحوّل كل طاقة وضعها إلى طاقة حركية عند القاع.',
      simType: 'free_fall',
      defaultParams: {'height': 25, 'mass': 2, 'gravity': 9.81},
    ),

    // #27
    PhysicsExperimentInfo(
      id: 'conservation_energy',
      name: 'Conservation of Mechanical Energy',
      nameAr: 'حفظ الطاقة الميكانيكية',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'KE₁ + PE₁ = KE₂ + PE₂',
      description: 'Total mechanical energy stays constant (no friction). Demonstrated on an incline.',
      descriptionAr: 'الطاقة الميكانيكية الكلية ثابتة (بدون احتكاك). تُوضح على مستوى مائل.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 2, 'angle': 40, 'friction': 0, 'mass2': 0.1},
    ),

    // #28
    PhysicsExperimentInfo(
      id: 'work_force',
      name: 'Work-Force Relationship',
      nameAr: 'الشغل والقوة',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'W = F·d·cosθ',
      description: 'Work equals force times displacement times cosine of the angle between them.',
      descriptionAr: 'الشغل يساوي القوة × الإزاحة × جيب تمام الزاوية بينهما.',
      simType: 'inclined_plane',
      defaultParams: {'mass1': 3, 'angle': 25, 'friction': 0.1, 'mass2': 0.5},
    ),

    // #29
    PhysicsExperimentInfo(
      id: 'power_machine',
      name: 'Power of a Machine',
      nameAr: 'قدرة الآلة',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'P = W/t = Fv',
      description: 'Power is the rate of doing work. Compare different machines lifting the same mass.',
      descriptionAr: 'القدرة هي معدل إنجاز الشغل. مقارنة آلات مختلفة ترفع نفس الكتلة.',
      simType: 'none',
    ),

    // #30
    PhysicsExperimentInfo(
      id: 'hookes_spring',
      name: "Hooke's Spring",
      nameAr: 'زنبرك هوك',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'F = -kx',
      description: 'Spring force is proportional to displacement. Foundation of SHM.',
      descriptionAr: 'قوة الزنبرك تتناسب طردياً مع الإزاحة. أساس الحركة التوافقية البسيطة.',
      simType: 'pendulum',
      defaultParams: {'length': 1.0, 'angle': 30, 'gravity': 9.81},
    ),

    // #31
    PhysicsExperimentInfo(
      id: 'spring_energy',
      name: 'Spring Potential Energy',
      nameAr: 'طاقة الزنبرك',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'PE = ½kx²',
      description: 'Energy stored in a compressed/stretched spring. Converts to KE when released.',
      descriptionAr: 'الطاقة المخزنة في زنبرك مضغوط/ممدود. تتحول لطاقة حركية عند الإفلات.',
      simType: 'pendulum',
      defaultParams: {'length': 0.5, 'angle': 45, 'gravity': 9.81},
    ),

    // #32
    PhysicsExperimentInfo(
      id: 'elastic_collision',
      name: 'Elastic Collision',
      nameAr: 'تصادم مرن',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'KE_before = KE_after',
      description: 'Both momentum and kinetic energy are conserved. Objects bounce off each other.',
      descriptionAr: 'كمية الحركة والطاقة الحركية محفوظتان. الأجسام ترتد عن بعضها.',
      simType: 'none',
    ),

    // #33
    PhysicsExperimentInfo(
      id: 'inelastic_collision',
      name: 'Inelastic Collision',
      nameAr: 'تصادم غير مرن',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'm₁v₁ + m₂v₂ = (m₁+m₂)v_f',
      description: 'Momentum conserved but KE is lost. Objects may stick together.',
      descriptionAr: 'كمية الحركة محفوظة لكن الطاقة الحركية تُفقد. الأجسام قد تلتصق.',
      simType: 'none',
    ),

    // #34
    PhysicsExperimentInfo(
      id: 'conservation_momentum',
      name: 'Conservation of Momentum',
      nameAr: 'حفظ كمية الحركة',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'Σp_before = Σp_after',
      description: 'Total momentum of an isolated system is always conserved.',
      descriptionAr: 'كمية الحركة الكلية لنظام معزول محفوظة دائماً.',
      simType: 'none',
    ),

    // #35
    PhysicsExperimentInfo(
      id: 'impulse_momentum',
      name: 'Impulse & Momentum',
      nameAr: 'الاندفاع والزخم',
      category: 'Energy', categoryAr: 'الطاقة',
      formula: 'J = FΔt = Δp',
      description: 'Impulse (force × time) equals change in momentum.',
      descriptionAr: 'الاندفاع (القوة × الزمن) يساوي التغير في كمية الحركة.',
      simType: 'none',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  D · PENDULUM & OSCILLATIONS  (10 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #36
    PhysicsExperimentInfo(
      id: 'simple_pendulum',
      name: 'Simple Pendulum',
      nameAr: 'البندول البسيط',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'T = 2π√(L/g)',
      description: 'A mass on a string swings back and forth. Period depends on length and gravity.',
      descriptionAr: 'كتلة على خيط تتأرجح ذهاباً وإياباً. الزمن الدوري يعتمد على الطول والجاذبية.',
      simType: 'pendulum',
      defaultParams: {'length': 1.5, 'angle': 30, 'gravity': 9.81},
    ),

    // #37
    PhysicsExperimentInfo(
      id: 'pendulum_period',
      name: 'Pendulum Period vs Length',
      nameAr: 'الزمن الدوري للبندول',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'T² ∝ L',
      description: 'The square of the period is proportional to the length. Double length = √2 × period.',
      descriptionAr: 'مربع الزمن الدوري يتناسب مع الطول. مضاعفة الطول = √2 × الزمن الدوري.',
      simType: 'pendulum',
      defaultParams: {'length': 2.0, 'angle': 20, 'gravity': 9.81},
    ),

    // #38
    PhysicsExperimentInfo(
      id: 'pendulum_length_effect',
      name: 'Pendulum Length Effect',
      nameAr: 'تأثير طول البندول',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'T = 2π√(L/g)',
      description: 'Compare pendulums of different lengths — longer = slower swing.',
      descriptionAr: 'مقارنة بندولات بأطوال مختلفة — أطول = تأرجح أبطأ.',
      simType: 'pendulum',
      defaultParams: {'length': 3.0, 'angle': 25, 'gravity': 9.81},
    ),

    // #39
    PhysicsExperimentInfo(
      id: 'pendulum_planets',
      name: 'Pendulum on Different Planets',
      nameAr: 'البندول على كواكب مختلفة',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'T = 2π√(L/g_planet)',
      description: 'Same pendulum, different gravity. Moon pendulum swings ~2.5× slower than Earth.',
      descriptionAr: 'نفس البندول، جاذبية مختلفة. بندول القمر يتأرجح أبطأ ~2.5 مرة من الأرض.',
      simType: 'pendulum',
      defaultParams: {'length': 1.5, 'angle': 30, 'gravity': 1.62},
    ),

    // #40
    PhysicsExperimentInfo(
      id: 'conical_pendulum',
      name: 'Conical Pendulum',
      nameAr: 'البندول المخروطي',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'T = 2π√(Lcosθ/g)',
      description: 'Pendulum traces a circle — combines gravity and circular motion.',
      descriptionAr: 'البندول يرسم دائرة — يجمع بين الجاذبية والحركة الدائرية.',
      simType: 'none',
    ),

    // #41
    PhysicsExperimentInfo(
      id: 'shm_spring',
      name: 'SHM — Mass on Spring',
      nameAr: 'حركة توافقية بسيطة — زنبرك',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'T = 2π√(m/k)',
      description: 'A mass oscillates on a spring with a period depending on mass and spring constant.',
      descriptionAr: 'كتلة تتذبذب على زنبرك بزمن دوري يعتمد على الكتلة وثابت الزنبرك.',
      simType: 'pendulum',
      defaultParams: {'length': 1.0, 'angle': 40, 'gravity': 9.81},
    ),

    // #42
    PhysicsExperimentInfo(
      id: 'shm_graph',
      name: 'SHM — Displacement vs Time Graph',
      nameAr: 'حركة توافقية بسيطة — رسم بياني',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'x = A·sin(ωt + φ)',
      description: 'The displacement of SHM follows a sine wave. Visualize x, v, and a over time.',
      descriptionAr: 'إزاحة الحركة التوافقية تتبع موجة جيبية. رسم x و v و a بمرور الزمن.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.0},
    ),

    // #43
    PhysicsExperimentInfo(
      id: 'damped_oscillation',
      name: 'Damped Oscillation',
      nameAr: 'اهتزاز مخمد',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'x = A·e^(-γt)·sin(ωt)',
      description: 'Oscillation amplitude decreases over time due to friction/viscosity.',
      descriptionAr: 'سعة الاهتزاز تقل بمرور الزمن بسبب الاحتكاك أو اللزوجة.',
      simType: 'pendulum',
      defaultParams: {'length': 1.5, 'angle': 45, 'gravity': 9.81},
    ),

    // #44
    PhysicsExperimentInfo(
      id: 'mechanical_resonance',
      name: 'Mechanical Resonance',
      nameAr: 'الرنين الميكانيكي',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'f_resonance = f_natural',
      description: 'When driving frequency matches natural frequency — maximum amplitude! (Tacoma bridge)',
      descriptionAr: 'عندما يتساوى تردد القوة المحركة مع التردد الطبيعي — أقصى سعة! (جسر تاكوما)',
      simType: 'waves',
      defaultParams: {'amplitude': 2.0, 'frequency': 1.0},
    ),

    // #45
    PhysicsExperimentInfo(
      id: 'double_pendulum',
      name: 'Double Pendulum',
      nameAr: 'البندول المزدوج',
      category: 'Oscillations', categoryAr: 'الاهتزازات',
      formula: 'Chaotic system',
      description: 'Extremely sensitive to initial conditions — demonstrates chaos theory!',
      descriptionAr: 'حساس للغاية للشروط الابتدائية — يوضح نظرية الفوضى!',
      simType: 'none',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  E · WAVES & SOUND  (12 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #46
    PhysicsExperimentInfo(
      id: 'transverse_wave',
      name: 'Transverse Wave',
      nameAr: 'موجة عرضية',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'v = λf',
      description: 'Oscillation is perpendicular to wave propagation — like waves on a string.',
      descriptionAr: 'الاهتزاز عمودي على اتجاه انتشار الموجة — مثل موجات الحبل.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.0},
    ),

    // #47
    PhysicsExperimentInfo(
      id: 'longitudinal_wave',
      name: 'Longitudinal Wave',
      nameAr: 'موجة طولية',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'v = λf',
      description: 'Oscillation is parallel to propagation — like sound waves in air.',
      descriptionAr: 'الاهتزاز موازٍ لاتجاه الانتشار — مثل موجات الصوت في الهواء.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.5},
    ),

    // #48
    PhysicsExperimentInfo(
      id: 'wave_speed',
      name: 'Wave Speed',
      nameAr: 'سرعة الموجة',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'v = λf = λ/T',
      description: 'Wave speed equals wavelength times frequency. Constant for a given medium.',
      descriptionAr: 'سرعة الموجة تساوي الطول الموجي × التردد. ثابتة في وسط معين.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 2.0},
    ),

    // #49
    PhysicsExperimentInfo(
      id: 'wavelength_frequency',
      name: 'Wavelength & Frequency Relationship',
      nameAr: 'العلاقة بين الطول الموجي والتردد',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'λ = v/f',
      description: 'Higher frequency means shorter wavelength at constant speed.',
      descriptionAr: 'تردد أعلى يعني طول موجي أقصر عند سرعة ثابتة.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 3.0},
    ),

    // #50
    PhysicsExperimentInfo(
      id: 'constructive_interference',
      name: 'Constructive Interference',
      nameAr: 'تداخل بنّاء',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'A_total = A₁ + A₂',
      description: 'Two waves in phase add up — double amplitude at constructive points!',
      descriptionAr: 'موجتان متوافقتان في الطور تتجمعان — سعة مضاعفة عند نقاط التداخل البنّاء!',
      simType: 'waves',
      defaultParams: {'amplitude': 1.5, 'frequency': 1.0},
    ),

    // #51
    PhysicsExperimentInfo(
      id: 'destructive_interference',
      name: 'Destructive Interference',
      nameAr: 'تداخل هدّام',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'A_total = |A₁ - A₂|',
      description: 'Two waves out of phase cancel each other — zero amplitude!',
      descriptionAr: 'موجتان متعاكستان في الطور تلغيان بعضهما — سعة صفر!',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.0},
    ),

    // #52
    PhysicsExperimentInfo(
      id: 'standing_wave',
      name: 'Standing Wave',
      nameAr: 'موجة واقفة',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'f_n = n·v/(2L)',
      description: 'Two identical waves traveling opposite directions create nodes and antinodes.',
      descriptionAr: 'موجتان متماثلتان تسيران في اتجاهين معاكسين تنتجان عقداً وبطوناً.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 2.0},
    ),

    // #53
    PhysicsExperimentInfo(
      id: 'doppler_effect',
      name: 'Doppler Effect',
      nameAr: 'تأثير دوبلر',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'f\' = f·(v±v_observer)/(v∓v_source)',
      description: 'Frequency changes when source or observer moves — ambulance siren effect!',
      descriptionAr: 'التردد يتغير عندما يتحرك المصدر أو الراصد — تأثير صفارة الإسعاف!',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.5},
    ),

    // #54
    PhysicsExperimentInfo(
      id: 'wave_reflection',
      name: 'Wave Reflection',
      nameAr: 'انعكاس الموجة',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'θᵢ = θᵣ',
      description: 'A wave bounces off a fixed boundary — may invert or stay upright.',
      descriptionAr: 'الموجة ترتد عن حد ثابت — قد تنعكس أو تبقى قائمة.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.0},
    ),

    // #55
    PhysicsExperimentInfo(
      id: 'wave_refraction',
      name: 'Wave Refraction',
      nameAr: 'انكسار الموجة',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'sinθ₁/sinθ₂ = v₁/v₂',
      description: 'Wave changes direction when entering a new medium with different speed.',
      descriptionAr: 'الموجة تغير اتجاهها عند دخول وسط جديد بسرعة مختلفة.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.5},
    ),

    // #56
    PhysicsExperimentInfo(
      id: 'air_column_resonance',
      name: 'Air Column Resonance',
      nameAr: 'رنين عمود هوائي',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'L = nλ/4 (closed), L = nλ/2 (open)',
      description: 'Sound resonates in a tube at specific lengths — determines pipe harmonics.',
      descriptionAr: 'الصوت يتردد في أنبوب عند أطوال محددة — يحدد التوافقيات.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.5, 'frequency': 2.0},
    ),

    // #57
    PhysicsExperimentInfo(
      id: 'speed_of_sound',
      name: 'Speed of Sound in Air',
      nameAr: 'سرعة الصوت في الهواء',
      category: 'Waves', categoryAr: 'الموجات',
      formula: 'v = 331 + 0.6T (m/s)',
      description: 'Sound speed in air ≈ 343 m/s at 20°C. Increases with temperature.',
      descriptionAr: 'سرعة الصوت في الهواء ≈ 343 م/ث عند 20°م. تزداد مع الحرارة.',
      simType: 'waves',
      defaultParams: {'amplitude': 1.0, 'frequency': 1.0},
    ),

    // ═══════════════════════════════════════════════════════════════
    //  F · OPTICS & LIGHT  (12 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #58
    PhysicsExperimentInfo(
      id: 'light_reflection',
      name: 'Light Reflection',
      nameAr: 'انعكاس الضوء',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'θᵢ = θᵣ',
      description: 'Angle of incidence equals angle of reflection — the first law of optics.',
      descriptionAr: 'زاوية السقوط تساوي زاوية الانعكاس — القانون الأول للبصريات.',
      simType: 'none',
    ),

    // #59
    PhysicsExperimentInfo(
      id: 'light_refraction',
      name: 'Light Refraction',
      nameAr: 'انكسار الضوء',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'n₁sinθ₁ = n₂sinθ₂',
      description: 'Light bends when passing from one medium to another — Snell\'s Law.',
      descriptionAr: 'الضوء ينحني عند الانتقال من وسط لآخر — قانون سنل.',
      simType: 'none',
    ),

    // #60
    PhysicsExperimentInfo(
      id: 'snells_law',
      name: "Snell's Law",
      nameAr: 'قانون سنل',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'n₁sinθ₁ = n₂sinθ₂',
      description: 'Quantitative relationship between incident and refracted angles at interface.',
      descriptionAr: 'العلاقة الكمية بين زاوية السقوط وزاوية الانكسار عند السطح الفاصل.',
      simType: 'none',
    ),

    // #61
    PhysicsExperimentInfo(
      id: 'total_internal_reflection',
      name: 'Total Internal Reflection',
      nameAr: 'الانعكاس الكلي الداخلي',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'θ_c = arcsin(n₂/n₁)',
      description: 'Light is completely reflected when hitting interface beyond critical angle — fiber optics basis!',
      descriptionAr: 'الضوء ينعكس كلياً عند تجاوز الزاوية الحرجة — أساس الألياف البصرية!',
      simType: 'none',
    ),

    // #62
    PhysicsExperimentInfo(
      id: 'convex_lens',
      name: 'Convex Lens',
      nameAr: 'عدسة محدبة',
      category: 'Optics', categoryAr: 'البصريات',
      formula: '1/f = 1/do + 1/di',
      description: 'Convex lens converges light rays to a focal point. Creates real or virtual images.',
      descriptionAr: 'العدسة المحدبة تجمع أشعة الضوء في نقطة بؤرية. تنتج صوراً حقيقية أو خيالية.',
      simType: 'none',
    ),

    // #63
    PhysicsExperimentInfo(
      id: 'concave_lens',
      name: 'Concave Lens',
      nameAr: 'عدسة مقعرة',
      category: 'Optics', categoryAr: 'البصريات',
      formula: '1/f = 1/do + 1/di',
      description: 'Concave lens diverges light rays. Always produces virtual, upright, smaller images.',
      descriptionAr: 'العدسة المقعرة تشتت أشعة الضوء. تنتج دائماً صوراً خيالية معتدلة مصغرة.',
      simType: 'none',
    ),

    // #64
    PhysicsExperimentInfo(
      id: 'concave_mirror',
      name: 'Concave Mirror',
      nameAr: 'مرآة مقعرة',
      category: 'Optics', categoryAr: 'البصريات',
      formula: '1/f = 1/do + 1/di',
      description: 'Concave mirror focuses light — used in telescopes, headlights, and solar furnaces.',
      descriptionAr: 'المرآة المقعرة تُركز الضوء — تُستخدم في التلسكوبات والمصابيح الأمامية.',
      simType: 'none',
    ),

    // #65
    PhysicsExperimentInfo(
      id: 'prism_dispersion',
      name: 'Prism & Dispersion',
      nameAr: 'المنشور وتحليل الضوء',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'δ = (n-1)A',
      description: 'White light splits into rainbow spectrum through a prism — Newton\'s experiment!',
      descriptionAr: 'الضوء الأبيض يتحلل لطيف قوس قزح عبر منشور — تجربة نيوتن!',
      simType: 'none',
    ),

    // #66
    PhysicsExperimentInfo(
      id: 'light_diffraction',
      name: 'Light Diffraction',
      nameAr: 'حيود الضوء',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'dsinθ = nλ',
      description: 'Light bends around edges and through slits, creating interference patterns.',
      descriptionAr: 'الضوء ينحني حول الحواف وعبر الشقوق، مُنتجاً أنماط تداخل.',
      simType: 'none',
    ),

    // #67
    PhysicsExperimentInfo(
      id: 'light_polarization',
      name: 'Light Polarization',
      nameAr: 'استقطاب الضوء',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'I = I₀cos²θ',
      description: 'Filtering light to oscillate in one plane only — Malus\'s Law.',
      descriptionAr: 'ترشيح الضوء ليهتز في مستوى واحد فقط — قانون مالوس.',
      simType: 'none',
    ),

    // #68
    PhysicsExperimentInfo(
      id: 'double_slit',
      name: 'Double-Slit Interference',
      nameAr: 'تداخل الشق المزدوج',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'y = nλD/d',
      description: 'Young\'s experiment — proves wave nature of light with bright/dark fringes.',
      descriptionAr: 'تجربة يونغ — تثبت الطبيعة الموجية للضوء بهدب مضيئة/مظلمة.',
      simType: 'none',
    ),

    // #69
    PhysicsExperimentInfo(
      id: 'myopia_hyperopia',
      name: 'Myopia & Hyperopia',
      nameAr: 'قصر النظر وطول النظر',
      category: 'Optics', categoryAr: 'البصريات',
      formula: 'P = 1/f (diopters)',
      description: 'Eye defects corrected by concave (myopia) or convex (hyperopia) lenses.',
      descriptionAr: 'عيوب النظر تُصحح بعدسة مقعرة (قصر نظر) أو محدبة (طول نظر).',
      simType: 'none',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  G · ELECTRICITY & MAGNETISM  (12 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #70
    PhysicsExperimentInfo(
      id: 'simple_circuit',
      name: 'Simple Electric Circuit',
      nameAr: 'دائرة كهربائية بسيطة',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'V = IR',
      description: 'A battery, wire, and resistor — the foundation of all circuits.',
      descriptionAr: 'بطارية وسلك ومقاومة — أساس كل الدوائر الكهربائية.',
      simType: 'none',
    ),

    // #71
    PhysicsExperimentInfo(
      id: 'ohms_law',
      name: "Ohm's Law",
      nameAr: 'قانون أوم',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'V = IR',
      description: 'Voltage is directly proportional to current for a constant resistance.',
      descriptionAr: 'الجهد يتناسب طردياً مع التيار عند مقاومة ثابتة.',
      simType: 'none',
    ),

    // #72
    PhysicsExperimentInfo(
      id: 'resistors_series',
      name: 'Resistors in Series',
      nameAr: 'مقاومات على التوالي',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'R_total = R₁ + R₂ + R₃',
      description: 'Series resistors add up. Same current flows through all resistors.',
      descriptionAr: 'المقاومات على التوالي تُجمع. نفس التيار يسري في كل المقاومات.',
      simType: 'none',
    ),

    // #73
    PhysicsExperimentInfo(
      id: 'resistors_parallel',
      name: 'Resistors in Parallel',
      nameAr: 'مقاومات على التوازي',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: '1/R = 1/R₁ + 1/R₂ + 1/R₃',
      description: 'Parallel resistors reduce total resistance. Same voltage across all.',
      descriptionAr: 'المقاومات على التوازي تقلل المقاومة الكلية. نفس الجهد على الجميع.',
      simType: 'none',
    ),

    // #74
    PhysicsExperimentInfo(
      id: 'kirchhoffs_laws',
      name: "Kirchhoff's Laws",
      nameAr: 'قوانين كيرشوف',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'ΣI = 0 (node), ΣV = 0 (loop)',
      description: 'Conservation of charge at nodes and energy around loops.',
      descriptionAr: 'حفظ الشحنة عند العقد وحفظ الطاقة حول الحلقات.',
      simType: 'none',
    ),

    // #75
    PhysicsExperimentInfo(
      id: 'capacitor_charge',
      name: 'Capacitor Charge/Discharge',
      nameAr: 'شحن وتفريغ مكثف',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'V(t) = V₀(1 - e^(-t/RC))',
      description: 'Capacitor charges exponentially through a resistor. Time constant τ = RC.',
      descriptionAr: 'المكثف يُشحن أسياً عبر مقاومة. ثابت الزمن τ = RC.',
      simType: 'none',
    ),

    // #76
    PhysicsExperimentInfo(
      id: 'magnetic_field_wire',
      name: 'Magnetic Field of a Wire',
      nameAr: 'المجال المغناطيسي لسلك',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'B = μ₀I/(2πr)',
      description: 'Current creates circular magnetic field around a wire — right-hand rule!',
      descriptionAr: 'التيار يُنتج مجالاً مغناطيسياً دائرياً حول السلك — قاعدة اليد اليمنى!',
      simType: 'none',
    ),

    // #77
    PhysicsExperimentInfo(
      id: 'solenoid_field',
      name: 'Solenoid Magnetic Field',
      nameAr: 'المجال المغناطيسي لملف',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'B = μ₀nI',
      description: 'A coil creates a uniform field inside — behaves like a bar magnet.',
      descriptionAr: 'الملف يُنتج مجالاً منتظماً بالداخل — يتصرف كمغناطيس قضيبي.',
      simType: 'none',
    ),

    // #78
    PhysicsExperimentInfo(
      id: 'magnetic_force',
      name: 'Magnetic Force on Current',
      nameAr: 'القوة المغناطيسية على تيار',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'F = BIL·sinθ',
      description: 'A current-carrying wire in a magnetic field experiences a force (motor principle).',
      descriptionAr: 'سلك يحمل تياراً في مجال مغناطيسي يتعرض لقوة (مبدأ المحرك).',
      simType: 'none',
    ),

    // #79
    PhysicsExperimentInfo(
      id: 'electromagnetic_induction',
      name: 'Electromagnetic Induction',
      nameAr: 'الحث الكهرومغناطيسي',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'ε = -NΔΦ/Δt',
      description: 'Changing magnetic flux induces voltage — Faraday\'s law (generator principle).',
      descriptionAr: 'تغير التدفق المغناطيسي يُحدث جهداً — قانون فاراداي (مبدأ المولد).',
      simType: 'none',
    ),

    // #80
    PhysicsExperimentInfo(
      id: 'transformer',
      name: 'Transformer',
      nameAr: 'المحول الكهربائي',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'V₁/V₂ = N₁/N₂',
      description: 'Steps voltage up/down by ratio of coil turns. Essential for power grids.',
      descriptionAr: 'يرفع/يخفض الجهد بنسبة عدد اللفات. أساسي في شبكات الكهرباء.',
      simType: 'none',
    ),

    // #81
    PhysicsExperimentInfo(
      id: 'coulombs_law',
      name: "Coulomb's Law",
      nameAr: 'قانون كولوم',
      category: 'Electricity', categoryAr: 'الكهرباء',
      formula: 'F = kq₁q₂/r²',
      description: 'Electrostatic force between two charges — inverse square law like gravity.',
      descriptionAr: 'القوة الكهروستاتيكية بين شحنتين — قانون التربيع العكسي كالجاذبية.',
      simType: 'none',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  H · HEAT & THERMODYNAMICS  (8 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #82
    PhysicsExperimentInfo(
      id: 'linear_expansion',
      name: 'Linear Thermal Expansion',
      nameAr: 'التمدد الخطي',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'ΔL = αL₀ΔT',
      description: 'Metals expand when heated. Bridge expansion joints prevent buckling.',
      descriptionAr: 'المعادن تتمدد عند التسخين. فواصل التمدد في الجسور تمنع الانحناء.',
      simType: 'none',
    ),

    // #83
    PhysicsExperimentInfo(
      id: 'volume_expansion',
      name: 'Volume Thermal Expansion',
      nameAr: 'التمدد الحجمي',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'ΔV = βV₀ΔT',
      description: 'Liquids expand in volume when heated — thermometer principle.',
      descriptionAr: 'السوائل تتمدد حجمياً عند التسخين — مبدأ عمل الترمومتر.',
      simType: 'none',
    ),

    // #84
    PhysicsExperimentInfo(
      id: 'conduction',
      name: 'Heat Conduction',
      nameAr: 'التوصيل الحراري',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'Q/t = kA(T₂-T₁)/L',
      description: 'Heat flows through solids from hot to cold — different rates for different materials.',
      descriptionAr: 'الحرارة تنتقل عبر الأجسام الصلبة من الساخن للبارد — معدلات مختلفة حسب المادة.',
      simType: 'none',
    ),

    // #85
    PhysicsExperimentInfo(
      id: 'convection',
      name: 'Heat Convection',
      nameAr: 'الحمل الحراري',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'Q = hAΔT',
      description: 'Hot fluid rises, cold fluid sinks — creates circulation currents.',
      descriptionAr: 'السائل الساخن يصعد والبارد ينزل — يُنتج تيارات دورانية.',
      simType: 'none',
    ),

    // #86
    PhysicsExperimentInfo(
      id: 'radiation',
      name: 'Heat Radiation',
      nameAr: 'الإشعاع الحراري',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'P = εσAT⁴',
      description: 'All objects emit thermal radiation — Stefan-Boltzmann law.',
      descriptionAr: 'كل الأجسام تُشع حرارة — قانون ستيفان-بولتزمان.',
      simType: 'none',
    ),

    // #87
    PhysicsExperimentInfo(
      id: 'heat_capacity',
      name: 'Specific Heat Capacity',
      nameAr: 'السعة الحرارية النوعية',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'Q = mcΔT',
      description: 'Amount of heat needed to raise temperature — water has highest specific heat.',
      descriptionAr: 'كمية الحرارة اللازمة لرفع درجة الحرارة — الماء له أعلى سعة حرارية نوعية.',
      simType: 'none',
    ),

    // #88
    PhysicsExperimentInfo(
      id: 'phase_change',
      name: 'Phase Change (Melting/Boiling)',
      nameAr: 'تغير الحالة (انصهار/غليان)',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'Q = mL',
      description: 'Temperature stays constant during phase transitions despite continuous heating.',
      descriptionAr: 'درجة الحرارة تبقى ثابتة أثناء تحولات الحالة رغم التسخين المستمر.',
      simType: 'none',
    ),

    // #89
    PhysicsExperimentInfo(
      id: 'first_law_thermodynamics',
      name: 'First Law of Thermodynamics',
      nameAr: 'القانون الأول للديناميكا الحرارية',
      category: 'Heat', categoryAr: 'الحرارة',
      formula: 'ΔU = Q - W',
      description: 'Energy is conserved: internal energy change = heat added minus work done.',
      descriptionAr: 'الطاقة محفوظة: تغير الطاقة الداخلية = الحرارة المضافة — الشغل المبذول.',
      simType: 'none',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  I · PRESSURE & FLUIDS  (6 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #90
    PhysicsExperimentInfo(
      id: 'atmospheric_pressure',
      name: 'Atmospheric Pressure',
      nameAr: 'الضغط الجوي',
      category: 'Fluids', categoryAr: 'الموائع',
      formula: 'P_atm = 101,325 Pa',
      description: 'Air exerts pressure in all directions — Torricelli\'s barometer experiment.',
      descriptionAr: 'الهواء يُحدث ضغطاً في كل الاتجاهات — تجربة بارومتر توريشيلي.',
      simType: 'none',
    ),

    // #91
    PhysicsExperimentInfo(
      id: 'archimedes',
      name: "Archimedes' Principle",
      nameAr: 'مبدأ أرخميدس',
      category: 'Fluids', categoryAr: 'الموائع',
      formula: 'F_b = ρ_fluid × V × g',
      description: 'Buoyant force equals weight of displaced fluid — eureka moment!',
      descriptionAr: 'قوة الطفو تساوي وزن السائل المُزاح — لحظة يوريكا!',
      simType: 'none',
    ),

    // #92
    PhysicsExperimentInfo(
      id: 'pascals_law',
      name: "Pascal's Law",
      nameAr: 'قانون باسكال',
      category: 'Fluids', categoryAr: 'الموائع',
      formula: 'F₁/A₁ = F₂/A₂',
      description: 'Pressure applied to enclosed fluid is transmitted equally — hydraulic press!',
      descriptionAr: 'الضغط المؤثر على سائل محبوس ينتقل بالتساوي — المكبس الهيدروليكي!',
      simType: 'none',
    ),

    // #93
    PhysicsExperimentInfo(
      id: 'bernoullis',
      name: "Bernoulli's Principle",
      nameAr: 'مبدأ برنولي',
      category: 'Fluids', categoryAr: 'الموائع',
      formula: 'P + ½ρv² + ρgh = const',
      description: 'Faster fluid = lower pressure — explains airplane lift and curve balls.',
      descriptionAr: 'سرعة أكبر = ضغط أقل — يُفسر رفع الطائرة والكرات المنحنية.',
      simType: 'none',
    ),

    // #94
    PhysicsExperimentInfo(
      id: 'viscosity',
      name: 'Viscosity',
      nameAr: 'اللزوجة',
      category: 'Fluids', categoryAr: 'الموائع',
      formula: 'F = ηA(dv/dy)',
      description: 'Resistance of fluid to flow — honey is more viscous than water.',
      descriptionAr: 'مقاومة السائل للسريان — العسل أكثر لزوجة من الماء.',
      simType: 'none',
    ),

    // #95
    PhysicsExperimentInfo(
      id: 'capillary_action',
      name: 'Capillary Action',
      nameAr: 'الخاصية الشعرية',
      category: 'Fluids', categoryAr: 'الموائع',
      formula: 'h = 2γcosθ/(ρgr)',
      description: 'Liquid rises in narrow tubes against gravity — plants use this!',
      descriptionAr: 'السائل يرتفع في أنابيب ضيقة ضد الجاذبية — النباتات تستخدم هذا!',
      simType: 'none',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  J · MODERN PHYSICS  (5 experiments)
    // ═══════════════════════════════════════════════════════════════

    // #96
    PhysicsExperimentInfo(
      id: 'photoelectric_effect',
      name: 'Photoelectric Effect',
      nameAr: 'التأثير الكهروضوئي',
      category: 'Modern Physics', categoryAr: 'الفيزياء الحديثة',
      formula: 'KE_max = hf - φ',
      description: 'Light ejects electrons from metal — Einstein\'s Nobel Prize experiment!',
      descriptionAr: 'الضوء يطرد إلكترونات من المعدن — تجربة جائزة نوبل لأينشتاين!',
      simType: 'none',
    ),

    // #97
    PhysicsExperimentInfo(
      id: 'rutherford',
      name: 'Rutherford Scattering',
      nameAr: 'تجربة رذرفورد',
      category: 'Modern Physics', categoryAr: 'الفيزياء الحديثة',
      formula: 'N(θ) ∝ 1/sin⁴(θ/2)',
      description: 'Alpha particles scattered by gold foil — discovered the atomic nucleus!',
      descriptionAr: 'جسيمات ألفا مبعثرة بواسطة رقاقة ذهب — اكتشاف نواة الذرة!',
      simType: 'none',
    ),

    // #98
    PhysicsExperimentInfo(
      id: 'atomic_spectra',
      name: 'Atomic Emission Spectra',
      nameAr: 'أطياف انبعاث الذرات',
      category: 'Modern Physics', categoryAr: 'الفيزياء الحديثة',
      formula: '1/λ = R(1/n₁² - 1/n₂²)',
      description: 'Each element has a unique fingerprint of spectral lines — used to identify stars!',
      descriptionAr: 'كل عنصر له بصمة فريدة من الخطوط الطيفية — تُستخدم لتحديد النجوم!',
      simType: 'none',
    ),

    // #99
    PhysicsExperimentInfo(
      id: 'wave_particle_duality',
      name: 'Wave-Particle Duality',
      nameAr: 'ازدواجية الموجة-الجسيم',
      category: 'Modern Physics', categoryAr: 'الفيزياء الحديثة',
      formula: 'λ = h/p',
      description: 'Light and matter exhibit both wave and particle properties — de Broglie relation.',
      descriptionAr: 'الضوء والمادة يُظهران خصائص موجية وجسيمية — علاقة دي بروي.',
      simType: 'none',
    ),

    // #100
    PhysicsExperimentInfo(
      id: 'millikan',
      name: "Millikan's Oil Drop Experiment",
      nameAr: 'تجربة ميليكان (قطرة الزيت)',
      category: 'Modern Physics', categoryAr: 'الفيزياء الحديثة',
      formula: 'q = ne (n = 1, 2, 3...)',
      description: 'Measured the charge of a single electron — proved charge is quantized!',
      descriptionAr: 'قياس شحنة إلكترون واحد — أثبتت أن الشحنة مكمّاة!',
      simType: 'none',
    ),
  ];
}
