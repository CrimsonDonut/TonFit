import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/tables.dart';

/// A one-field text dialog. Returns the text, or null when cancelled.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  int maxLength = 40,
  String confirm = 'Save',
  TextInputType? keyboardType,
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
        keyboardType: keyboardType,
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

/// The four kinds of exercise as a list of radio-style choices, each with a
/// one-line example, so the difference is clear before anything is logged.
class ExerciseTypePicker extends StatelessWidget {
  const ExerciseTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.trackDistance = false,
    this.onTrackDistanceChanged,
  });

  final ExerciseType value;
  final ValueChanged<ExerciseType> onChanged;

  /// Optional distance for timed and sport exercises (running, cycling). The
  /// checkbox only appears when [onTrackDistanceChanged] is given and the kind
  /// is time-based.
  final bool trackDistance;
  final ValueChanged<bool>? onTrackDistanceChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final t in ExerciseType.values)
          InkWell(
            onTap: () => onChanged(t),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      value == t
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: value == t
                          ? AppColors.accent
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.label, style: text.bodyLarge),
                        const SizedBox(height: 2),
                        Text(t.description, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (value.isTimeBased && onTrackDistanceChanged != null)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: trackDistance,
            onChanged: (v) => onTrackDistanceChanged!(v ?? false),
            title: const Text('Track distance'),
            subtitle: const Text('For running, jogging, cycling or swimming.'),
          ),
      ],
    );
  }
}

/// Name, kind and (for timed and sport) whether to track distance, for a new
/// exercise.
Future<({String name, ExerciseType type, bool trackDistance})?>
    promptNewExercise(BuildContext context) {
  final controller = TextEditingController();
  var type = ExerciseType.weighted;
  var trackDistance = false;
  return showDialog<({String name, ExerciseType type, bool trackDistance})>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('New exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Cable Fly'),
              ),
              const SizedBox(height: 8),
              ExerciseTypePicker(
                value: type,
                onChanged: (t) => setState(() => type = t),
                trackDistance: trackDistance,
                onTrackDistanceChanged: (v) => setState(() => trackDistance = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop((
              name: controller.text,
              type: type,
              trackDistance: trackDistance && type.isTimeBased,
            )),
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
