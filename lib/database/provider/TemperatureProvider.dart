import 'package:my_temperature/database/DatabaseProvider.dart';
import 'package:my_temperature/database/model/TemperatureModel.dart';
import 'package:sqflite/sqflite.dart';

class TemperatureProvider extends DatabaseProvider {
  String table = "temperature";

  @override
  createTableString() {
    return 'CREATE TABLE temperature (id INTEGER PRIMARY KEY, user_id INTEGER, date TEXT, time TEXT, value INTEGER)';
  }

  @override
  tableName() {
    return table;
  }

  ///查询数据库
  Future _getTemperatureProvider(Database db, int id) async {
    List<Map<String, dynamic>> maps =
        await db.rawQuery("select * from $table where id = $id");
    return maps;
  }

  ///插入到数据库
  Future insert(TemperatureModel model) async {
    Database db = await getDataBase();
    return await db.rawInsert(
        "insert into $table (user_id, date, time, value) values (?, ?,?,?)",
        [model.date, model.time, model.value]);
  }
}