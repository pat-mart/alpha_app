import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {

  bool? _isRed = false;

  static final ThemeViewModel _instance = ThemeViewModel._();

  ThemeViewModel._();

  factory ThemeViewModel() => _instance;

  Future<void> toggleTheme([bool notify=true]) async {

    final sharedPrefs = await SharedPreferences.getInstance();

    _isRed = sharedPrefs.getBool('red');

    _isRed ??= false;

    await sharedPrefs.setBool('red', _isRed!);

    if(notify) notifyListeners();
  }

  Future<bool> get isRed async {
    final sharedPrefs = await SharedPreferences.getInstance();

    return sharedPrefs.getBool('red') ?? false;
  }
}