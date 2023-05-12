import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewMealView extends StatefulWidget {
  const NewMealView({super.key});

  @override
  State<NewMealView> createState() => _NewMealViewState();
}

class _NewMealViewState extends State<NewMealView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New meal')),
      body: const Text('Write your new meal here...'),
    );
  }
}