
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin_model.dart';
import '../services/api_service.dart';

class MarketProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CoinModel> _coins = [];
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _watchlist = {};
  Set<String> get watchlist => _watchlist;

  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCoins() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _coins = await _apiService.fetchCoins();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInWatchlist(String coinId) {
    return _watchlist.contains(coinId);
  }

  Future<void> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    _watchlist = (prefs.getStringList('watchlist') ?? []).toSet();
    notifyListeners();
  }

  Future<void> toggleWatchlist(String coinId) async {
    if (_watchlist.contains(coinId)) {
      _watchlist.remove(coinId);
    } else {
      _watchlist.add(coinId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('watchlist', _watchlist.toList());
    notifyListeners();
  }

}
