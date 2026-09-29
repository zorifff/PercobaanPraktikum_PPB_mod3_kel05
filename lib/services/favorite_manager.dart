import 'package:flutter/foundation.dart';
import '../screens/home.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;
  FavoriteManager._internal();

  static FavoriteManager get instance => _instance;

  final List<Country> _favorites = [];

  List<Country> get favoriteCountries => List.unmodifiable(_favorites);

  bool isFavorite(Country country) {
    return _favorites.any((c) => c.name == country.name);
  }

  void toggleFavorite(Country country) {
    if (isFavorite(country)) {
      _favorites.removeWhere((c) => c.name == country.name);
    } else {
      _favorites.add(country);
    }
    notifyListeners();
  }

  void removeFavorite(Country country) {
    _favorites.removeWhere((c) => c.name == country.name);
    notifyListeners();
  }
}
