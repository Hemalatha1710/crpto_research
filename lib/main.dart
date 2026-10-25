import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/providers/market_provider.dart';
import 'package:task/screens/home_page.dart';

void main() {
  runApp(    ChangeNotifierProvider(
    create: (_) => MarketProvider()..loadWatchlist(),
    child: const MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Research',
      home: const HomeScreen(),
    );
  }
}


