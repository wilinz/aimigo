// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `username` TEXT NOT NULL, `password` TEXT NOT NULL, `is_active` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_users_username` ON `users` (`username`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'users',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'password': item.password,
                  'is_active': item.isActive ? 1 : 0,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<User?> getActive() async {
    return _queryAdapter.query(
        'SELECT * FROM users WHERE is_active = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0));
  }

  @override
  Stream<User?> getActiveStream() {
    return _queryAdapter.queryStream(
        'SELECT * FROM users WHERE is_active = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        queryableName: 'users',
        isView: false);
  }

  @override
  Future<User?> get(String username) async {
    return _queryAdapter.query(
        'SELECT * FROM users WHERE username = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        arguments: [username]);
  }

  @override
  Future<List<User>> getRecent() async {
    return _queryAdapter.queryList(
        'SELECT * FROM users ORDER BY update_time DESC LIMIT 5',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0));
  }

  @override
  Stream<List<User>> getRecentStream() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM users ORDER BY update_time DESC LIMIT 5',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        queryableName: 'users',
        isView: false);
  }

  @override
  Future<List<User>> searchUsers(String keyword) async {
    return _queryAdapter.queryList('SELECT * FROM users WHERE username LIKE ?1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        arguments: [keyword]);
  }

  @override
  Future<List<User>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM users',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0));
  }

  @override
  Future<void> offlineCurrent() async {
    await _queryAdapter
        .queryNoReturn('UPDATE users SET is_active = 0 WHERE is_active = 1');
  }

  @override
  Future<void> offlineOtherUser(String username) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE users SET is_active = 0 WHERE username <> ?1',
        arguments: [username]);
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _dateTimeNullableConverter = DateTimeNullableConverter();
