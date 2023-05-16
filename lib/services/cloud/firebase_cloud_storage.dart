//Al implementar un patrón singleton sólo puede haber una instancia de esta clase en toda la aplicación
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymeals/services/cloud/cloud_meal.dart';
import 'package:mymeals/services/cloud/cloud_storage_constants.dart';
import 'package:mymeals/services/cloud/cloud_storage_exception.dart';

class FirebaseCloudStorage {
  final meals = FirebaseFirestore.instance.collection('meals');

  Future<void> deleteMeal({required String documentId}) async {
    try {
      await meals.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteMealException();
    }
  }

  Future<void> updateMeal({
    required String documentId,
    required String text,
  }) async {
    try {
      await meals.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateMealException();
    }
  }

  Stream<Iterable<CloudMeal>> allMeals({required String ownerUserId}) =>
      meals.snapshots().map((event) => event.docs
          .map((doc) => CloudMeal.fromSnapshot(doc))
          //Aquí es donde se hace el filtrado por usuario de los meals que tiene cada uno.
          .where((meal) => meal.ownerUserId == ownerUserId));

  Future<Iterable<CloudMeal>> getMeals({required String ownerUserId}) async {
    try {
      return await meals
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudMeal.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllMealException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  Future<CloudMeal> createNewMeal({required String ownerUserId}) async {
    final document = await meals.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedMeal = await document.get();
    return CloudMeal(
      documentId: fetchedMeal.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  //Constructor privado, no se puede acceder desde fuera de la clase [Técnica común en el patrón Singleton]
  //Para evitar que se creen más instancias de la clase.
  FirebaseCloudStorage._sharedInstance();

  //Al utilizar un método fábrica, se asegura de que siempre se devuelva la misma instancia de la clase en lugar
  // de crear una nueva cada vez que se llama al constructor.
  factory FirebaseCloudStorage() => _shared;
}
