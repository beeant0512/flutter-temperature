import 'package:my_temperature/database/DatabaseProvider.dart';
import 'package:my_temperature/database/model/UserModel.dart';
import 'package:sqflite/sqflite.dart';

class UserProvider extends DatabaseProvider {
  String table = "user";

  @override
  createTableString() {
    return 'CREATE TABLE user (id INTEGER PRIMARY KEY, name TEXT, gender TEXT, birthday INTEGER)';
  }

  @override
  tableName() {
    return table;
  }

  ///插入到数据库
  Future insert(UserModel model) async {
    Database db = await getDataBase();
    return await db.rawInsert(
        "insert into $table (name, gender, birthday) values (?,?,?)",
        [model.name, model.gender, model.birthday]);
  }

  Future<List<UserModel>> fetchAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select * from $table");
    List<UserModel> list = List<UserModel>();

    maps.forEach((model) => {
      list.add(UserModel.fromJson(model))
    });
    return list;
  }
}
