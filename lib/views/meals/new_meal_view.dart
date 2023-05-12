import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mymeals/services/auth/auth_service.dart';
import 'package:mymeals/services/crud/meals_service.dart';

class NewMealView extends StatefulWidget {
  const NewMealView({super.key});

  @override
  State<NewMealView> createState() => _NewMealViewState();
}

class _NewMealViewState extends State<NewMealView> {
  DatabaseMeal? _meal;
  late final MealsService _mealsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _mealsService = MealsService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final meal = _meal;
    if (meal == null) {
      return;
    }
    final text = _textController.text;
    await _mealsService.updateMeal(
      meal: meal,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseMeal> createNewMeal() async {
    final existingMeal = _meal;
    if (existingMeal != null) {
      return existingMeal;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _mealsService.getUser(email: email);
    return await _mealsService.createMeal(owner: owner);
  }

  void _deleteMealIfTextIsEmpty() {
    final meal = _meal;
    if (_textController.text.isEmpty && meal != null) {
      _mealsService.deleteMeal(id: meal.id);
    }
  }

  void _saveMealIfTextNotEmpty() async {
    final meal = _meal;
    final text = _textController.text;
    if (meal != null && text.isNotEmpty) {
      await _mealsService.updateMeal(
        meal: meal,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteMealIfTextIsEmpty();
    _saveMealIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New meal'),
      ),
      body: FutureBuilder(
        future: createNewMeal(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _meal = snapshot.data as DatabaseMeal;
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your meal...'
                ),
              );
              break;
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
