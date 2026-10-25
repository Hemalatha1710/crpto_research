
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../models/coin_model.dart';

class ApiService {
  // Android Emulator uses 10.0.2.2 to access your computer.
  // static const String baseUrl = 'http://10.166.20.74:3000';
  static const String baseUrl = 'http://192.168.3.36:3000';

  Future<List<CoinModel>> fetchCoins() async {
    final uri = Uri.parse('$baseUrl/api/coins');

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

        return data
            .map(
              (json) => CoinModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();
      }

      if (response.statusCode == 429) {
        throw Exception(
          'API request limit reached. Please try again later.',
        );
      }

      throw Exception(
        'Unable to load coins. Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected API error: $e');
    }
  }

  Future<List<FlSpot>> fetchChart(
      String coinId,
      int days,
      ) async {
    final uri = Uri.parse(
      '$baseUrl/api/coins/${Uri.encodeComponent(coinId)}/chart'
          '?days=$days',
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load chart. Status: ${response.statusCode}',
      );
    }

    final data =
    jsonDecode(response.body) as Map<String, dynamic>;

    final prices = data['prices'] as List<dynamic>;

    return prices.asMap().entries.map((entry) {
      final price = entry.value as List<dynamic>;

      return FlSpot(
        entry.key.toDouble(),
        (price[1] as num).toDouble(),
      );
    }).toList();
  }
}
