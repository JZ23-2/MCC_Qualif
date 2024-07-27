import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './material/theme_notifier.dart';
import 'model/user.dart';
import 'main.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final user = Provider.of<User>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Profile Page for ${user.username}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginApp()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
