import 'package:flutter/material.dart';
import 'package:mymeals/constants/routes.dart';
import 'package:mymeals/services/auth/auth_service.dart';
import 'package:mymeals/views/login_view.dart';
import 'package:mymeals/views/meals_view.dart';
import 'package:mymeals/views/register_view.dart';
import 'package:mymeals/views/verify_email_view.dart';



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
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        mealsRoute: (context) => const MealsView(),
        verifyEmailRoute:(context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      //El SNAPSHOT es el encargado de proveer los datos al futuro
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const MealsView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}




