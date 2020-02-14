import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:my_temperature/database/provider/UserProvider.dart';
import 'package:my_temperature/database/model/UserModel.dart';

class AddUserPage extends StatefulWidget {
  final String title;

  const AddUserPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddUserPageState();
  }
}

class AddUserPageState extends State<AddUserPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();

  GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          // 去掉导航栏下面的阴影
          elevation: 0.0,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('添加成员'),
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
                TextFormField(
                    autofocus: true,
                    controller: _nameController,
                    decoration: new InputDecoration(
                        labelText: '名称', hintText: '请输入成员名称'),
                    validator: (v) {
                      return v.trim().length > 0 ? null : "成员名称不能为空";
                    }),
                DropdownButtonFormField(
                    onChanged: (newValue) => setState(() {
                      _genderController.text = newValue;
                    }),
                    value: _genderController.text == null || _genderController.text.isEmpty ? 'm' :  _genderController.text,
                    items: [
                      DropdownMenuItem(
                        child: Text('男'),
                        value: 'm',
                      ),
                      DropdownMenuItem(
                        child: Text('女'),
                        value: 'f',
                      ),
                    ],
                    decoration: new InputDecoration(
                        labelText: '性别', hintText: '请选择成员性别'),
                    validator: (v) {
                      return v.trim().length > 0 ? null : "成员性别不能为空";
                    }),
              TextFormField(
                enableInteractiveSelection: false,
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: '生日',
                    hintText: '请输入生日',
                    suffix: new FlatButton(
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              maxDateTime: DateTime.now(),
                              onConfirm: (dateTime, List<int> index) {
                                _birthdayController.text =
                                dateTime.toString().split(" ")[0];
                              },
                              initialDateTime: DateTime.now(),
                              locale: DateTimePickerLocale.zh_cn);
                        },
                        child: new Text("选择"))),
                controller: _birthdayController,
                validator: (v) {
                  return v.trim().length > 0 ? null : "生日不能为空";
                },
              ),
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
                              var provider = new UserProvider();
                              UserModel model = new UserModel();
                              model.name = _nameController.text;
                              model.gender = _genderController.text;
                              model.birthday = _birthdayController.text;
                              provider.insert(model);

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
