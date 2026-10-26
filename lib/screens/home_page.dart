





import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coin_model.dart';
import '../providers/market_provider.dart';
import 'coin_detail_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';
  String _sortBy = 'Market Cap';
  String _selectedFilter = 'All';

  static const Color _background = Color(0xFF111318);
  static const Color _surface = Color(0xFF1B1E25);
  static const Color _border = Color(0xFF30343D);
  static const Color _secondary = Color(0xFF9CA3AF);
  static const Color _textSecondary = Color(0xFF9CA3AF);
  static const Color _green = Color(0xFF36B37E);
  static const Color _red = Color(0xFFE45B64);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MarketProvider>().fetchCoins();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        titleSpacing: 18,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crypto Market',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Market prices and performance',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: _secondary,
              ),
            ),
          ],
        ),
                actions: [
          Consumer<MarketProvider>(
            builder: (context, provider, child) {
              final hasWatchlist = provider.coins.any(
                    (coin) => provider.isInWatchlist(coin.id),
              );

              return IconButton(
                tooltip: 'My Watchlist',
                icon: Icon(
                  hasWatchlist ? Icons.star : Icons.star_border,
                  color: hasWatchlist ? Colors.amber : _textSecondary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WatchlistScreen(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MarketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.coins.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white70,
                strokeWidth: 2,
              ),
            );
          }

          if (provider.errorMessage != null &&
              provider.coins.isEmpty) {
            return _buildError(
              provider.errorMessage!,
              provider.fetchCoins,
            );
          }

          final coins = provider.coins.where((coin) {
            final query = _searchQuery.trim().toLowerCase();

            final matchesSearch =
                coin.name.toLowerCase().contains(query) ||
                    coin.symbol.toLowerCase().contains(query);

            final matchesFilter =
                _selectedFilter == 'All' ||
                    (_selectedFilter == 'Gainers' &&
                        coin.priceChange > 0) ||
                    (_selectedFilter == 'Losers' &&
                        coin.priceChange < 0);

            return matchesSearch && matchesFilter;
          }).toList();

          coins.sort((a, b) {
            switch (_sortBy) {
              case 'Price: High to Low':
                return b.price.compareTo(a.price);
              case 'Price: Low to High':
                return a.price.compareTo(b.price);
              default:
                return b.marketCap.compareTo(a.marketCap);
            }
          });

          final totalMarketCap = provider.coins.fold<double>(
            0,
                (sum, coin) => sum + coin.marketCap,
          );

          final gainers = provider.coins
              .where((coin) => coin.priceChange > 0)
              .length;

          final losers = provider.coins
              .where((coin) => coin.priceChange < 0)
              .length;

          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: _surface,
            onRefresh: provider.fetchCoins,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildMarketOverview(
                  totalMarketCap,
                  provider.coins.length,
                  gainers,
                  losers,
                ),
                const SizedBox(height: 22),

                const Text(
                  'Explore coins',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                _buildSearchField(),
                const SizedBox(height: 12),

                _buildFilters(),
                const SizedBox(height: 18),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'All cryptocurrencies',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'Sort by ',
                      style: TextStyle(
                        color: _secondary,
                        fontSize: 12,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _sortBy,
                      dropdownColor: _surface,
                      underline: const SizedBox.shrink(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: _secondary,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Market Cap',
                          child: Text('Market cap'),
                        ),
                        DropdownMenuItem(
                          value: 'Price: High to Low',
                          child: Text('Price: high to low'),
                        ),
                        DropdownMenuItem(
                          value: 'Price: Low to High',
                          child: Text('Price: low to high'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (coins.isEmpty)
                  _buildEmptyState()
                else
                  _buildCoinList(coins, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketOverview(
      double marketCap,
      int totalCoins,
      int gainers,
      int losers,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total market cap',
            style: TextStyle(
              fontSize: 13,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '\$${_formatCompact(marketCap)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 15),
          Row(
            children: [
              _summaryItem('Coins', '$totalCoins', Colors.white),
              _summaryItem('Gainers', '$gainers', _green),
              _summaryItem('Losers', '$losers', _red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Search by name or symbol',
        hintStyle: const TextStyle(
          color: _secondary,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: _secondary,
          size: 21,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
          icon: const Icon(
            Icons.close,
            color: _secondary,
            size: 19,
          ),
        ),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _filterButton('All'),
        const SizedBox(width: 8),
        _filterButton('Gainers'),
        const SizedBox(width: 8),
        _filterButton('Losers'),
      ],
    );
  }

  Widget _filterButton(String label) {
    final selected = _selectedFilter == label;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() => _selectedFilter = label);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFF30343D) : null,
          foregroundColor: selected ? Colors.white : _secondary,
          side: BorderSide(
            color: selected ? Colors.white30 : _border,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          visualDensity: VisualDensity.compact,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCoinList(
      List<CoinModel> coins,
      MarketProvider provider,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: coins.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          indent: 66,
          color: _border,
        ),
        itemBuilder: (context, index) {
          final coin = coins[index];
          final saved = provider.isInWatchlist(coin.id);

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoinDetailScreen(coin: coin),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              child: Row(
                children: [
                  _coinImage(coin),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coin.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coin.symbol.toUpperCase(),
                          style: const TextStyle(
                            color: _secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${_formatPrice(coin.price)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${coin.priceChange >= 0 ? '+' : ''}${coin.priceChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: coin.priceChange >= 0 ? _green : _red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => provider.toggleWatchlist(coin.id),
                    icon: Icon(
                      saved ? Icons.star : Icons.star_border,
                      size: 20,
                      color: saved ? Colors.amber : _secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _coinImage(CoinModel coin) {
    return CircleAvatar(
      radius: 19,
      backgroundColor: const Color(0xFF292D35),
      backgroundImage: coin.image.isNotEmpty
          ? NetworkImage(coin.image)
          : null,
      child: coin.image.isEmpty
          ? const Icon(
        Icons.currency_bitcoin,
        color: Colors.white70,
        size: 20,
      )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            color: _secondary,
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'No coins found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try a different search or filter.',
            style: TextStyle(
              color: _secondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: _secondary,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1) {
      return price.toStringAsFixed(2);
    }
    if (price >= 0.01) {
      return price.toStringAsFixed(4);
    }
    return price.toStringAsFixed(6);
  }

  String _formatCompact(double value) {
    if (value >= 1e12) {
      return '${(value / 1e12).toStringAsFixed(2)}T';
    }
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(2)}B';
    }
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(2)}M';
    }
    if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }
}
