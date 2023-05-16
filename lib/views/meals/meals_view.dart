import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mymeals/constants/routes.dart';
import 'package:mymeals/enums/menu_action.dart';
import 'package:mymeals/services/auth/auth_service.dart';
import 'package:mymeals/services/auth/bloc/auth_bloc.dart';
import 'package:mymeals/services/auth/bloc/auth_event.dart';
import 'package:mymeals/services/cloud/cloud_meal.dart';
import 'package:mymeals/services/cloud/firebase_cloud_storage.dart';
import 'package:mymeals/utilities/dialogs/logout_dialog.dart';
import 'package:mymeals/views/meals/meals_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class MealsView extends StatefulWidget {
  const MealsView({super.key});

  @override
  State<MealsView> createState() => _MealsViewState();
}

class _MealsViewState extends State<MealsView> {
  late final FirebaseCloudStorage _mealsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _mealsService = FirebaseCloudStorage();
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
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
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
      body: StreamBuilder(
        stream: _mealsService.allMeals(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allMeals = snapshot.data as Iterable<CloudMeal>;
                return MealsListView(
                  meals: allMeals,
                  onDeleteMeal: (meal) async {
                    await _mealsService.deleteMeal(documentId: meal.documentId);
                  },
                  onTap: (meal) {
                    Navigator.of(context)
                        .pushNamed(createOrUpdateMealRoute, arguments: meal);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
