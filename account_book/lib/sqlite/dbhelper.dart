import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:account_book/sqlite/accountmodel.dart';

class DBHelper {
  final String dbname;
  final String tablename;
  DBHelper({required this.tablename, required this.dbname});
  var _db;

  Future<Database> get database async {
    if (_db != null) return _db;
    _db = openDatabase(
      join(await getDatabasesPath(), '$dbname.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tablename(id TEXT PRIMARY KEY, uid TEXT, date TEXT, money TEXT, content TEXT)",
        );
      },
      version: 1,
    );
    return _db;
  }

  Future<void> insertAccount(Account account) async {
    final db = await database;

    await db.insert(
      tablename,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Account>> accounts(
      String wherecondition, String condition) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db
        .query(tablename, where: wherecondition, whereArgs: [condition]);

    return List.generate(maps.length, (i) {
      return Account(
        id: maps[i]['id'],
        uid: maps[i]['uid'],
        date: maps[i]['date'],
        money: maps[i]['money'],
        content: maps[i]['content'],
      );
    });
  }

  Future<void> updateAccount(Account account) async {
    final db = await database;

    await db.update(
      tablename,
      account.toMap(),
      where: "id = ?",
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(String uid) async {
    final db = await database;

    await db.delete(
      tablename,
      where: "uid = ?",
      whereArgs: [uid],
    );
  }
}
