import 'package:flutter/material.dart';
import 'package:mymeals/services/crud/meals_service.dart';
import 'package:mymeals/utilities/dialogs/delete_dialog.dart';

typedef MealCallback = void Function(DatabaseMeal meals);

class MealsListView extends StatelessWidget {
  final List<DatabaseMeal> meals;
  final MealCallback onDeleteMeal;
  final MealCallback onTap;

  const MealsListView({
    Key? key,
    required this.meals,
    required this.onDeleteMeal,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return ListTile(
            onTap: () {
              onTap(meal);
            },
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
