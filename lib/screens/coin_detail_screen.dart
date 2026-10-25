
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/coin_model.dart';
import '../services/api_service.dart';

class CoinDetailScreen extends StatefulWidget {
  final CoinModel coin;

  const CoinDetailScreen({
    super.key,
    required this.coin,
  });

  @override
  State<CoinDetailScreen> createState() =>
      _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  final ApiService _apiService = ApiService();

  List<FlSpot> _chartSpots = [];
  bool _isLoading = true;
  String? _error;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spots = await _apiService.fetchChart(
        widget.coin.id,
        _days,
      );

      if (!mounted) return;

      setState(() {
        _chartSpots = spots;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load price chart.';
        _isLoading = false;
      });
    }
  }

  String _formatNumber(double value) {
    if (value >= 1e12) {
      return '\$${(value / 1e12).toStringAsFixed(2)}T';
    }
    if (value >= 1e9) {
      return '\$${(value / 1e9).toStringAsFixed(2)}B';
    }
    if (value >= 1e6) {
      return '\$${(value / 1e6).toStringAsFixed(2)}M';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  Widget _stat(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF20283A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;

    return Scaffold(
      backgroundColor: const Color(0xFF101522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101522),
        title: Text(
          '${coin.name} (${coin.symbol.toUpperCase()})',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (coin.image.isNotEmpty)
            Center(
              child: Image.network(
                coin.image,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.currency_bitcoin, size: 60),
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '\$${coin.price.toStringAsFixed(coin.price < 1 ? 6 : 2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${coin.priceChange.toStringAsFixed(2)}% (24h)',
              style: TextStyle(
                fontSize: 16,
                color: coin.priceChange >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Price Chart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [1, 7, 30].map((days) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${days}D'),
                  selected: _days == days,
                  onSelected: (_) {
                    setState(() => _days = days);
                    _loadChart();
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _error != null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: _loadChart,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : _chartSpots.isEmpty
                ? const Center(
              child: Text(
                'No chart data available',
                style: TextStyle(color: Colors.white),
              ),
            )
                : LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: const LineTouchData(
                  enabled: true,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartSpots,
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.greenAccent
                          .withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Market Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _stat('Market Cap', _formatNumber(coin.marketCap)),
              _stat('24h Volume', _formatNumber(coin.volume)),
              _stat(
                'Circulating Supply',
                coin.circulatingSupply?.toStringAsFixed(2) ?? 'N/A',
              ),
              _stat(
                'Total Supply',
                coin.totalSupply?.toStringAsFixed(2) ?? 'N/A',
              ),
              _stat(
                'Max Supply',
                coin.maxSupply?.toStringAsFixed(2) ?? 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
