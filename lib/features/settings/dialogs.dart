import 'package:flutter/material.dart';

import '../../data/database/tables.dart';

/// A one-field text dialog. Returns the text, or null when cancelled.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  int maxLength = 40,
  String confirm = 'Save',
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: maxLength,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text),
          child: Text(confirm),
        ),
      ],
    ),
  );
}

/// Name plus weighted/bodyweight choice for a new exercise.
Future<({String name, ExerciseType type})?> promptNewExercise(
  BuildContext context,
) {
  final controller = TextEditingController();
  var type = ExerciseType.weighted;
  return showDialog<({String name, ExerciseType type})>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('New exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'e.g. Cable Fly'),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ExerciseType>(
              segments: const [
                ButtonSegment(
                    value: ExerciseType.weighted, label: Text('Weighted')),
                ButtonSegment(
                    value: ExerciseType.bodyweight, label: Text('Bodyweight')),
              ],
              selected: {type},
              onSelectionChanged: (s) => setState(() => type = s.first),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop((name: controller.text, type: type)),
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Shows a blocking progress dialog while [task] runs, then closes it.
Future<T> runWithProgress<T>(
  BuildContext context,
  String label,
  Future<T> Function() task,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    navigator.pop();
  }
}

/// OK / Cancel confirmation. Returns true when confirmed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> infoDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
