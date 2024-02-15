import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get telegramId => integer().unique()();
  BoolColumn get isAdmin => boolean()();

  TextColumn get name => text().nullable().withLength(min: 2, max: 32)();
  IntColumn get groupNumber => integer().nullable()();
}

class LeetCodeAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get user => integer().unique().references(Users, #id)();
  TextColumn get nickname => text().unique().withLength(min: 3, max: 32)();
  DateTimeColumn get dateOfAddition => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isGraduated => boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 128)();
  TextColumn get shortTitle => text().withLength(min: 1, max: 16)();
  TextColumn get description => text().withLength(min: 1, max: 1024)();
  IntColumn get sortingNumber => integer()();
  DateTimeColumn get deadline => dateTime()();
}

enum LeetCodeTaskComplexity {
  easy,
  medium,
  hard;

  String get cutName => name[0].toUpperCase();
}

class LeetCodeTasks extends Table {
  IntColumn get id => integer().unique()();
  IntColumn get category => integer().references(Categories, #id)();
  TextColumn get title => text().withLength(min: 1, max: 128)();
  TextColumn get link => text().withLength(min: 1, max: 512)();
  TextColumn get complexity => textEnum<LeetCodeTaskComplexity>()();
}

class SolvedLeetCodeTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get user => integer().references(Users, #id)();
  IntColumn get task => integer().references(LeetCodeTasks, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Users,
    LeetCodeAccounts,
    Categories,
    LeetCodeTasks,
    SolvedLeetCodeTasks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final scriptFolderPath = File(Platform.script.toFilePath()).parent.path;
      final dbFolderPath = path.join(scriptFolderPath, 'db');

      final file = File(path.join(dbFolderPath, 'db.sqlite'));
      final cachebase = path.join(dbFolderPath, 'cache');

      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}