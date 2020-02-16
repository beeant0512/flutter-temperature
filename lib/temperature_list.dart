import 'package:flutter/material.dart';
import 'package:my_temperature/database/model/UserModel.dart';
import 'package:my_temperature/temperature_manage.dart';

import 'database/model/TemperatureModel.dart';
import 'database/provider/TemperatureProvider.dart';

class ListTemperaturePage extends StatelessWidget {
  UserModel user;

  ListTemperaturePage({this.user});

  Future<List<TemperatureModel>> getAllTemperature(int userId) async {
    TemperatureProvider provider = new TemperatureProvider();
    Future<List<TemperatureModel>> temperatures =
        provider.fetchAllByUserId(userId, 'desc');
    return temperatures;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // 去掉导航栏下面的阴影
          elevation: 0.0,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("${this.user.name}的温度"),
        ),
        body: Center(
          child: FutureBuilder(
            future: getAllTemperature(this.user.id),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<TemperatureModel> temperatures = snapshot.data;
                return ListView.separated(
                  reverse: true,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  padding: const EdgeInsets.all(8),
                  itemCount: temperatures.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        subtitle: Text("${temperatures[index].date} ${temperatures[index].time}"),
                        title: Text(
                            "${temperatures[index].value}℃"),
                        trailing: new FlatButton(
                          child: new Text("编辑 >"),
                          onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ManageTemperaturePage(
                                        temperature: temperatures[index])))
                          },
                        ));
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ));
  }
}
