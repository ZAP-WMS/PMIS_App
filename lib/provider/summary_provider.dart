import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/daily_projectModel.dart';

class SummaryProvider extends ChangeNotifier {
  Map<String, dynamic> alldate = Map();
  List<DailyProjectModel> _dailydata = [];

  List<DailyProjectModel> get dailydata {
    return _dailydata;
  }

  fetchdailydata(
      String depoName, String userId, DateTime date, DateTime endDate) async {
    final List<DailyProjectModel> loadeddata = [];
    for (DateTime initialdate = date;
        initialdate.isBefore(endDate.add(const Duration(days: 1)));
        initialdate = initialdate.add(const Duration(days: 1))) {
      print(DateFormat.yMMMMd().format(initialdate));
      FirebaseFirestore.instance
          .collection('DailyProjectReport2')
          .doc(depoName)
          .collection('userId')
          .doc(userId)
          .collection('date')
          .doc(DateFormat.yMMMMd().format(initialdate))
          .get()
          .then((value) {
        if (value.data() != null) {
          print('swswssw${value.data()!['data'].length}');
          for (int i = 0; i < value.data()!['data'].length; i++) {
            var _data = value.data()!['data'][i];
            loadeddata.add(DailyProjectModel.fromjson(_data));
          }
          _dailydata = loadeddata;
          notifyListeners();
        }
      });
    }
  }
}
