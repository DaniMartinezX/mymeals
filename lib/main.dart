import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mymeals/constants/routes.dart';
import 'package:mymeals/helpers/loading/loading_screen.dart';
import 'package:mymeals/services/auth/bloc/auth_bloc.dart';
import 'package:mymeals/services/auth/bloc/auth_event.dart';
import 'package:mymeals/services/auth/bloc/auth_state.dart';
import 'package:mymeals/services/auth/firebase_auth_provider.dart';
import 'package:mymeals/views/forgot_password_view.dart';
import 'package:mymeals/views/login_view.dart';
import 'package:mymeals/views/meals/meals_view.dart';
import 'package:mymeals/views/meals/create_update_meal_view.dart';
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
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateMealRoute: (context) => const CreateUpdateMealView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? 'Please wait a moment',
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const MealsView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
