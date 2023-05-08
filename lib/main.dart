import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mymeals/firebase_options.dart';
import 'package:mymeals/views/login_view.dart';
import 'package:mymeals/views/register_view.dart';

void main() {
  //Binding
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        //El SNAPSHOT es el encargado de proveer los datos al futuro
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            /*
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
              return const Text('Done');
              } else {
                return const VerifyEmailView();
              }
              */
              return const LoginView();
            default:
              return const Text('Loading...');
          }
        },
      ),
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const Text('Please verify your email address:'),
          TextButton(onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            await user?.sendEmailVerification();
          }, child: const Text('Send email verification'))
        ],
      );
  }
}
