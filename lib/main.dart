import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_temperature/add_user.dart';
import 'package:my_temperature/database/provider/TemperatureProvider.dart';
import 'package:my_temperature/temperature_list.dart';
import 'package:my_temperature/temperature_manage.dart';

import 'database/model/TemperatureModel.dart';
import 'database/model/UserModel.dart';
import 'database/provider/UserProvider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '温度计',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '温度计'),
      routes: <String, WidgetBuilder>{
        // 这里可以定义静态路由，不能传递参数
        '/router/temperature': (_) => new ManageTemperaturePage(),
        '/router/user': (_) => new AddUserPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showTitle = true;

  // 10 全部 0 今天 -1 昨天 -2 前天
  int daysBefore = 10;

  static List<Choice> choices = const <Choice>[
    const Choice(title: '全部', icon: Icons.directions_bike),
    const Choice(title: '今天', icon: Icons.directions_car),
    const Choice(title: '昨天', icon: Icons.directions_car),
    const Choice(title: '显示数值', icon: Icons.directions_boat),
    const Choice(title: '隐藏数值', icon: Icons.directions_bus),
  ];

  Choice _selectedChoice = choices[0]; // The app's "state".

  void _select(Choice choice) {
    switch (choice.title) {
      case "全部":
        setState(() {
          daysBefore = 10;
        });
        break;
      case "今天":
        setState(() {
          daysBefore = 0;
        });
        break;
      case "昨天":
        setState(() {
          daysBefore = -1;
        });
        break;
      case "显示数值":
        setState(() {
          showTitle = true;
        });
        break;
      case "隐藏数值":
        setState(() {
          showTitle = false;
        });
        break;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    UserProvider userProvider = new UserProvider();
    Future<List<UserModel>> users = userProvider.fetchAll();
    return users;
  }

  Future<List<TemperatureModel>> getAllTemperature(
      int userId, int daysBefore) async {
    TemperatureProvider provider = new TemperatureProvider();
    Future<List<TemperatureModel>> temperatures;
    if (daysBefore == 10) {
      temperatures = provider.fetchAllByUserId(userId, "asc");
    } else {
      temperatures = provider.fetchAllByUserIdByDay(
          userId,
          DateTime.now()
              .add(new Duration(days: daysBefore))
              .toString()
              .split(" ")[0],
          "asc");
    }
    return temperatures;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: [
            PopupMenuButton<Choice>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: getAllUsers(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<UserModel> users = snapshot.data;
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                padding: const EdgeInsets.all(8),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                    child: FutureBuilder(
                        future: getAllTemperature(users[index].id, daysBefore),
                        builder: (BuildContext context,
                            AsyncSnapshot snapshotTemperature) {
                          if (snapshotTemperature.connectionState ==
                              ConnectionState.done) {
                            List<TemperatureModel> temperatures =
                                snapshotTemperature.data;
                            if (temperatures == null) {
                              return CircularProgressIndicator();
                            }
                            var xAxis = [];
                            List<double> yAxis = List<double>();
                            temperatures.forEach((temperature) => {
                                  xAxis.add(
                                      '\"${temperature.date.substring(5)} ${temperature.time.substring(0, 5)}\"'),
                                  yAxis.add(temperature.value)
                                });
                            var xAxisString = "[" + xAxis.join(",") + "]";
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(users[index].name),
                                  trailing: new FlatButton.icon(
                                    label: Text(""),
                                    onPressed: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ListTemperaturePage(
                                                      user: users[index])))
                                    },
                                    icon: Icon(Icons
                                        .keyboard_arrow_right), //`Icon` to display
                                  ),
                                ),
                                Container(
                                  height: 250,
                                  child: Echarts(
                                    option:
                                        getEchartsOptions(xAxisString, yAxis),
                                  ),
                                )
                              ],
                            );
                          } else {
                            // 请求未结束，显示loading
                            return CircularProgressIndicator();
                          }
                        }),
                  );
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => ManageTemperaturePage())),
        tooltip: '添加温度',
        child: Icon(Icons.add),
      ),
    );
  }

  getEchartsOptions(String xAxisString, List<double> yAxis) {
    var options = '''
    {
      title: {
          text: '体温曲线'
      },
      dataZoom: [
        {
            show: true,
            realtime: true,
            start: 90,
            end: 100
        },
        {
            type: 'inside',
            realtime: true,
            start: 0,
            end: 100
        }
      ],
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      tooltip: {
          trigger: 'axis',
          axisPointer: {
              type: 'cross',
              animation: false,
              label: {
                  backgroundColor: '#505765'
              }
          }
      },
      xAxis: {
        type: 'category',
        data: $xAxisString,
      },
      yAxis: {
        type: 'value',
        min: function (value) {
            return value.min - 0.5;
        },
        max: function (value) {
            return value.max + 0.5;
        },
        minInterval: 0.2,
        maxInterval: 0.5,
      },
      series: [{
        data: $yAxis,
        type: 'line',''';
    if (showTitle) {
      options += '''
         label: {
                normal: {
                    show: true,
                    position: 'top'
                }
            },
      ''';
    }
    options += '''
      }]
    }''';
    return options;
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
