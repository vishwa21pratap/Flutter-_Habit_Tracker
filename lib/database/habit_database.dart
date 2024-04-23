import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:habittute/models/app_settings.dart';
import 'package:habittute/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /*
  Setup
  */

  //initialise database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  // Save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  //  get first date of app startup

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*
  CRUD OPERATIONS */
  //LIST OF HABITS
  final List<Habit> currentHabits = [];

  //CREATE -ADD A NEW HABIT
  Future<void> addHabit(String habitName) async {
    //create a new habit
    final newHabit = Habit()..name = habitName;

    // save to db

    await isar.writeTxn(() => isar.habits.put(newHabit));
    //re-read
    readHabits();
  }

  //READ
  Future<void> readHabits() async {
    //read all habits
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update UI
    notifyListeners();
  }

  //UPDATE CHECK HABIT on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find the specific habit
    final habit = await isar.habits.get(id);

    // update the habit status
    if (habit != null) {
      await isar.writeTxn(() async {
        //if habit is completed-> add current date to the completed list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          //today
          final today = DateTime.now();

          // add the current date if its not already in the list
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        }
        // if habit is not completed remove it
        else {
          //remove the current day
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        // save the update back to databse
        await isar.habits.put(habit);
      });
    }

    //re-read from database
    readHabits();
  }

  //UPDATE AND EDIT
  Future<void> updateHabitName(int id, String newName) async {
    //find the specific habit
    final habit = await isar.habits.get(id);

    // update the habit name
    if (habit != null) {
      //update name
      await isar.writeTxn(() async {
        habit.name = newName;
        //save updated habit back to the db
        await isar.habits.put(habit);
      });
    }

    //reread from database
    readHabits();
  }

  //DELETE
  Future<void> deleteHabit(int id) async {
    //perform the delete
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    // reread from db
    readHabits();
  }
}
