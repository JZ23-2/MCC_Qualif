import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import './material/theme_notifier.dart';
import 'drinkDetailPage.dart';
import './model/user.dart';

class DrinkApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrinkAppState();
}

class _DrinkAppState extends State<DrinkApp> {
  Future<List<dynamic>>? _drinksFuture;

  @override
  void initState() {
    super.initState();
    _drinksFuture = _fetchDrinks();
  }

  Future<List<dynamic>> _fetchDrinks() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/drink/getAllDrinks'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load drinks');
      }
    } catch (e) {
      throw Exception('Error fetching drinks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _drinksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No drinks available"));
          } else {
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: snapshot.data!.map((drink) {
                return DrinkCard(
                  imageUrl: "http://localhost:3000/${drink['DrinkImage']}",
                  drinkName: drink['DrinkName'],
                  price: (drink['DrinkPrice']).toString(),
                  description: drink['DrinkDescription'],
                  drinkId: drink["DrinkID"],
                  user: user,
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class DrinkCard extends StatelessWidget {
  final String imageUrl;
  final String drinkName;
  final String price;
  final String description;
  final int drinkId;
  final User user; 

  DrinkCard({
    required this.imageUrl,
    required this.drinkName,
    required this.price,
    required this.description,
    required this.drinkId,
    required this.user, 
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrinkDetailPage(
              drinkId: drinkId,
              user: user, 
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 5,
        color: themeNotifier.getTheme().cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                drinkName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeNotifier.getTheme().textTheme.titleMedium?.color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  color: themeNotifier.getTheme().textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: themeNotifier.getTheme().textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
