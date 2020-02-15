import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class SqlManager {
  static const _VERSION = 1;

  static const _NAME = "xstudio.db";

  static Database _database;

  static init() async {
//    var databasesPath = await getDatabasesPath();
    var databasesPath = await getExternalStorageDirectory();
    String path = join(databasesPath.path, _NAME);
//    await deleteDatabase(path);
    print(path);
    _database = await openDatabase(path, version: _VERSION,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE temperature (id INTEGER PRIMARY KEY, user_id INTEGER, date TEXT, time TEXT, value INTEGER)');
      await db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY KEY, name TEXT, gender TEXT, birthday INTEGER)');
    });
  }

  /// 判断表是否存在
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.length > 0;
  }

  /// 获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  /// 关闭
  static close() {
    _database?.close();
    _database = null;
  }
}
