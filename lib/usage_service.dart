import 'dart:convert';
import 'dart:io';
import 'package:app_usage/app_usage.dart';
import 'package:cron/cron.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';

class Service {
  factory Service.instance() => _instance;

  Service._internal();

  static final _instance = Service._internal();

  void getUsageStats() async {
    final cron = Cron();
    cron.schedule(Schedule.parse('0 * * * *'), () async {
      // var date = DateTime.now();
      //if (date.hour >= 22 || date.hour <= 9) {
      List usageList = [];
      List difference = [];
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      Duration totalusageinhour = new Duration();

      try {
        DateTime endDate = DateTime.now();
        DateTime startDate = endDate.subtract(Duration(hours: 1));
        List<AppUsageInfo> infoList =
            await AppUsage.getAppUsage(startDate, endDate);

        for (var info in infoList) {
          usageList.add([
            info.packageName,
            info.usage.toString(),
          ]);
        }

        final String tmp = prefs.getString('usage');

        if (tmp != null) {
          List list2 = jsonDecode(tmp); // Stored List

          print(list2);
          print(usageList);
          for (var info in infoList) {
            usageList.add([
              info.packageName,
              info.usage.toString(),
            ]);
          }
          totalusageinhour = new Duration();
          for (int i = 0; i < list2.length; i++) {
            int index =
                usageList.indexWhere((element) => element[0] == list2[i][0]);
            if (index == -1) {
              difference.add([
                list2[i][0] + " " + usageList[i][0],
                (parseDuration(list2[i][1])
                        .difference(parseDuration(usageList[i][1])))
                    .abs(),
              ]);
              totalusageinhour += (parseDuration(list2[i][1])
                      .difference(parseDuration(usageList[i][1])))
                  .abs();
            } else {
              difference.add([
                list2[i][0] + " " + list2[i][0],
                (parseDuration(list2[i][1]).timeZoneOffset).abs(),
              ]);
              totalusageinhour +=
                  parseDuration(list2[i][1]).timeZoneOffset.abs();
            }
          }
          // difference = list2
          //     .toSet()
          //     .difference(usageList.toSet())
          //     .toList(); // Comparing Two Lists
          writeData(totalusageinhour);
          print(difference);
        } else {
          await prefs.setString('usage', jsonEncode(usageList));
        }
      } on AppUsageException catch (exception) {
        print(exception);
      }
      //  }
    });
  }

  DateTime parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return DateTime.now()
        .subtract(DateTime.now().timeZoneOffset)
        .add(Duration(hours: hours, minutes: minutes, microseconds: micros));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/duration.txt');
  }

  Future<File> writeData(Duration dur) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString(
        DateTime.now().toString() + "  ===  " + '$dur' + '\n',
        mode: FileMode.append);
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0.
      return "No data";
    }
  }
}
