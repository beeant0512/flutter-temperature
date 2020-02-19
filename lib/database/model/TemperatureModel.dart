import 'package:my_temperature/database/model/BaseModel.dart';

class TemperatureModel extends BaseModel {

  int userId;

  double value;

  String date;

  String time;

  String comment;

  static TemperatureModel fromJson(Map<String, dynamic> map) {
    TemperatureModel model = new TemperatureModel();
    model.userId = map['user_id'];
    model.value = double.parse(map['value'].toString());
    model.date = map['date'];
    model.time = map['time'];
    model.id = map['id'];
    model.comment = map['comment'];
    return model;
  }
}