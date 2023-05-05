import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

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
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

late final TextEditingController _email;
late final TextEditingController _password;

@override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Register'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              ),
        //El SNAPSHOT es el encargado de proveer los datos al futuro
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.done:
              return Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              //El siguiente es para añadir al teclado un "@"
              keyboardType: TextInputType.emailAddress,
      
              decoration: const InputDecoration(
                hintText: 'Enter your email here'
              ),
            ),
            TextField(
              controller: _password,
              //3 características muy importantes para passwords.
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
      
              decoration: const InputDecoration(
                hintText: 'Enter your password here'
              ),
            ),
            TextButton(
              onPressed:() async {
                
                final email = _email.text;
                final password = _password.text;
                final userCredential =await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                  );
                  print(userCredential);
              },
              child: const Text('Register'),
            ),
            ],
        ); 
            
            default:
            return const Text('Loading...');
          }
          
        }, 
        
      ),
    );
  }
}

