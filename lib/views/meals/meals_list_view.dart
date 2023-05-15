import 'package:flutter/material.dart';
import 'package:mymeals/services/crud/meals_service.dart';
import 'package:mymeals/utilities/dialogs/delete_dialog.dart';

typedef DeleteMealCallback = void Function(DatabaseMeal meals);

class MealsListView extends StatelessWidget {
  final List<DatabaseMeal> meals;
  final DeleteMealCallback onDeleteMeal;

  const MealsListView({
    Key? key,
    required this.meals,
    required this.onDeleteMeal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return ListTile(
            title: Text(
              meal.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteMeal(meal);
                }
              },
              icon: const Icon(Icons.delete),
            ),
          );
        });
  }
}
