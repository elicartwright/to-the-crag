// Flutter code sample for Scaffold

// This example shows a [Scaffold] with a [body] and [FloatingActionButton].
// The [body] is a [Text] placed in a [Center] in order to center the text
// within the [Scaffold]. The [FloatingActionButton] is connected to a
// callback that increments a counter.
//
// ![The Scaffold has a white background with a blue AppBar at the top. A blue FloatingActionButton is positioned at the bottom right corner of the Scaffold.](https://flutter.github.io/assets-for-api-docs/assets/material/scaffold.png)

import 'package:flutter/material.dart';

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
      // Weather widget here
    ]);
  }

  Widget build(BuildContext context) {
    Widget mainColumn = buildMainColumn();
    Widget paddedMainColumn = Padding(child: mainColumn, padding: EdgeInsets.all(26.0));
    return Scaffold(
      appBar: AppBar(
        title: const Text('To The Crag'),
      ),
      body: paddedMainColumn,
    );
  }
}
