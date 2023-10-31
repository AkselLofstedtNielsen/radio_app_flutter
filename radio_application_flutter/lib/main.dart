import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:radio_application_flutter/tableu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RadioApp(),
    );
  }
}

class RadioApp extends StatefulWidget {
  @override
  _RadioAppState createState() => _RadioAppState();
}

class _RadioAppState extends State<RadioApp> {
  //Variables for api data and programs blabla

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Radio App'),
        ),
        body: TableuWidget());
  }
}

void _showProgramDetails(BuildContext context, int index) {
  //Show detailed stuff

  showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Title'),
          content: Column(
            children: [
              Text('Description')
              //More stuff
            ],
          ),
        );
      });
}
