import 'package:flutter/material.dart';
import 'package:flutter_weather/main.dart';
import 'package:flutter_weather/src/api/weather_api_client.dart';
import 'package:flutter_weather/src/bloc/weather_bloc.dart';
import 'package:flutter_weather/src/bloc/weather_event.dart';
import 'package:flutter_weather/src/bloc/weather_state.dart';
import 'package:flutter_weather/src/repository/weather_repository.dart';
import 'package:flutter_weather/src/api/api_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/src/widgets/weather_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

enum OptionsMenu { changeCity, settings }

class WeatherScreen extends StatefulWidget {
  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(
          httpClient: http.Client(), apiKey: ApiKey.OPEN_WEATHER_MAP));
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  WeatherBloc _weatherBloc;
  String _cragName = 'bengaluru';
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();

  Widget inputForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            textAlign: TextAlign.center,
            onFieldSubmitted: (text) {
              _cragName = text;
              _fetchWeatherWithCity();
            },
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
              hintText: 'Enter your destination',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _weatherBloc = WeatherBloc(weatherRepository: widget.weatherRepository);
    _fetchWeatherWithLocation().catchError((error) {
      _fetchWeatherWithCity();
    });
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppStateContainer.of(context).theme.primaryColor,
          elevation: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                    color: AppStateContainer.of(context)
                        .theme
                        .accentColor
                        .withAlpha(80),
                    fontSize: 14),
              )
            ],
          ),
          actions: <Widget>[
            PopupMenuButton<OptionsMenu>(
                child: Icon(
                  Icons.more_vert,
                  color: AppStateContainer.of(context).theme.accentColor,
                ),
                onSelected: this._onOptionMenuItemSelected,
                itemBuilder: (context) => <PopupMenuEntry<OptionsMenu>>[
                      PopupMenuItem<OptionsMenu>(
                        value: OptionsMenu.settings,
                        child: Text("settings"),
                      ),
                    ])
          ],
        ),
        backgroundColor: Colors.white,
        body: Material(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                color: AppStateContainer.of(context).theme.primaryColor),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BlocBuilder(
                  bloc: _weatherBloc,
                  builder: (_, WeatherState weatherState) {
                    if (weatherState is WeatherLoaded) {
                      this._cragName = weatherState.weather.cityName;
                      _fadeController.reset();
                      _fadeController.forward();
                      // Create a column of [Padding(inputForm), WeatherWidget]
                      // vs before we just had WeatherWidget
                      return Column(children: [
                        Padding(
                            child: inputForm(), padding: EdgeInsets.all(26.0)),
                        WeatherWidget(
                          weather: weatherState.weather,
                        )
                      ]);
                    } else if (weatherState is WeatherError ||
                        weatherState is WeatherEmpty) {
                      String errorText =
                          'There was an error fetching weather data';
                      if (weatherState is WeatherError) {
                        if (weatherState.errorCode == 404) {
                          errorText =
                              'We have trouble fetching weather for $_cragName';
                        }
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            errorText,
                            style: TextStyle(
                                color: AppStateContainer.of(context)
                                    .theme
                                    .accentColor),
                          ),
                          FlatButton(
                            child: Text(
                              "Go Home",
                              style: TextStyle(
                                  color: AppStateContainer.of(context)
                                      .theme
                                      .accentColor),
                            ),
                            // Replace this with the function which navigates home
                            // This is a function
                            // () {
                            // Do something in here
                            // }
                            onPressed: () {
                              Navigator.of(context).pushNamed("/home");
                            },
                          )
                        ],
                      );
                    } else if (weatherState is WeatherLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor:
                              AppStateContainer.of(context).theme.primaryColor,
                        ),
                      );
                    }
                  }),
            ),
          ),
        ));
  }

  _onOptionMenuItemSelected(OptionsMenu item) {
    Navigator.of(context).pushNamed("/settings");
  }

  _fetchWeatherWithCity() async {
    // Get location from /search/_crag_name
    final http.Response response = await http.get('http://10.0.2.2:8000/search/' + _cragName);
    final cragList = json.decode(response.body);

    final firstCrag = cragList[0];
    final double longitude = double.parse(firstCrag["longitude"]);
    final double latitude = double.parse(firstCrag["latitude"]);

    // Dispatch weather
    _weatherBloc.dispatch(FetchWeather(
        longitude: longitude, latitude: latitude));
  }

  _fetchWeatherWithLocation() async {
    var permissionHandler = PermissionHandler();
    var permissionResult = await permissionHandler
        .requestPermissions([PermissionGroup.locationWhenInUse]);

    switch (permissionResult[PermissionGroup.locationWhenInUse]) {
      case PermissionStatus.denied:
      case PermissionStatus.unknown:
        print('location permission denied');
        _showLocationDeniedDialog(permissionHandler);
        throw Error();
    }

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    _weatherBloc.dispatch(FetchWeather(
        longitude: position.longitude, latitude: position.latitude));
  }

  void _showLocationDeniedDialog(PermissionHandler permissionHandler) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Location is disabled :(',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Enable!',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                onPressed: () {
                  permissionHandler.openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
