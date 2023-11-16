import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/app_retain_widget.dart';
import 'package:flutter_background/background_main.dart';
import 'package:path_provider/path_provider.dart';
import 'usage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  var channel = const MethodChannel('com.example/background_service');
  var callbackHandle = PluginUtilities.getCallbackHandle(backgroundMain);
  channel.invokeMethod('startService', callbackHandle.toRawHandle());

  Service.instance().getUsageStats();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Background Demo',
      home: AppRetainWidget(
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String filetext = "No data";
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/duration.txt');
  }

  Future<void> readData() async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();

      setState(() {
        filetext = contents;
      });
    } catch (e) {
      // If encountering an error, return 0.
      setState(() {
        filetext = "No data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Phone Usage'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                readData();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(child: Text('$filetext')),
        ));
  }
}
