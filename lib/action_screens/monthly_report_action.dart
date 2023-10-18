import 'package:ev_pmis_app/screen/materialprocurement/material_vendor.dart';
import 'package:ev_pmis_app/screen/monthlyreport/monthly_project.dart';
import 'package:flutter/material.dart';

class MonthlyReportAction extends StatefulWidget {
  String? role;
  String? cityName;
  String? depoName;
  MonthlyReportAction({super.key, this.cityName, this.role, this.depoName});

  @override
  State<MonthlyReportAction> createState() => _MonthlyReportActionState();
}

class _MonthlyReportActionState extends State<MonthlyReportAction> {
  Widget selectedUi = Container();

  @override
  void initState() {
    selectWidget();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return selectedUi;
  }

  Widget selectWidget() {
    switch (widget.role) {
      case 'user':
        selectedUi = MonthlyProject(depoName: widget.depoName);
        break;
      case 'admin':
        selectedUi = MonthlyProject(
          depoName: widget.depoName,
        );
    }

    return selectedUi;
  }
}
