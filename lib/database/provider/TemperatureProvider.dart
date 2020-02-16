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

  ///插入到数据库
  Future insert(TemperatureModel model) async {
    Database db = await getDataBase();
    return await db.rawInsert(
        "insert into $table (user_id, date, time, value) values (?, ?,?,?)",
        [model.userId, model.date, model.time, model.value]);
  }

  Future<List> fetchAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select * from $table");
    List<TemperatureModel> list = List<TemperatureModel>();

    maps.forEach((model) => {list.add(TemperatureModel.fromJson(model))});
    return list;
  }

  Future<List<TemperatureModel>> fetchAllByUserId(int userId, String order) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "select * from $table where user_id = $userId order by date $order, time $order");
    List<TemperatureModel> list = List<TemperatureModel>();

    maps.forEach((model) => {list.add(TemperatureModel.fromJson(model))});
    return list;
  }

  Future update(TemperatureModel model) async {
    Database db = await getDataBase();
    return await db.rawUpdate(
        "update $table set user_id = ?, date = ?, time = ?, value = ? where id = ?",
        [model.userId, model.date, model.time, model.value, model.id]);
  }
}
