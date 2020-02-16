import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:my_temperature/database/model/TemperatureModel.dart';
import 'package:my_temperature/database/model/UserModel.dart';
import 'package:my_temperature/database/provider/TemperatureProvider.dart';
import 'package:my_temperature/database/provider/UserProvider.dart';

class ManageTemperaturePage extends StatefulWidget {
  final TemperatureModel temperature;

  const ManageTemperaturePage({Key key, this.temperature}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ManageTemperaturePageState(this.temperature);
  }
}

class ManageTemperaturePageState extends State<ManageTemperaturePage> {
  TextEditingController _temperatureController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TemperatureModel temperature;

  GlobalKey _formKey = new GlobalKey<FormState>();
  var dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if(null != temperature){
      _dayController.text = temperature.date;
      _timeController.text = temperature.time;
      _userController.text = temperature.userId.toString();
      _temperatureController.text = temperature.value.toString();
    } else {
      var dateTimes = dateTime.toString().split(" ");
      _dayController.text = dateTimes[0];
      _timeController.text = dateTimes[1].substring(0, 8);
    }
  }

  ManageTemperaturePageState(this.temperature);

  Future<List<UserModel>> getAllUsers() async {
    UserProvider userProvider = new UserProvider();
    Future<List<UserModel>> users = userProvider.fetchAll();
    return users;
  }

  @override
  Widget build(BuildContext context) {
    String title = null == temperature ? "添加温度" : "编辑温度";
    return Scaffold(
        appBar: AppBar(
          // 去掉导航栏下面的阴影
          elevation: 0.0,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(title),
        ),
        // 使用 SingleChildScrollView 包裹 解决 调出键盘时报溢出异常
        body: SingleChildScrollView(
            child: Center(
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
                          List<UserModel> users = snapshot.data;
                          // 用户没有 先添加用户
                          if (users.isEmpty) {
                            return TextFormField(
                              enableInteractiveSelection: false,
                              autofocus: true,
                              decoration: new InputDecoration(
                                  icon: Icon(Icons.person),
                                  enabled: false,
                                  labelText: '用户',
                                  hintText: '请先添加用户',
                                  suffix: new FlatButton(
                                      onPressed: () async {
                                        Navigator.pushNamed(
                                            context, '/router/user');
                                      },
                                      child: new Text("添加"))),
                              controller: _userController,
                              validator: (v) {
                                return v.trim().length > 0 ? null : "用户不能为空";
                              },
                            );
                          }

                          List<DropdownMenuItem> items = [];
                          // 有用户，显示下拉框
                          users.forEach((user) => {
                                items.add(DropdownMenuItem(
                                  child: Text(user.name),
                                  value: user.id,
                                ))
                              });
                          if (_userController.text.isEmpty) {
                            _userController.text = items[0].value.toString();
                          }

                          return DropdownButtonFormField(
                              onChanged: (newValue) => setState(() {
                                    _userController.text = newValue.toString();
                                  }),
                              value: int.parse(_userController.text),
                              items: items,
                              decoration: new InputDecoration(
                                  icon: Icon(Icons.person),
                                  labelText: '用户',
                                  hintText: '请选择用户',
                                  suffix: FlatButton(
                                    child: Text("添加"),
                                    onPressed: () async {
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
                        icon: Icon(Icons.date_range),
                        labelText: '日期',
                        hintText: '请输入日期',
                        suffix: new FlatButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  maxDateTime: dateTime,
                                  onConfirm: (dateTime, List<int> index) {
                                _dayController.text =
                                    dateTime.toString().split(" ")[0];
                              },
                                  initialDateTime:  DateTime.parse("${_dayController.text} ${_timeController.text}"),
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
                          icon: Icon(Icons.access_time),
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
                                    initialDateTime: DateTime.parse("${_dayController.text} ${_timeController.text}"),
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
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      controller: _temperatureController,
                      decoration: new InputDecoration(
                          icon: Icon(Icons.whatshot),
                          labelText: '温度',
                          hintText: '请输入您的体温',
                          suffix: new FlatButton(child: new Text("℃"), onPressed: () => {},)),
                      validator: (v) {
                        var error = v.trim().length > 0 ? null : "温度不能为空";
                        error = v.compareTo("35") >= 0
                            ? v.compareTo("42") <= 0 ? null : "温度区间35~42"
                            : "温度区间35~42";
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
                              if ((_formKey.currentState as FormState)
                                  .validate()) {
                                //验证通过提交数据

                                var temperatureProvider =
                                    new TemperatureProvider();
                                TemperatureModel model = new TemperatureModel();
                                model.value =
                                    double.parse(_temperatureController.text);
                                model.date = _dayController.text;
                                model.time = _timeController.text;
                                model.userId = int.parse(_userController.text);
                                if(null != temperature){
                                  model.id  = temperature.id;
                                  temperatureProvider.update(model);
                                } else {
                                  temperatureProvider.insert(model);
                                }

                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ]))
                ],
              ),
            ),
          ),
        )));
  }
}
