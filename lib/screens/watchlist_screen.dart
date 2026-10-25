import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/market_provider.dart';
import 'coin_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101522),
        foregroundColor: Colors.white,
        title: const Text(
          'My Watchlist ⭐',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<MarketProvider>(
        builder: (context, provider, child) {
          final coins = provider.coins
              .where((coin) =>
              provider.isInWatchlist(coin.id))
              .toList();

          if (coins.isEmpty) {
            return const Center(
              child: Text(
                'No coins in your watchlist.\nTap ⭐ to add coins.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: coins.length,
            itemBuilder: (context, index) {
              final coin = coins[index];

              return Card(
                color: const Color(0xFF20283A),
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: coin.image.isNotEmpty
                        ? NetworkImage(coin.image)
                        : null,
                    child: coin.image.isEmpty
                        ? const Icon(Icons.currency_bitcoin)
                        : null,
                  ),
                  title: Text(
                    coin.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    coin.symbol.toUpperCase(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${coin.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          provider.toggleWatchlist(coin.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoinDetailScreen(coin: coin),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}