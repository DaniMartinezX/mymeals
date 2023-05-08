import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mymeals/firebase_options.dart';
import 'package:mymeals/views/login_view.dart';

void main() {
  //Binding
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget{
  const HomePage({Key? key}) : super(key:key);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Home'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              
              ),
        //El SNAPSHOT es el encargado de proveer los datos al futuro
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user?.emailVerified ?? false){
              print('You are verified user');
            } else {
              print('You need to verify your email first');
            }
              return const Text('Done');
            default:
            return const Text('Loading...');
          }
          
        }, 
        
      ),
    );
  }
}




