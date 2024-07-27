import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'model/user.dart';
import 'package:http/http.dart' as http;
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:provider/provider.dart';
import './material/theme_notifier.dart';
import 'drink.dart';
import 'profile.dart'; 

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  Future<List<dynamic>>? _drinksFuture;
  int _selectedIndex = 0;
  late PageController _pageController;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _drinksFuture = _fetchDrinks();
    _children = [
      Center(child: Text("Loading...")),
      DrinkApp(),
      ProfilePage(), 
    ];
  }

  Future<List<dynamic>> _fetchDrinks() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/drink/getDrinks'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load drinks');
      }
    } catch (e) {
      throw Exception('Error fetching drinks: $e');
    }
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _buildHomePage(List<dynamic> drinks) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 120),
              child: Container(
                width: 180,
                height: 200,
                child: const Text(
                  'To inspire and nurture the human spirit - one person, one cup, and one neighborhood at a time.',
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Image.asset(
              "../assets/poster.png",
              width: 200,
              height: 250,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CarouselSlider.builder(
              itemCount: drinks.length,
              itemBuilder: (context, index, realIndex) {
                final drink = drinks[index];
                final imageUrl = "http://localhost:3000/${drink['DrinkImage']}";
                print(imageUrl);
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image at index $index: $error');
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error),
                              Text("Failed to load image"),
                            ],
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          drink['DrinkName'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              options: CarouselOptions(
                height: 400.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("JtarbuckZ"),
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'Dark Mode') {
                  themeNotifier.setDarkMode();
                } else {
                  themeNotifier.setLightMode();
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Light Mode', 'Dark Mode'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        backgroundColor: themeNotifier.getTheme().primaryColor,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          FutureBuilder<List<dynamic>>(
            future: _drinksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No drinks available"));
              } else {
                return _buildHomePage(snapshot.data!);
              }
            },
          ),
          DrinkApp(),
          ProfilePage(), 
        ],
      ),
      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: themeNotifier.getTheme().primaryColor,
        onItemSelected: _onItemSelected,
        selectedIndex: _selectedIndex,
        barItems: [
          BarItem(
            filledIcon: Icons.home,
            outlinedIcon: Icons.home_outlined,
          ),
          BarItem(
            filledIcon: Icons.local_drink,
            outlinedIcon: Icons.local_drink_outlined,
          ),
          BarItem(
            filledIcon: Icons.person,
            outlinedIcon: Icons.person_outline,
          ),
        ],
      ),
    );
  }
}
