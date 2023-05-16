import 'package:flutter/material.dart';
import 'package:mymeals/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyMealDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty meal!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
