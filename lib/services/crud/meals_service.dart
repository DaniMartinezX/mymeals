import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mymeals/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;



//Para comunicarse con la BD.
class NotesService {
  Database? _db;

  List<DatabaseMeal> _meals = [];

  final _mealsStreamController =
    StreamController<List<DatabaseMeal>>.broadcast();

  Future<void> _cacheMeals() async {
    final allMeals = await getAllMeals();
    _meals = allMeals.toList();
    _mealsStreamController.add(_meals);
  }

  Future<DatabaseMeal> updateMeal({
    required DatabaseMeal meal,
    required String text
  }) async {
    final db = _getDatabaseOrThrow();

    //Make sure meal exists
    await getMeal(id: meal.id);

    //update DB
    final updatesCount = await db.update(mealTable, {
      textColumn: text,
      isSynceWithCloudColumn: 0});

    if (updatesCount == 0) {
      throw CouldNotUpdateMeal();
    } else {
      final updatedMeal = await getMeal(id: meal.id);
      _meals.removeWhere((meal) => meal.id == updatedMeal.id);
      _meals.add(updatedMeal);
      _mealsStreamController.add(_meals);
      return updatedMeal;
    }

    }

  Future<Iterable<DatabaseMeal>> getAllMeals() async {
    final db = _getDatabaseOrThrow();
    final meals = await db.query(
      mealTable
    );

    return meals.map((mealRow) => DatabaseMeal.fromRow(mealRow));
  }

  Future<DatabaseMeal> getMeal({required int id}) async {
    final db = _getDatabaseOrThrow();
    final meals = await db.query(
      mealTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (meals.isEmpty){
      throw CouldNotFindMeal();
    } else {
      final meal = DatabaseMeal.fromRow(meals.first);
      _meals.removeWhere((meal) => meal.id == id);
      _meals.add(meal);
      _mealsStreamController.add(_meals);
      return meal;
    }
  }

  Future<void> deleteMeal({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      mealTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteMeal();
    } else {
      _meals.removeWhere((meal) => meal.id == id);
      _mealsStreamController.add(_meals);
    }
  }

  Future<int> deleteAllMeals() async {
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(mealTable);
    _meals = [];
    _mealsStreamController.add(_meals);
    return numberOfDeletions;
  }

  Future<DatabaseMeal> createMeal({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    //Make sure owner exists in the database with the correct id

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    //create the meal
    final mealId = await db.insert(mealTable,
        {userIdColumn: owner.id, textColumn: text, isSynceWithCloudColumn: 1});

    final meal = DatabaseMeal(
      id: mealId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _meals.add(meal);
    _mealsStreamController.add(_meals);

    return meal;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExist();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create user table
      await db.execute(createUserTable);
      //create note table
      await db.execute(createMealTable);
      await _cacheMeals();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseMeal {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseMeal({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseMeal.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSynceWithCloudColumn as int]) == 1 ? true : false;

  @override
  String toString() =>
      'Meal, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseMeal other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'meals.db';

const mealTable = 'meal';
const userTable = 'user';

const idColumn = "id";
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSynceWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createMealTable = '''CREATE TABLE IF NOT EXISTS "meal" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT,
      "is_synced_with_cloud"	INTEGER NOT NULL,
      FOREIGN KEY("user_id") REFERENCES "user"("id"),
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''';
