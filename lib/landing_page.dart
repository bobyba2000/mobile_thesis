import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_v2/page/load_file_page.dart';
import 'package:mobile_v2/page/auth/login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('There has been an error.'),
          );
        } else if (snapshot.hasData) {
          return const LoadFilePage();
        }
        return const LoginPage();
      }),
      stream: FirebaseAuth.instance.authStateChanges(),
    );
  }
}
