import 'package:flutter/material.dart';
import 'package:mymeals/constants/routes.dart';
import 'package:mymeals/enums/menu_action.dart';
import 'package:mymeals/services/auth/auth_service.dart';
import 'package:mymeals/services/crud/meals_service.dart';
import 'package:mymeals/utilities/dialogs/logout_dialog.dart';
import 'package:mymeals/views/meals/meals_list_view.dart';

class MealsView extends StatefulWidget {
  const MealsView({super.key});

  @override
  State<MealsView> createState() => _MealsViewState();
}

class _MealsViewState extends State<MealsView> {
  late final MealsService _mealsService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _mealsService = MealsService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meals'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateMealRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _mealsService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _mealsService.allMeals,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allMeals = snapshot.data as List<DatabaseMeal>;
                        return MealsListView(
                          meals: allMeals,
                          onDeleteMeal: (meal) async {
                            await _mealsService.deleteMeal(id: meal.id);
                          },
                          onTap: (meal) {
                            Navigator.of(context).pushNamed(
                                createOrUpdateMealRoute,
                                arguments: meal);
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
