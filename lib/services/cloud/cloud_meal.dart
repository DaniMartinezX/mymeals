import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymeals/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudMeal {
  final String documentId;
  final String ownerUserId;
  final String text;
  const CloudMeal({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudMeal.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
