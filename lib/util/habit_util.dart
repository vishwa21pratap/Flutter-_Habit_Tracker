//given a habit list of completion days

//is it completed today
import 'package:habittute/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day);
}

//create heatmap dataset

Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      //normalie date to avoid time  mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);

      //if the datev already exists in dataset ,increment itrs count
      if (dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      } else {
        //else initialise it with a count
        dataset[normalizedDate] = 1;
      }
    }
  }
  return dataset;
}
