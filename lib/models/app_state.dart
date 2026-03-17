import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'room.dart';
import 'split_result.dart';

const _kRoomsKey = 'saved_rooms';
const _kRentKey = 'saved_rent';
const _kIapKey = 'iap_unlocked';
const _kIapConfigsKey = 'iap_configs_unlocked';
const _kAddressKey = 'saved_address';
const _kConfigsKey = 'saved_configs';

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
  List<Room> _rooms = [];
  double _totalRent = 2500;
  bool _iapUnlocked = false;
  bool _iapConfigsUnlocked = false;
  bool _loaded = false;
  String _address = '';
  List<SavedConfig> _savedConfigs = [];

  List<Room> get rooms => _rooms;
  double get totalRent => _totalRent;
  bool get iapUnlocked => _iapUnlocked;
  bool get iapConfigsUnlocked => _iapConfigsUnlocked;
  bool get loaded => _loaded;
  String get address => _address;
  List<SavedConfig> get savedConfigs => List.unmodifiable(_savedConfigs);

  List<SplitResult> get results => calculateSplit(rooms: _rooms, totalRent: _totalRent);

  AppState() { _loadFromPrefs(); }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = prefs.getString(_kRoomsKey);
    if (roomsJson != null) {
      _rooms = Room.decodeList(roomsJson);
    } else {
      _rooms = [
        Room(id: _uuid.v4(), name: 'Room 1', tenant: 'Alex', sqft: 180, naturalLightScore: 7),
        Room(id: _uuid.v4(), name: 'Room 2', tenant: 'Jordan', sqft: 140, naturalLightScore: 4),
      ];
    }
    _totalRent = prefs.getDouble(_kRentKey) ?? 2500;
    _iapUnlocked = prefs.getBool(_kIapKey) ?? false;
    _iapConfigsUnlocked = prefs.getBool(_kIapConfigsKey) ?? false;
    _address = prefs.getString(_kAddressKey) ?? '';
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
  void setAddress(String a) { _address = a; notifyListeners(); _save(); }

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
      Room(id: _uuid.v4(), name: 'Room 1', tenant: 'Alex', sqft: 180, naturalLightScore: 7),
      Room(id: _uuid.v4(), name: 'Room 2', tenant: 'Jordan', sqft: 140, naturalLightScore: 4),
    ];
    _totalRent = 2500;
    _address = '';
    notifyListeners(); _save();
  }
}
