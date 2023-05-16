import 'package:flutter/material.dart';
import 'package:mymeals/services/auth/auth_service.dart';
import 'package:mymeals/utilities/dialogs/cannot_share_empty_meal_dialog.dart';
import 'package:mymeals/utilities/generics/get_arguments.dart';
import 'package:mymeals/services/cloud/cloud_meal.dart';
import 'package:mymeals/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateMealView extends StatefulWidget {
  const CreateUpdateMealView({Key? key}) : super(key: key);

  @override
  _CreateUpdateMealViewState createState() => _CreateUpdateMealViewState();
}

class _CreateUpdateMealViewState extends State<CreateUpdateMealView> {
  CloudMeal? _meal;
  late final FirebaseCloudStorage _mealsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _mealsService = FirebaseCloudStorage();
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
      documentId: meal.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudMeal> createOrGetExistingMeal(BuildContext context) async {
    final widgetMeal = context.getArgument<CloudMeal>();

    if (widgetMeal != null) {
      _meal = widgetMeal;
      _textController.text = widgetMeal.text;
      return widgetMeal;
    }

    final existingMeal = _meal;
    if (existingMeal != null) {
      return existingMeal;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newMeal = await _mealsService.createNewMeal(ownerUserId: userId);
    _meal = newMeal;
    return newMeal;
  }

  void _deleteMealIfTextIsEmpty() {
    final meal = _meal;
    if (_textController.text.isEmpty && meal != null) {
      _mealsService.deleteMeal(documentId: meal.documentId);
    }
  }

  void _saveMealIfTextNotEmpty() async {
    final meal = _meal;
    final text = _textController.text;
    if (meal != null && text.isNotEmpty) {
      await _mealsService.updateMeal(
        documentId: meal.documentId,
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
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_meal == null || text.isEmpty) {
                await showCannotShareEmptyMealDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingMeal(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Start typing your meal...'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
