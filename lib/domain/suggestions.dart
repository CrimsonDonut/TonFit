import 'exercise_type.dart';
import 'progress.dart';

/// One logged occurrence of an exercise, as the suggestion rules see it.
class ExerciseSession {
  const ExerciseSession({
    required this.day,
    required this.volume,
    required this.topWeight,
    required this.repsAtTop,
    required this.sets,
  });

  factory ExerciseSession.fromSets(
    int day,
    List<SetData> sets, {
    ExerciseType type = ExerciseType.weighted,
    int bodyweightRef = Progress.defaultBodyweightRef,
    bool trackDistance = false,
  }) {
    final m = Progress.metrics(
      sets,
      type: type,
      bodyweightRef: bodyweightRef,
      trackDistance: trackDistance,
    );
    return ExerciseSession(
      day: day,
      volume: m.volume,
      topWeight: m.topWeight,
      repsAtTop: m.repsAtTop,
      sets: sets,
    );
  }

  final int day;
  final int volume;
  final int topWeight;
  final int repsAtTop;
  final List<SetData> sets;
}

/// Best marks from sessions BEFORE the one being evaluated.
class PriorBests {
  const PriorBests({required this.maxWeight, required this.repsAtMaxWeight});
  final int maxWeight;
  final int repsAtMaxWeight;
}

/// Everything a rule may look at. [history] is newest first: history[0] is
/// the session being evaluated. Keep it to the last few sessions (requirements
/// FR-20). [extras] is where future inputs such as calories plug in.
class SuggestionContext {
  const SuggestionContext({
    required this.exerciseName,
    required this.history,
    this.priorBests,
    this.extras = const {},
    this.timeBased = false,
    this.distanceBased = false,
  });

  final String exerciseName;

  /// A timed exercise: tips talk about time instead of reps and weight.
  final bool timeBased;

  /// Progress is measured in distance (a run): tips talk about distance.
  final bool distanceBased;
  final List<ExerciseSession> history;
  final PriorBests? priorBests;
  final Map<String, Object?> extras;
}

/// Thresholds for the starter rules, kept as data (requirements FR-21).
class SuggestionConfig {
  const SuggestionConfig({
    this.largeDropTenths = -150, // more than a 15% drop
    this.declineSessions = 2,
    this.stallSessions = 3,
    this.identicalSessions = 3,
  });

  final int largeDropTenths;
  final int declineSessions;
  final int stallSessions;
  final int identicalSessions;
}

/// Returns the message parameters when the rule fires, or null.
typedef RuleCheck = Map<String, Object?>? Function(
  SuggestionContext ctx,
  SuggestionConfig cfg,
);

class SuggestionRule {
  const SuggestionRule({
    required this.id,
    required this.priority,
    required this.check,
  });

  final String id;

  /// Lower number wins.
  final int priority;
  final RuleCheck check;
}

class SuggestionHit {
  const SuggestionHit({
    required this.ruleId,
    required this.priority,
    required this.exerciseName,
    required this.params,
  });

  final String ruleId;
  final int priority;
  final String exerciseName;
  final Map<String, Object?> params;
}

bool _improved(ExerciseSession cur, ExerciseSession prev) =>
    cur.volume > prev.volume || cur.topWeight > prev.topWeight;

bool _sameSets(ExerciseSession a, ExerciseSession b) {
  if (a.sets.length != b.sets.length) return false;
  for (var i = 0; i < a.sets.length; i++) {
    if (a.sets[i] != b.sets[i]) return false;
  }
  return true;
}

Map<String, Object?>? _personalBest(SuggestionContext ctx, SuggestionConfig cfg) {
  final prior = ctx.priorBests;
  if (prior == null || ctx.history.isEmpty) return null;
  final cur = ctx.history[0];
  final weightPr = cur.topWeight > prior.maxWeight;
  final repsPr =
      cur.topWeight == prior.maxWeight && cur.repsAtTop > prior.repsAtMaxWeight;
  if (!weightPr && !repsPr) return null;
  return {'kind': weightPr ? 'weight' : 'reps'};
}

Map<String, Object?>? _largeDrop(SuggestionContext ctx, SuggestionConfig cfg) {
  if (ctx.history.length < 2) return null;
  final pct = Progress.pctTenths(ctx.history[0].volume, ctx.history[1].volume);
  if (pct == null || pct >= cfg.largeDropTenths) return null;
  return {'pctTenths': pct};
}

Map<String, Object?>? _decline(SuggestionContext ctx, SuggestionConfig cfg) {
  final h = ctx.history;
  if (h.length < cfg.declineSessions + 1) return null;
  for (var i = 0; i < cfg.declineSessions; i++) {
    if (h[i].volume >= h[i + 1].volume) return null;
  }
  return {'sessions': cfg.declineSessions};
}

Map<String, Object?>? _stall(SuggestionContext ctx, SuggestionConfig cfg) {
  final h = ctx.history;
  final n = cfg.stallSessions;
  if (h.length < n + 1) return null;
  for (var i = 0; i < n; i++) {
    if (_improved(h[i], h[i + 1])) return null;
  }
  var identical = h.length >= cfg.identicalSessions;
  for (var i = 1; identical && i < cfg.identicalSessions; i++) {
    identical = _sameSets(h[0], h[i]);
  }
  return {
    'sessions': n,
    'identical': identical,
    'timeBased': ctx.timeBased,
    'distanceBased': ctx.distanceBased,
  };
}

/// The starter rules (requirements section 3.4). New rules, including ones
/// that read [SuggestionContext.extras] such as calories, can be added to this
/// list without changing the engine.
const List<SuggestionRule> defaultSuggestionRules = [
  SuggestionRule(id: 'pr', priority: 1, check: _personalBest),
  SuggestionRule(id: 'large_drop', priority: 2, check: _largeDrop),
  SuggestionRule(id: 'decline', priority: 3, check: _decline),
  SuggestionRule(id: 'stall', priority: 4, check: _stall),
];

class SuggestionEngine {
  SuggestionEngine({
    List<SuggestionRule> rules = defaultSuggestionRules,
    this.config = const SuggestionConfig(),
  }) : rules = ([...rules]..sort((a, b) => a.priority.compareTo(b.priority)));

  final List<SuggestionRule> rules;
  final SuggestionConfig config;

  /// At most one message per exercise: the highest-priority rule that fires.
  SuggestionHit? evaluate(SuggestionContext ctx) {
    for (final rule in rules) {
      final params = rule.check(ctx, config);
      if (params != null) {
        return SuggestionHit(
          ruleId: rule.id,
          priority: rule.priority,
          exerciseName: ctx.exerciseName,
          params: params,
        );
      }
    }
    return null;
  }

  /// One message per exercise, then the best [maxMessages] for the day.
  /// Equal priorities keep the order the exercises were given in.
  List<SuggestionHit> evaluateSession(
    List<SuggestionContext> contexts, {
    int maxMessages = 3,
  }) {
    final hits = <(int, SuggestionHit)>[];
    for (var i = 0; i < contexts.length; i++) {
      final hit = evaluate(contexts[i]);
      if (hit != null) hits.add((i, hit));
    }
    hits.sort((a, b) {
      final byPriority = a.$2.priority.compareTo(b.$2.priority);
      return byPriority != 0 ? byPriority : a.$1.compareTo(b.$1);
    });
    return [for (final h in hits.take(maxMessages)) h.$2];
  }
}

/// Message text for a hit (requirements section 3.4).
String suggestionMessage(SuggestionHit hit) {
  final name = hit.exerciseName;
  switch (hit.ruleId) {
    case 'pr':
      return 'New PR on $name.';
    case 'large_drop':
      return 'Tough session on $name. Check your recovery, sleep, and nutrition.';
    case 'decline':
      return '$name has been trending down. Consider a rest day or a deload week.';
    case 'stall':
      final base =
          '$name hasn’t progressed in ${hit.params['sessions']} sessions. '
          'Are you eating enough and sleeping well?';
      if (hit.params['identical'] != true) return base;
      if (hit.params['distanceBased'] == true) {
        return '$base Try going a little further.';
      }
      return hit.params['timeBased'] == true
          ? '$base Try adding 5–10 seconds.'
          : '$base Try adding 1–2 reps or a small weight increase.';
    default:
      return '';
  }
}
