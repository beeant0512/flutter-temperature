import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:my_temperature/database/model/TemperatureModel.dart';
import 'package:my_temperature/database/model/UserModel.dart';
import 'package:my_temperature/database/provider/TemperatureProvider.dart';
import 'package:my_temperature/database/provider/UserProvider.dart';

class AddTemperaturePage extends StatefulWidget {
  const AddTemperaturePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddTemperaturePageState();
  }
}

class AddTemperaturePageState extends State<AddTemperaturePage> {
  TextEditingController _temperatureController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  GlobalKey _formKey = new GlobalKey<FormState>();

  AddTemperaturePageState();

  Future<List<UserModel>> getAllUsers() async {
    UserProvider userProvider = new UserProvider();
    Future<List<UserModel>> users = userProvider.fetchAll();
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // 去掉导航栏下面的阴影
          elevation: 0.0,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('添加温度'),
        ),
        body: Center(
            child: Form(
          key: _formKey,
          autovalidate: true, // 自动开启校验
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: getAllUsers(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        // 请求失败，显示错误
                        return Text("用户信息获取失败 ${snapshot.error}");
                      } else {
                        List<DropdownMenuItem> items = [];

                        List<UserModel> users = snapshot.data;
                        // 用户没有 先添加用户
                        if (!users.isEmpty) {
                          // 有用户，显示下拉框
                          users.forEach((user) => {
                                items.add(DropdownMenuItem(
                                  child: Text(user.name),
                                  value: user.id,
                                ))
                              });
                        }
                        _userController.text = items.isEmpty ? '' : items[0].value.toString();
                        return DropdownButtonFormField(
                            onChanged: (newValue) => setState(() {
                                  _userController.text = newValue;
                                }),
                            value: _userController.text.isEmpty ? null : int.parse(_userController.text),
                            items: items,
                            decoration: new InputDecoration(
                                labelText: '用户',
                                hintText: '请选择用户',
                                suffix: RaisedButton(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text("添加用户"),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    //在这里不能通过此方式获取FormState，context不对
                                    Navigator.pushNamed(
                                        context, '/router/user');
                                  },
                                )),
                            validator: (v) {
                              return v != null ? null : "用户不能为空";
                            });
                      }
                    } else {
                      // 请求未结束，显示loading
                      return CircularProgressIndicator();
                    }
                  },
                ),
                TextFormField(
                  enableInteractiveSelection: false,
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: '日期',
                      hintText: '请输入日期',
                      suffix: new FlatButton(
                          onPressed: () {
                            DatePicker.showDatePicker(context,
                                maxDateTime: DateTime.now(),
                                onConfirm: (dateTime, List<int> index) {
                              _dayController.text =
                                  dateTime.toString().split(" ")[0];
                            },
                                initialDateTime: DateTime.now(),
                                locale: DateTimePickerLocale.zh_cn);
                          },
                          child: new Text("选择"))),
                  controller: _dayController,
                  validator: (v) {
                    return v.trim().length > 0 ? null : "日期不能为空";
                  },
                ),
                TextFormField(
                    // *** this is important to prevent user interactive selection ***
                    enableInteractiveSelection: false,
                    autofocus: true,
                    controller: _timeController,
                    decoration: new InputDecoration(
                        labelText: '时间',
                        hintText: '请输入时间',
                        suffix: new FlatButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  pickerMode: DateTimePickerMode.time,
                                  onConfirm: (dateTime, List<int> index) {
                                _timeController.text = dateTime
                                    .toString()
                                    .split(" ")[1]
                                    .substring(0, 8);
                              },
                                  initialDateTime: DateTime.now(),
                                  locale: DateTimePickerLocale.zh_cn);
                            },
                            child: new Text("选择"))),
                    validator: (v) {
                      return v.trim().length > 0 ? null : "时间不能为空";
                    }),
                TextFormField(
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[0-9.]")),
                    ],
                    autofocus: true,
                    controller: _temperatureController,
                    decoration: new InputDecoration(
                        labelText: '温度', hintText: '请输入您的体温', suffixText: '℃'),
                    validator: (v) {
                      var error = v.trim().length > 0 ? null : "温度不能为空";
                      error = v.compareTo("20") >= 0
                          ? v.compareTo("40") <= 0 ? null : "温度区间20~40"
                          : "温度区间20~40";
                      return error;
                    }),
                Padding(
                    padding: const EdgeInsets.only(top: 28.0),
                    child: Row(children: [
                      Expanded(
                        child: RaisedButton(
                          padding: EdgeInsets.all(15.0),
                          child: Text("提交"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () async {
                            //在这里不能通过此方式获取FormState，context不对
                            //print(Form.of(context));

                            // 通过_formKey.currentState 获取FormState后，
                            // 调用validate()方法校验用户名密码是否合法，校验
                            // 通过后再提交数据。
                            if ((_formKey.currentState as FormState).validate()) {
                              //验证通过提交数据

                              var temperatureProvider =
                                  new TemperatureProvider();
                              TemperatureModel model = new TemperatureModel();
                              model.value =
                                  double.parse(_temperatureController.text);
                              model.date = _dayController.text;
                              model.time = _timeController.text;
                              model.userId = int.parse(_userController.text);
                              temperatureProvider.insert(model);

                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ]))
              ],
            ),
          ),
        )));
  }
}
