import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();

    final usersBox = await Hive.openBox('users');
    await Hive.openBox('scans');

    print("Users count: ${usersBox.length}");
    print("Users keys: ${usersBox.keys.toList()}");
  }
}