import 'dart:async';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/user.dart';
import '../model/user/user.dart';
import 'datetime_converter.dart';

part 'database.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter, DateTimeNullableConverter])
@Database(version: 1, entities: [User])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}

// 以下是OnConflictStrategy枚举中可用的选项：
//
// OnConflictStrategy.rollback: 回滚事务并撤销插入操作，以便回到插入之前的状态。
// OnConflictStrategy.abort: 中止插入操作并回滚事务。
// OnConflictStrategy.fail: 抛出一个异常以表示插入操作失败。
// OnConflictStrategy.ignore: 忽略冲突并继续执行操作，不会抛出异常或撤销操作。
// OnConflictStrategy.replace: 替换现有记录的值，并继续执行操作，不会抛出异常或撤销操作。

late AppDatabase appDatabase;

Future<AppDatabase> getDatabase() async => appDatabase;

late Database db;

Future<void> initDatabase() async => appDatabase = await _getDatabase();


Future<AppDatabase> _getDatabase() async {
  final dir = await getApplicationSupportDirectory();
  return $FloorAppDatabase
      .databaseBuilder(join(dir.path, 'app_database.db'))
      .build();
}
