import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_v2/model/server_model.dart';
import 'package:mobile_v2/model/user_model.dart';
import 'package:mobile_v2/page/auth/signup_option.dart';
import 'package:mobile_v2/preference/user_prefrence.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: data.name, password: data.password);
      final server = await FirebaseDatabase.instance
          .ref('servers')
          .orderByChild('ownerId')
          .equalTo(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (server.exists) {
        final model = ServerModel.fromJson(server);
        final prefs = await SharedPreferences.getInstance();
        UserPrefrence.setIsServer(true);
        UserPrefrence.setLocation(model.location ?? '');

        prefs.setString('url', model.url);
        prefs.setString('id', server.key ?? '');
      } else {
        final client = await FirebaseDatabase.instance
            .ref('client')
            .orderByChild('clientId')
            .equalTo(FirebaseAuth.instance.currentUser?.uid)
            .get();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('location', (client.value as Map)['location'] ?? '');
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
      return 'Sign in failed';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    SignupModel? res = await showDialog<SignupModel>(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: SignupOptionWidget(),
          );
        });
    if (res == null) {
      return 'Please select Signup option.';
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name ?? '',
        password: data.password ?? '',
      );

      if (res.option == 'Client') {
        await FirebaseDatabase.instance.ref('client').push().set(
          {
            'clientId': FirebaseAuth.instance.currentUser?.uid ?? '',
            'location': res.optionDetail,
          },
        );
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('location', res.optionDetail);
      } else {
        User? user = FirebaseAuth.instance.currentUser;
        user?.updateDisplayName(res.name);

        await FirebaseDatabase.instance.ref('servers').push().set(
              ServerModel(
                url: res.optionDetail,
                owner: UserModel(
                  imageUrl: user?.photoURL,
                  name: res.name ?? '',
                  phoneNumber: res.phone ?? '',
                  id: user?.uid ?? '',
                ),
                ownerId: user?.uid ?? '',
                description: res.description ?? '',
                status: 'Pending',
              ).toJson(),
            );
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('phoneNumber', user?.phoneNumber ?? '');
        prefs.setString('url', res.optionDetail);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return 'Sign up failed';
    } catch (e) {
      debugPrint('Error: $e');
      return e.toString();
    }
  }

  Future<String?> googleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return 'Sign in with Google failed.';
    }

    try {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _recoverPassword(String name) async {
    debugPrint('Name: $name');
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      }
      return 'Recover failed';
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Decentralized',
      onLogin: _authUser,
      onSignup: _signupUser,
      userValidator: (email) {
        if (EmailValidator.validate(email ?? '')) {
          return null;
        } else {
          return 'Please enter the correct email format';
        }
      },
      onSubmitAnimationCompleted: () {},
      onRecoverPassword: _recoverPassword,
      theme: LoginTheme(
        inputTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
