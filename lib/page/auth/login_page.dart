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
        await setInfo(isServer: false, location: res.optionDetail);
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(data.name?.split('@').first);
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
                  email: user?.email ?? '',
                ),
                ownerId: user?.uid ?? '',
                description: res.description ?? '',
                status: 'Inactive',
                requestUpload: 0,
                requestNumber: 0,
                requestDownload: 0,
                responseDownloadTime: 0,
                responseTime: 0,
                responseUploadTime: 0,
                unresponse: 0,
              ).toJson(),
            );
        await setInfo(
          isServer: true,
          location: '',
          url: res.optionDetail,
          phoneNumber: res.phone,
        );
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

  Future<void> setInfo({
    required bool isServer,
    required String location,
    String? url,
    String? phoneNumber,
  }) async {
    await UserPrefrence.setIsServer(isServer);
    await UserPrefrence.setLocation(location);
    await UserPrefrence.setUrl(url ?? '');
    UserPrefrence.setPhoneNumber(phoneNumber ?? '');
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
