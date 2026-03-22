import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'iap_service.dart';
import 'room.dart';
import 'split_result.dart';

// TODO: set to false before release
const _kDebugUnlockAll = false;

const _kRoomsKey = 'saved_rooms';
const _kRentKey = 'saved_rent';
const _kIapKey = 'iap_unlocked';
const _kIapConfigsKey = 'iap_configs_unlocked';
const _kAddressKey = 'saved_address';
const _kConfigsKey = 'saved_configs';
const _kRecentAddressesKey = 'recent_addresses';

// ─── Saved Configuration ─────────────────────────────────────────────────────

class SavedConfig {
  final String id;
  final String name;
  final List<Room> rooms;
  final double totalRent;
  final String address;

  SavedConfig({
    required this.id,
    required this.name,
    required this.rooms,
    required this.totalRent,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'rooms': rooms.map((r) => r.toJson()).toList(),
    'totalRent': totalRent, 'address': address,
  };

  factory SavedConfig.fromJson(Map<String, dynamic> json) => SavedConfig(
    id: json['id'], name: json['name'],
    rooms: (json['rooms'] as List).map((r) => Room.fromJson(r)).toList(),
    totalRent: (json['totalRent'] as num).toDouble(),
    address: json['address'] ?? '',
  );

  static String encodeList(List<SavedConfig> configs) =>
      jsonEncode(configs.map((c) => c.toJson()).toList());

  static List<SavedConfig> decodeList(String source) =>
      (jsonDecode(source) as List).map((e) => SavedConfig.fromJson(e)).toList();
}

// ─── AppState ────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();
  final iapService = IapService();
  List<Room> _rooms = [];
  double _totalRent = 2500;
  bool _iapUnlocked = false;
  bool _iapConfigsUnlocked = false;
  bool _loaded = false;
  String _address = '';
  List<SavedConfig> _savedConfigs = [];
  List<String> _recentAddresses = [];

  List<Room> get rooms => _rooms;
  double get totalRent => _totalRent;
  bool get iapUnlocked => _kDebugUnlockAll || _iapUnlocked;
  bool get iapConfigsUnlocked => _kDebugUnlockAll || _iapConfigsUnlocked;
  bool get loaded => _loaded;
  String get address => _address;
  List<SavedConfig> get savedConfigs => List.unmodifiable(_savedConfigs);
  List<String> get recentAddresses => List.unmodifiable(_recentAddresses);

  List<SplitResult> get results => calculateSplit(rooms: _rooms, totalRent: _totalRent);

  AppState() { _loadFromPrefs(); }

  /// Call after [_loadFromPrefs] completes to connect the real IAP store.
  Future<void> initIap() => iapService.init(
    pdfAlreadyUnlocked: _iapUnlocked,
    configsAlreadyUnlocked: _iapConfigsUnlocked,
    onPdfPurchased: unlockIap,
    onConfigsPurchased: unlockConfigsIap,
  );

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = prefs.getString(_kRoomsKey);
    if (roomsJson != null) {
      _rooms = Room.decodeList(roomsJson);
    } else {
      _rooms = [
        Room(id: _uuid.v4(), name: 'Room 1', tenant: 'Roommate 1', sqft: 180, naturalLightScore: 7),
        Room(id: _uuid.v4(), name: 'Room 2', tenant: 'Roommate 2', sqft: 140, naturalLightScore: 4),
      ];
    }
    _totalRent = prefs.getDouble(_kRentKey) ?? 2500;
    _iapUnlocked = prefs.getBool(_kIapKey) ?? false;
    _iapConfigsUnlocked = prefs.getBool(_kIapConfigsKey) ?? false;
    _address = prefs.getString(_kAddressKey) ?? '';
    final recentsJson = prefs.getString(_kRecentAddressesKey);
    if (recentsJson != null) _recentAddresses = List<String>.from(jsonDecode(recentsJson) as List);
    final configsJson = prefs.getString(_kConfigsKey);
    if (configsJson != null) _savedConfigs = SavedConfig.decodeList(configsJson);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRoomsKey, Room.encodeList(_rooms));
    await prefs.setDouble(_kRentKey, _totalRent);
    await prefs.setString(_kAddressKey, _address);
  }

  Future<void> _saveConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kConfigsKey, SavedConfig.encodeList(_savedConfigs));
  }

  void setTotalRent(double rent) { _totalRent = rent; notifyListeners(); _save(); }
  void setAddress(String a) {
    _address = a;
    final trimmed = a.trim();
    if (trimmed.isNotEmpty && !_recentAddresses.contains(trimmed)) {
      _recentAddresses = [trimmed, ..._recentAddresses.take(9)].toList();
      _saveRecentAddresses();
    }
    notifyListeners(); _save();
  }

  Future<void> _saveRecentAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRecentAddressesKey, jsonEncode(_recentAddresses));
  }

  void addRoom() {
    _rooms.add(Room(id: _uuid.v4(), name: 'Room ${_rooms.length + 1}', tenant: 'Roommate ${_rooms.length + 1}'));
    notifyListeners(); _save();
  }

  void removeRoom(String id) { _rooms.removeWhere((r) => r.id == id); notifyListeners(); _save(); }

  void updateRoom(String id, Room updated) {
    final idx = _rooms.indexWhere((r) => r.id == id);
    if (idx != -1) { _rooms[idx] = updated; notifyListeners(); _save(); }
  }

  void reorderRooms(int oldIdx, int newIdx) {
    if (newIdx > oldIdx) newIdx--;
    final room = _rooms.removeAt(oldIdx);
    _rooms.insert(newIdx, room);
    notifyListeners(); _save();
  }

  // ─── IAP ────────────────────────────────────────────────────────────────────

  Future<void> unlockIap() async {
    _iapUnlocked = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIapKey, true);
    notifyListeners();
  }

  Future<void> unlockConfigsIap() async {
    _iapConfigsUnlocked = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIapConfigsKey, true);
    notifyListeners();
  }

  // ─── Saved Configurations ───────────────────────────────────────────────────

  void saveCurrentConfig(String name) {
    final config = SavedConfig(
      id: _uuid.v4(),
      name: name.trim().isNotEmpty ? name.trim() : 'Config ${_savedConfigs.length + 1}',
      rooms: List.from(_rooms),
      totalRent: _totalRent,
      address: _address,
    );
    _savedConfigs.add(config);
    notifyListeners();
    _saveConfigs();
  }

  void loadConfig(String id) {
    final config = _savedConfigs.where((c) => c.id == id).firstOrNull;
    if (config == null) return;
    _rooms = List.from(config.rooms);
    _totalRent = config.totalRent;
    _address = config.address;
    notifyListeners();
    _save();
  }

  void deleteConfig(String id) {
    _savedConfigs.removeWhere((c) => c.id == id);
    notifyListeners();
    _saveConfigs();
  }

  // ─── Reset ───────────────────────────────────────────────────────────────────

  void reset() {
    _rooms = [
      Room(id: _uuid.v4(), name: 'Room 1', tenant: 'Roommate 1', sqft: 180, naturalLightScore: 7),
      Room(id: _uuid.v4(), name: 'Room 2', tenant: 'Roommate 2', sqft: 140, naturalLightScore: 4),
    ];
    _totalRent = 2500;
    _address = '';
    notifyListeners(); _save();
  }
}
