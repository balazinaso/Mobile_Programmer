import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';
import 'crypto_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Default theme mode
  Currency _selectedCurrency = Currency.USD; // Default currency

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeCurrency(Currency newCurrency) {
    setState(() {
      _selectedCurrency = newCurrency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '211011400877 - RYO AKBAR',
      themeMode: _themeMode, // Set the theme mode
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headline6: TextStyle(fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 18),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
      ),
      home: CryptoListScreen(selectedCurrency: _selectedCurrency, onChangeCurrency: _changeCurrency),
    );
  }
}

enum Currency {
  USD,
  IDR,
}

class CryptoListScreen extends StatefulWidget {
  final Currency selectedCurrency;
  final void Function(Currency) onChangeCurrency;

  const CryptoListScreen({super.key, required this.selectedCurrency, required this.onChangeCurrency});

  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  late List<Crypto> cryptos = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updatePrices();
    });
  }

  void _fetchData() async {
    try {
      List<Crypto> fetchedCryptos = await ApiService().fetchCryptos();
      setState(() {
        cryptos = fetchedCryptos;
      });
    } catch (e) {
      // Handle error appropriately here
      print('Error fetching data: $e');
    }
  }

  void _updatePrices() async {
    try {
      List<Crypto> fetchedCryptos = await ApiService().fetchCryptos();
      setState(() {
        for (var i = 0; i < cryptos.length; i++) {
          cryptos[i].priceUsd = fetchedCryptos[i].priceUsd;
        }
      });
    } catch (e) {
      // Handle error appropriately here
      print('Error updating prices: $e');
    }
  }

  String _formatPrice(double price) {
    if (widget.selectedCurrency == Currency.IDR) {
      // Convert USD to IDR (1 USD = 14,000 IDR for example)
      return 'Rp ${(price * 14000).toStringAsFixed(2)}';
    } else {
      // Display USD
      return '\$${price.toStringAsFixed(2)}';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga Crypto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () {
              // Toggle theme on button press
              final _myApp = context.findAncestorStateOfType<_MyAppState>();
              _myApp!._toggleTheme();
            },
          ),
          PopupMenuButton<Currency>(
            initialValue: widget.selectedCurrency,
            onSelected: (currency) {
              widget.onChangeCurrency(currency);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Currency>>[
              const PopupMenuItem<Currency>(
                value: Currency.USD,
                child: Text('USD (\$)'),
              ),
              const PopupMenuItem<Currency>(
                value: Currency.IDR,
                child: Text('IDR (Rp)'),
              ),
            ],
          ),
        ],
      ),
      body: cryptos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cryptos.length,
        itemBuilder: (context, index) {
          final crypto = cryptos[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    crypto.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                title: Text(
                  crypto.name,
                  style: Theme.of(context).textTheme.headline6,
                ),
                subtitle: Text(crypto.symbol),
                trailing: Text(
                  _formatPrice(crypto.priceUsd),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  print('Tapped ${crypto.name}');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
