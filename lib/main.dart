// Flutter code sample for Scaffold

// This example shows a [Scaffold] with a [body] and [FloatingActionButton].
// The [body] is a [Text] placed in a [Center] in order to center the text
// within the [Scaffold]. The [FloatingActionButton] is connected to a
// callback that increments a counter.
//
// ![The Scaffold has a white background with a blue AppBar at the top. A blue FloatingActionButton is positioned at the bottom right corner of the Scaffold.](https://flutter.github.io/assets-for-api-docs/assets/material/scaffold.png)

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:weather/weather_library.dart';

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  String searchText = '';
  String key = 'c42af43eb20a8eb991ede3d3401d15e9';
  WeatherStation ws;
  List<Weather> _data = [];
  AppState _state = AppState.NOT_DOWNLOADED;
  double lat, lon;

  @override
  void initState() {
    super.initState();
    ws = new WeatherStation(key);
  }

  void queryForecast() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _state = AppState.DOWNLOADING;
    });

    List<Weather> forecasts = await ws.fiveDayForecast(lat, lon);
    print(forecasts);
    print('got here matey');
    setState(() {
      _data = forecasts;
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  void queryWeather() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    setState(() {
      _state = AppState.DOWNLOADING;
    });

    Weather weather = await ws.currentWeather(lat, lon);
    setState(() {
      _data = [weather];
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  Widget contentFinishedDownload() {
    return Center(
      child: ListView.separated(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_data[index].toString()),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }

  Widget contentDownloading() {
    return Container(
        margin: EdgeInsets.all(25),
        child: Column(children: [
          Text(
            'Fetching Weather...',
            style: TextStyle(fontSize: 20),
          ),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
        ]));
  }

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Press the button to download the Weather forecast',
          ),
        ],
      ),
    );
  }

  Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
          ? contentDownloading()
          : contentNotDownloaded();

  void _saveLat(String input) {
    lat = double.tryParse(input);
    print(lat);
  }

  void _saveLon(String input) {
    lon = double.tryParse(input);
    print(lon);
  }

  Widget _latTextField() {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: EdgeInsets.all(10),
        child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter longitude'),
            keyboardType: TextInputType.number,
            onChanged: _saveLat,
            onSubmitted: _saveLat));
  }

  Widget _lonTextField() {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: EdgeInsets.all(10),
        child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter longitude'),
            keyboardType: TextInputType.number,
            onChanged: _saveLon,
            onSubmitted: _saveLon));
  }

  Widget _weatherButton() {
    return FlatButton(
      child: Text('Fetch weather'),
      onPressed: queryWeather,
      color: Colors.blue,
    );
  }

  Widget _forecastButton() {
    return FlatButton(
      child: Text('Fetch forecast'),
      onPressed: queryForecast,
      color: Colors.blue,
    );
  }


  Widget buildSearchBar() {
    return Form(
        key: _formKey,
        child: TextFormField(
            decoration: InputDecoration(
          hintText: 'Enter your location',
        )));
  }

  Widget buildMainColumn() {
    Widget searchBarA = buildSearchBar();
    return Column(children: [
      searchBarA,
      _latTextField(),
      _lonTextField(),
      _weatherButton(),
      _forecastButton(),
      Text(
        'Output:',
        style: TextStyle(fontSize: 20),
      ),
      Divider(
        height: 20.0,
        thickness: 2.0,
      ),
      Expanded(child: _resultView()) // <---This is the search bar
      // <--- add it here,
      // outWeather
      // Text('Hello there')
    ]);
  }

  Widget build(BuildContext context) {
    Widget mainColumn = buildMainColumn();
    Widget paddedMainColumn =
        Padding(child: mainColumn, padding: EdgeInsets.all(26.0));
    return Scaffold(
      appBar: AppBar(
        title: const Text('To The Crag'),
      ),
      body: paddedMainColumn,
    );
  }
}
