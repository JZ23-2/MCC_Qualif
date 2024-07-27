import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import './material/theme_notifier.dart';
import 'home.dart';
import '../model/user.dart';

void main() => runApp(ChangeNotifierProvider(
      create: (_) => ThemeNotifier(ThemeData.light()),
      child: LoginApp(),
    ));

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Login Page',
      theme: themeNotifier.getTheme(),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static User? loginData;

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    String url = 'http://localhost:3000/user/login';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': username,
          'password': password,
        }),
      );

      var responseBody = jsonDecode(response.body);
      print(
          'Response Body: $responseBody');

      String errorMessage = responseBody['error'] ?? 'Unknown error occurred';

      if (response.statusCode == 200) {
        String message = responseBody["message"];
        var data = responseBody["data"];

        if (data != null) {
          // Ensure data types are correct
          String userId = data["UserID"].toString();
          String username = data["Username"].toString();
          String email = data["Email"].toString();

          loginData = User(userId, username, email);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Provider<User>.value(
              value: loginData!,
              child: HomeApp(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Failed: " + errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Exception: $e');
      if (e is TypeError) {
        print('TypeError details: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('../assets/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 16.0),
            Image.asset(
              '../assets/logo.jpg',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 24.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            SizedBox(
              height: 40,
              width: 170,
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
