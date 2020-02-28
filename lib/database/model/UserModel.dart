import 'package:my_temperature/database/model/BaseModel.dart';

class UserModel extends BaseModel {

  String name;

  String birthday;

  String gender;

  static UserModel fromJson(Map<String, dynamic> map) {
    UserModel model = new UserModel();
    model.birthday = map['birthday'].toString();
    model.name = map['name'];
    model.gender = map['gender'];
    model.id = map['id'];
    return model;
  }
}