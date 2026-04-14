import 'dart:convert';

class CustomFeature {
  final String id;
  String name;
  int points; // 10-40
  bool enabled;

  CustomFeature({required this.id, required this.name, this.points = 20, this.enabled = true});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'points': points, 'enabled': enabled};

  factory CustomFeature.fromJson(Map<String, dynamic> json) => CustomFeature(
    id: json['id'],
    name: json['name'],
    points: (json['points'] as num?)?.toInt() ?? 20,
    enabled: json['enabled'] ?? true,
  );

  CustomFeature copyWith({String? name, int? points, bool? enabled}) => CustomFeature(
    id: id,
    name: name ?? this.name,
    points: points ?? this.points,
    enabled: enabled ?? this.enabled,
  );
}

class Room {
  final String id;
  String name;
  String tenant;
  double sqft;
  bool hasPrivateBath;
  bool hasBalcony;
  bool hasWalkInCloset;
  bool hasParking;
  bool hasAC;
  double naturalLightScore;
  double noiseScore;
  double storageScore;
  int floorLevel; // 0 = ground/unknown, positive = floor number
  double? communalSharePct; // null = use equal share
  List<CustomFeature> customFeatures;

  Room({
    required this.id, required this.name, required this.tenant,
    this.sqft = 150, this.hasPrivateBath = false, this.hasBalcony = false,
    this.hasWalkInCloset = false, this.hasParking = false, this.hasAC = false,
    this.naturalLightScore = 5, this.noiseScore = 5, this.storageScore = 5,
    this.floorLevel = 0, this.communalSharePct,
    List<CustomFeature>? customFeatures,
  }) : customFeatures = customFeatures ?? [];

  Room copyWith({String? name, String? tenant, double? sqft, bool? hasPrivateBath,
    bool? hasBalcony, bool? hasWalkInCloset, bool? hasParking, bool? hasAC,
    double? naturalLightScore, double? noiseScore, double? storageScore, int? floorLevel,
    double? communalSharePct, List<CustomFeature>? customFeatures}) {
    return Room(
      id: id, name: name ?? this.name, tenant: tenant ?? this.tenant,
      sqft: sqft ?? this.sqft, hasPrivateBath: hasPrivateBath ?? this.hasPrivateBath,
      hasBalcony: hasBalcony ?? this.hasBalcony, hasWalkInCloset: hasWalkInCloset ?? this.hasWalkInCloset,
      hasParking: hasParking ?? this.hasParking, hasAC: hasAC ?? this.hasAC,
      naturalLightScore: naturalLightScore ?? this.naturalLightScore,
      noiseScore: noiseScore ?? this.noiseScore, storageScore: storageScore ?? this.storageScore,
      floorLevel: floorLevel ?? this.floorLevel,
      communalSharePct: communalSharePct,
      customFeatures: customFeatures ?? this.customFeatures.map((f) => f.copyWith()).toList(),
    );
  }

  /// Convenience getter: score without communal extra sqft.
  double get totalScore => computeScore();

  double computeScore({double extraSqft = 0}) {
    double score = (sqft + extraSqft) * 1.0;
    if (hasPrivateBath) score += 40;
    if (hasBalcony) score += 20;
    if (hasWalkInCloset) score += 15;
    if (hasParking) score += 30;
    if (hasAC) score += 10;
    for (final f in customFeatures) {
      if (f.enabled) score += f.points;
    }
    // Higher floors get a small bonus (view, privacy)
    if (floorLevel > 0) score += (floorLevel * 2).clamp(0, 12).toDouble();
    score += naturalLightScore * 3;
    score += noiseScore * 2;
    score += storageScore * 1.5;
    return score;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'tenant': tenant, 'sqft': sqft,
    'hasPrivateBath': hasPrivateBath, 'hasBalcony': hasBalcony,
    'hasWalkInCloset': hasWalkInCloset, 'hasParking': hasParking, 'hasAC': hasAC,
    'naturalLightScore': naturalLightScore,
    'noiseScore': noiseScore, 'storageScore': storageScore, 'floorLevel': floorLevel,
    'communalSharePct': communalSharePct,
    'customFeatures': customFeatures.map((f) => f.toJson()).toList(),
  };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'], name: json['name'], tenant: json['tenant'],
    sqft: (json['sqft'] as num).toDouble(),
    hasPrivateBath: json['hasPrivateBath'] ?? false,
    hasBalcony: json['hasBalcony'] ?? false,
    hasWalkInCloset: json['hasWalkInCloset'] ?? false,
    hasParking: json['hasParking'] ?? false,
    hasAC: json['hasAC'] ?? false,
    naturalLightScore: (json['naturalLightScore'] as num).toDouble(),
    noiseScore: (json['noiseScore'] as num).toDouble(),
    storageScore: (json['storageScore'] as num).toDouble(),
    floorLevel: (json['floorLevel'] as num?)?.toInt() ?? 0,
    communalSharePct: (json['communalSharePct'] as num?)?.toDouble(),
    customFeatures: (json['customFeatures'] as List?)
        ?.map((e) => CustomFeature.fromJson(e))
        .toList(),
  );

  static String encodeList(List<Room> rooms) =>
      jsonEncode(rooms.map((r) => r.toJson()).toList());

  static List<Room> decodeList(String source) =>
      (jsonDecode(source) as List).map((e) => Room.fromJson(e)).toList();
}