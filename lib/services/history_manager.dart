import 'package:flutter/foundation.dart';
import '../screens/home.dart';

class HistoryManager extends ChangeNotifier {
  static final HistoryManager _instance = HistoryManager._internal();
  factory HistoryManager() => _instance;
  HistoryManager._internal();

  static HistoryManager get instance => _instance;

  final List<Map<String, dynamic>> _history = [];

  List<Map<String, dynamic>> get historyList => List.unmodifiable(_history);

  void addHistory(Country country) {
    // Hapus entry lama dengan nama sama agar tidak duplikat
    _history.removeWhere((entry) => entry['country'].name == country.name);
    // Tambah ke awal
    _history.insert(0, {
      'country': country,
      'visitedAt': DateTime.now(),
    });
    // Batasi riwayat 100 item
    if (_history.length > 100) {
      _history.removeLast();
    }
    notifyListeners();
  }

  void removeHistory(Country country) {
    _history.removeWhere((entry) => entry['country'].name == country.name);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
