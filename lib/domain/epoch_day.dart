/// Calendar dates as integer epoch-days of the LOCAL calendar date
/// (requirements NFR-9). Day 0 is 1970-01-01, a Thursday.
abstract final class EpochDay {
  static final DateTime _epoch = DateTime.utc(1970, 1, 1);

  /// The epoch-day for the calendar date of [date] (time of day ignored).
  static int fromDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).difference(_epoch).inDays;

  /// The calendar date at local midnight.
  static DateTime toDate(int day) {
    final d = _epoch.add(Duration(days: day));
    return DateTime(d.year, d.month, d.day);
  }

  static int today([DateTime? now]) => fromDate(now ?? DateTime.now());

  /// Weekday of an epoch-day: 1 = Monday ... 7 = Sunday.
  static int weekdayOf(int day) => ((day + 3) % 7) + 1;

  /// Epoch-day of the Monday that starts the week containing [day].
  static int weekStart(int day) => day - ((day + 3) % 7);

  /// The next local midnight after [now]; used to schedule the day rollover.
  static DateTime nextMidnight([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day + 1);
  }
}
