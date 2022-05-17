import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_v2/page/load_file_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyABTUCPHL-_3dCay_GdlMEHHSgZB5013hM",
        authDomain: "mobile-thesis.firebaseapp.com",
        projectId: "mobile-thesis",
        storageBucket: "mobile-thesis.appspot.com",
        messagingSenderId: "600265855407",
        appId: "1:600265855407:web:d1036b6f2d1ed596a85f5a",
        databaseURL: "https://mobile-thesis-default-rtdb.firebaseio.com/",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoadFilePage(),
      builder: EasyLoading.init(),
    );
  }
}
