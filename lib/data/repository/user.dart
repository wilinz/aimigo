import 'package:dio/src/response.dart';
import 'package:floor/floor.dart';
import 'package:aimigo/data/network.dart';
import '../database/database.dart';
import '../model/user/user.dart';

class UserRepository {
  Future<User?> getRecentUser() async {
    final db = appDatabase;
    final user = await db.userDao.getRecent();
    return user.firstOrNull;
  }

  Stream<User?> getRecentUserStream() {
    final db = appDatabase;
    final user = db.userDao.getRecentStream();
    return user.map((e) => e.firstOrNull);
  }

  Stream<User?> getActiveUserStream() {
    final db = appDatabase;
    final user = db.userDao.getActiveStream();
    return user;
  }

  Future<void> login(String username) async {
    final db = await getDatabase();
    var user = await db.userDao.get(username);
    if (user != null) {
      user.isActive = true;
      db.userDao.offlineOtherUser(username);
      db.userDao.updateUser(user);
    } else {
      user = User(
          updateTime: DateTime.now(),
          username: username,
          password: "",
          isActive: true);
      db.userDao.offlineOtherUser(username);
      db.userDao.insertUser(user);
    }
  }

  Future<dynamic> logout() async {
    final resp = await AppNetwork.get().dio.delete("/account/logout");
    print(resp.data['code'] == 200);
    if (resp.data['code'] == 200) {
      appDatabase.userDao.offlineCurrent();
      // final user = await appDatabase.userDao.getActive();
      // if (user != null) {
      //   user.isActive = false;
      //   appDatabase.userDao.updateUser(user);
      // }
    }
    return resp.data;
  }

  Future<User?> getActiveUser() async {
    final db = await getDatabase();
    return db.userDao.getActive();
  }

  UserRepository._create();

  static UserRepository? _instance;

  factory UserRepository.getInstance() =>
      _instance ??= UserRepository._create();
}
