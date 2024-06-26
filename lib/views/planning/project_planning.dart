import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_pmis_app/views/citiespage/depot.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gantt_chart/gantt_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../components/Loading_page.dart';
import '../../PMIS/datasource/key_datasource.dart';
import '../../PMIS/provider/cities_provider.dart';
import '../../style.dart';
import '../../models/employee.dart';
import '../../PMIS/widgets/custom_appbar.dart';
import '../../PMIS/widgets/navbar.dart';
import '../../PMIS/user/keyevents/Grid_DataTableA2.dart';
import '../../PMIS/view_AllFiles.dart';

/// The application that contains datagrid on it.

/// The home page of the application which hosts the datagrid.
class KeyEvents extends StatefulWidget {
  /// Creates the home page.
  String? depoName;
  String? cityName;
  String role;
  String? userId;
  KeyEvents(
      {Key? key, this.userId, this.depoName, this.cityName, required this.role})
      : super(key: key);

  @override
  _KeyEventsState createState() => _KeyEventsState();
}

class _KeyEventsState extends State<KeyEvents> {
  late KeyDataSourceKeyEvents _KeyDataSourceKeyEvents;
  List<Employee> _employees = <Employee>[];
  late DataGridController _dataGridController;
  //  List<DataGridRow> dataGridRows = [];
  DataGridRow? dataGridRow;
  RowColumnIndex? rowColumnIndex;
  GridColumn? column;
  List<dynamic> tabledata2 = [];
  Stream? yourstream;
  Stream? yourstream1;
  double totalweightage = 0;
  List<String> startdate = [];
  List<String> enddate = [];
  List<String> asstartdate = [];
  List<String> asenddate = [];
  String? actualstartdate;
  String? actualenddate;
  List<double> weight = [];
  List<ChartData> chartData = <ChartData>[];
  List<ChartData> chartData2 = <ChartData>[];
  String? sdate;
  String? edate;
  String? asdate;
  String? aedate;
  var alldata;
  bool _isLoading = false;
  bool _isInit = true;
  int? length;
  final scrollController = ScrollController();
  List<GanttEventBase> ganttdata = [];
  List<String> startDate = [];
  List<String> endDate = [];
  List<String> actualstart = [];
  List<String> actualend = [];
  List<int> srNo = [];

  String? sdate2,
      sdate3,
      sdate4,
      sdate5,
      sdate6,
      sdate7,
      sdate8,
      sdate9,
      sdate10;
  String? edate2,
      edate3,
      edate4,
      edate5,
      edate6,
      edate7,
      edate8,
      edate9,
      edate10;
  String? asdate2,
      asdate3,
      asdate4,
      asdate5,
      asdate6,
      asdate7,
      asdate8,
      asdate9,
      asdate10;
  String? aedate2,
      aedate3,
      aedate4,
      aedate5,
      aedate6,
      aedate7,
      aedate8,
      aedate9,
      aedate10;

  List<double> weight2 = [];
  List<double> weight3 = [];
  List<double> weight4 = [];
  List<double> weight5 = [];
  List<double> weight6 = [];
  List<double> weight7 = [];
  List<double> weight8 = [];
  List<double> weight9 = [];
  List<double> weight10 = [];

  String? startdate2,
      enddate2,
      asstartdate2,
      asenddate2,
      actualstartdate2,
      actualenddate2;
  String? startdate3,
      enddate3,
      asstartdate3,
      asenddate3,
      actualstartdate3,
      actualenddate3;
  String? startdate4,
      enddate4,
      asstartdate4,
      asenddate4,
      actualstartdate4,
      actualenddate4;
  String? startdate5,
      enddate5,
      asstartdate5,
      asenddate5,
      actualstartdate5,
      actualenddate5;
  String? startdate6,
      enddate6,
      asstartdate6,
      asenddate6,
      actualstartdate6,
      actualenddate6;
  String? startdate7,
      enddate7,
      asstartdate7,
      asenddate7,
      actualstartdate7,
      actualenddate7;
  String? startdate8,
      enddate8,
      asstartdate8,
      asenddate8,
      actualstartdate8,
      actualenddate8;
  String? startdate9,
      enddate9,
      asstartdate9,
      asenddate9,
      actualstartdate9,
      actualenddate9;

  double? perc2 = 0,
      perc3 = 0,
      perc4 = 0,
      perc5 = 0,
      perc6 = 0,
      perc7 = 0,
      perc8 = 0,
      perc9 = 0,
      perc10 = 0;
  int balanceQty2 = 0,
      balanceQty3 = 0,
      balanceQty4 = 0,
      balanceQty5 = 0,
      balanceQty6 = 0,
      balanceQty7 = 0,
      balanceQty8 = 0,
      balanceQty9 = 0,
      balanceQty10 = 0;
  int scope2 = 0,
      scope3 = 0,
      scope4 = 0,
      scope5 = 0,
      scope6 = 0,
      scope7 = 0,
      scope8 = 0,
      scope9 = 0,
      scope10 = 0;
  int totalBalanceQty2 = 0,
      totalBalanceQty3 = 0,
      totalBalanceQty4 = 0,
      totalBalanceQty5 = 0,
      totalBalanceQty6 = 0,
      totalBalanceQty7 = 0,
      totalBalanceQty8 = 0,
      totalBalanceQty9 = 0,
      totalBalanceQty10 = 0;
  int totalscope2 = 0,
      totalscope3 = 0,
      totalscope4 = 0,
      totalscope5 = 0,
      totalscope6 = 0,
      totalscope7 = 0,
      totalscope8 = 0,
      totalscope9 = 0,
      totalscope10 = 0;

  bool _isloading = true;
  @override
  void initState() {
    widget.cityName =
        Provider.of<CitiesProvider>(context, listen: false).getName;
    yourstream = FirebaseFirestore.instance
        .collection('KeyEventsTable')
        .doc(widget.depoName!)
        .collection('KeyDataTable')
        .doc(userId)
        .collection('KeyAllEvents')
        // .doc('${widget.depoName}')
        .snapshots();

    _isLoading = false;
    setState(() {});
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeLeft,
    ]);
    // getUserId().whenComplete(() {
    //   yourstream = FirebaseFirestore.instance
    //       .collection('KeyEventsTable')
    //       .doc(widget.depoName!)
    //       .collection('KeyDataTable')
    //       .doc(userId)
    //       .collection('KeyAllEvents')
    //       // .doc('${widget.depoName}')
    //       .snapshots();

    //   _isLoading = false;
    //   setState(() {});
    // });

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // List<Widget> menuwidget = [];

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
        :
        // keyBoardArrow(
        //     scrollController: scrollController,
        //     myScaffold:
        Scaffold(
            drawer: NavbarDrawer(
              role: widget.role,
            ),
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: CustomAppBar(
                  depoName: widget.depoName ?? '',
                  title: 'Project Planning',
                  height: 50,
                  isSync: false,
                  isCentered: false,
                  // showDepoBar: true,
                  // toPlanning: true,
                  // cityname: widget.cityName,
                  // text:
                  //     '${widget.cityName} / ${widget.depoName} / Key Events',
                  // haveSynced: false,
                )),

            //  AppBar(
            //   title: Text(
            //       '${widget.cityName} / ${widget.depoName} / Key Events  '),
            //   backgroundColor: blue,
            // ),
            body: StreamBuilder(
                stream: yourstream,
                builder: (context, snapshot) {
                  ganttdata = [];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingPage();
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length != 0) {
                      int length = snapshot.data.docs.length;
                      startdate.clear();
                      enddate.clear();
                      asstartdate.clear();
                      asenddate.clear();
                      weight.clear();
                      for (int i = 0; i < length; i++) {
                        for (int j = 0; j < length; j++) {
                          totalscope10 = 0;
                          totalBalanceQty10 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A10') {
                            var alldataA10 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate10 = alldataA10[0]['StartDate'];
                            edate10 =
                                alldataA10[alldataA10.length - 1]['EndDate'];
                            asdate10 = alldataA10[0]['ActualStart'];
                            aedate10 =
                                alldataA10[alldataA10.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA10.length; i++) {
                              perc10 = 0;
                              scope10 = alldataA10[i]['QtyScope'];
                              balanceQty10 = alldataA10[i]['QtyScope'] -
                                  alldataA10[i]['QtyExecuted'];
                              var weightage = alldataA10[i]['Weightage'];
                              totalscope10 = scope10 + totalscope10;
                              totalBalanceQty10 =
                                  balanceQty10 + totalBalanceQty10;
                              totalweightage = totalweightage + weightage;
                            }
                            perc10 = ((totalBalanceQty10 / totalscope10) *
                                totalweightage);
                            weight10.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope2 = 0;
                          totalBalanceQty2 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A2') {
                            var alldataA2 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate2 = alldataA2[0]['StartDate'];
                            edate2 = alldataA2[alldataA2.length - 1]['EndDate'];
                            asdate2 = alldataA2[0]['ActualStart'];
                            aedate2 =
                                alldataA2[alldataA2.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA2.length; i++) {
                              perc2 = 0;
                              scope2 = alldataA2[i]['QtyScope'];
                              balanceQty2 = alldataA2[i]['QtyScope'] -
                                  alldataA2[i]['QtyExecuted'];

                              var weightage = alldataA2[i]['Weightage'];
                              totalweightage = totalweightage + weightage;
                              totalscope2 = scope2 + totalscope2;
                              totalBalanceQty2 = balanceQty2 + totalBalanceQty2;
                            }
                            perc2 = ((totalBalanceQty2 / totalscope2) *
                                totalweightage);
                            print(perc2);
                            weight2.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope3 = 0;
                          totalBalanceQty3 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A3') {
                            var alldataA3 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate3 = alldataA3[0]['StartDate'];
                            edate3 = alldataA3[alldataA3.length - 1]['EndDate'];
                            asdate3 = alldataA3[0]['ActualStart'];
                            aedate3 =
                                alldataA3[alldataA3.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA3.length; i++) {
                              perc3 = 0;
                              scope3 = alldataA3[i]['QtyScope'];
                              balanceQty3 = alldataA3[i]['QtyScope'] -
                                  alldataA3[i]['QtyExecuted'];
                              var weightage = alldataA3[i]['Weightage'];
                              totalweightage = totalweightage + weightage;
                              totalscope3 = scope3 + totalscope3;
                              totalBalanceQty3 = balanceQty3 + totalBalanceQty3;
                            }
                            perc3 = ((totalBalanceQty3 / totalscope3) *
                                totalweightage);
                            print(perc3);
                            weight3.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope4 = 0;
                          totalBalanceQty4 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A4') {
                            var alldataA4 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate4 = alldataA4[0]['StartDate'];
                            edate4 = alldataA4[alldataA4.length - 1]['EndDate'];
                            asdate4 = alldataA4[0]['ActualStart'];
                            aedate4 =
                                alldataA4[alldataA4.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA4.length; i++) {
                              perc4 = 0;
                              scope4 = alldataA4[i]['QtyScope'];
                              balanceQty4 = alldataA4[i]['QtyScope'] -
                                  alldataA4[i]['QtyExecuted'];
                              var weightage = alldataA4[i]['Weightage'];
                              totalweightage = totalweightage + weightage;
                              totalscope4 = scope4 + totalscope4;
                              totalBalanceQty4 = balanceQty4 + totalBalanceQty4;
                            }
                            perc4 = ((totalBalanceQty4 / totalscope4) *
                                totalweightage);
                            weight4.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope5 = 0;
                          totalBalanceQty5 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A5') {
                            var alldataA5 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate5 = alldataA5[0]['StartDate'];
                            edate5 = alldataA5[alldataA5.length - 1]['EndDate'];
                            asdate5 = alldataA5[0]['ActualStart'];
                            aedate5 =
                                alldataA5[alldataA5.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA5.length; i++) {
                              perc5 = 0;
                              scope5 = alldataA5[i]['QtyScope'];
                              balanceQty5 = alldataA5[i]['QtyScope'] -
                                  alldataA5[i]['QtyExecuted'];
                              var weightage = alldataA5[i]['Weightage'];
                              totalscope5 = scope5 + totalscope5;
                              totalBalanceQty5 = balanceQty5 + totalBalanceQty5;
                              totalweightage = totalweightage + weightage;
                            }
                            perc5 = ((totalBalanceQty5 / totalscope5) *
                                totalweightage);
                            weight5.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope6 = 0;
                          totalBalanceQty6 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A6') {
                            var alldataA6 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate6 = alldataA6[0]['StartDate'];
                            edate6 = alldataA6[alldataA6.length - 1]['EndDate'];
                            asdate6 = alldataA6[0]['ActualStart'];
                            aedate6 =
                                alldataA6[alldataA6.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA6.length; i++) {
                              perc6 = 0;
                              scope6 = alldataA6[i]['QtyScope'];
                              balanceQty6 = alldataA6[i]['QtyScope'] -
                                  alldataA6[i]['QtyExecuted'];
                              totalscope6 = scope6 + totalscope6;
                              totalBalanceQty6 = balanceQty6 + totalBalanceQty6;
                              var weightage = alldataA6[i]['Weightage'];
                              totalweightage = totalweightage + weightage;
                            }
                            perc6 = ((totalBalanceQty6 / totalscope6) *
                                totalweightage);
                            weight6.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope7 = 0;
                          totalBalanceQty7 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A7') {
                            var alldataA7 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate7 = alldataA7[0]['StartDate'];
                            edate7 = alldataA7[alldataA7.length - 1]['EndDate'];
                            asdate7 = alldataA7[0]['ActualStart'];
                            aedate7 =
                                alldataA7[alldataA7.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA7.length; i++) {
                              perc7 = 0;
                              scope7 = alldataA7[i]['QtyScope'];
                              balanceQty7 = alldataA7[i]['QtyScope'] -
                                  alldataA7[i]['QtyExecuted'];
                              totalscope7 = scope7 + totalscope7;
                              totalBalanceQty7 = balanceQty7 + totalBalanceQty7;
                              var weightage = alldataA7[i]['Weightage'];
                              totalweightage = totalweightage + weightage;
                            }
                            perc7 = ((totalBalanceQty7 / totalscope7) *
                                totalweightage);
                            weight7.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope8 = 0;
                          totalBalanceQty8 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A8') {
                            var alldataA8 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate8 = alldataA8[0]['StartDate'];
                            edate8 = alldataA8[alldataA8.length - 1]['EndDate'];
                            asdate8 = alldataA8[0]['ActualStart'];
                            aedate8 =
                                alldataA8[alldataA8.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA8.length; i++) {
                              perc8 = 0;
                              scope8 = alldataA8[i]['QtyScope'];
                              balanceQty8 = alldataA8[i]['QtyScope'] -
                                  alldataA8[i]['QtyExecuted'];
                              var weightage = alldataA8[i]['Weightage'];
                              totalscope8 = scope8 + totalscope8;
                              totalBalanceQty8 = balanceQty8 + totalBalanceQty8;
                              totalweightage = totalweightage + weightage;
                            }
                            perc8 = ((totalBalanceQty8 / totalscope8) *
                                totalweightage);
                            weight8.add(totalweightage);
                          }
                        }

                        for (int j = 0; j < length; j++) {
                          totalscope9 = 0;
                          totalBalanceQty9 = 0;
                          totalweightage = 0;
                          if (snapshot.data.docs[j].reference.id.toString() ==
                              '${widget.depoName}A9') {
                            var alldataA9 =
                                snapshot.data.docs[j]['data'] as List<dynamic>;
                            sdate9 = alldataA9[0]['StartDate'];
                            edate9 = alldataA9[alldataA9.length - 1]['EndDate'];
                            asdate9 = alldataA9[0]['ActualStart'];
                            aedate9 =
                                alldataA9[alldataA9.length - 1]['ActualEnd'];

                            for (int i = 0; i < alldataA9.length; i++) {
                              perc9 = 0;
                              scope9 = alldataA9[i]['QtyScope'];
                              balanceQty9 = alldataA9[i]['QtyScope'] -
                                  alldataA9[i]['QtyExecuted'];
                              totalscope9 = scope9 + totalscope9;
                              totalBalanceQty9 = balanceQty9 + totalBalanceQty9;
                              var weightage = alldataA9[i]['Weightage'];
                              totalweightage = totalweightage + weightage;
                            }
                          }
                          perc9 = ((totalBalanceQty9 / totalscope9) *
                              totalweightage);
                          weight9.add(totalweightage);
                        }
                      }
                      startDate.clear();
                      enddate.clear();
                      actualstart.clear();
                      actualend.clear();
                      srNo.clear();
                      for (int j = 0; j < length; j++) {
                        // if (snapshot.data.docs[j].reference.id.toString() ==
                        //     '${widget.depoName}A$j') {
                        if (j != 0) {
                          var startdate = '';
                          var endDate = '';
                          var actualDate = '';
                          var actualEnd = '';
                          var srno;

                          var allchartdata =
                              snapshot.data.docs[j]['data'] as List<dynamic>;
                          startdate = allchartdata[0]['StartDate'];
                          endDate =
                              allchartdata[allchartdata.length - 1]['EndDate'];
                          actualDate = allchartdata[0]['ActualStart'];
                          actualEnd = allchartdata[allchartdata.length - 1]
                              ['ActualEnd'];

                          srno = j;

                          startDate.add(startdate);
                          enddate.add(endDate);
                          actualstart.add(actualDate);
                          actualend.add(actualEnd);
                          srNo.add(srno);
                        }
                      }
                      for (int j = 0; j < 1; j++) {
                        // if (snapshot.data.docs[j].reference.id.toString() ==
                        //     '${widget.depoName}A$j') {

                        var startdate = '';
                        var endDate = '';
                        var actualDate = '';
                        var actualEnd = '';
                        var srno;

                        var allchartdata =
                            snapshot.data.docs[j]['data'] as List<dynamic>;
                        startdate = allchartdata[0]['StartDate'];
                        endDate =
                            allchartdata[allchartdata.length - 1]['EndDate'];
                        actualDate = allchartdata[0]['ActualStart'];
                        actualEnd =
                            allchartdata[allchartdata.length - 1]['ActualEnd'];

                        srno = j;

                        startDate.add(startdate);
                        enddate.add(endDate);
                        actualstart.add(actualDate);
                        actualend.add(actualEnd);
                        srNo.add(srno);
                      }

                      ganttdata.add(GanttAbsoluteEvent(
                        displayNameBuilder: (context) {
                          int sr = 1;
                          return sr.toString();
                        },
                        startDate: DateTime.now(),
                        endDate: DateTime.now(),
                      ));

                      ganttdata.add(GanttAbsoluteEvent(
                        displayNameBuilder: (context) {
                          return '';
                        },
                        startDate: DateTime.now(),
                        endDate: DateTime.now(),
                        //displayName: yAxis[i].toString()
                      ));

                      for (int i = 0; i < length; i++) {
                        ganttdata.add(GanttAbsoluteEvent(
                          displayNameBuilder: (context) {
                            int sr = i + 2;
                            // int ss = sr + 1;
                            return sr.toString();
                          },
                          startDate:
                              DateFormat('dd-MM-yyyy').parse(startDate[i]),
                          endDate: DateFormat('dd-MM-yyyy').parse(enddate[i]),
                        ));

                        ganttdata.add(GanttAbsoluteEvent(
                          displayNameBuilder: (context) {
                            return '';
                          },
                          startDate:
                              DateFormat('dd-MM-yyyy').parse(actualstart[i]),
                          endDate: DateFormat('dd-MM-yyyy').parse(actualend[i]),
                          //displayName: yAxis[i].toString()
                        ));
                      }
                      _employees = getEmployeeData();
                      _KeyDataSourceKeyEvents =
                          KeyDataSourceKeyEvents(_employees, context);
                      _dataGridController = DataGridController();

                      return Container(
                          height: 600,
                          child: Row(children: [
                            Expanded(
                              child: SfDataGrid(
                                source: _KeyDataSourceKeyEvents,
                                onCellTap: (DataGridCellTapDetails details) {
                                  final DataGridRow row =
                                      _KeyDataSourceKeyEvents.effectiveRows[
                                          details.rowColumnIndex.rowIndex - 1];

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) {
                                    if (row.getCells()[0].value == 'A1') {
                                      return ViewAllPdf(
                                          userId: userId,
                                          cityName: widget.cityName,
                                          depoName: widget.depoName,
                                          title: 'Key Events',
                                          docId: row.getCells()[1].value);
                                    } else {
                                      return StatutoryAprovalA2(
                                        events: row.getCells().first.value,
                                        depoName: widget.depoName,
                                      );
                                    }
                                  }
                                      // menuwidget[
                                      //     details.rowColumnIndex.rowIndex - 1]
                                      ));
                                },
                                allowEditing: true,
                                frozenColumnsCount: 2,
                                editingGestureType: EditingGestureType.tap,
                                headerGridLinesVisibility:
                                    GridLinesVisibility.both,
                                gridLinesVisibility: GridLinesVisibility.both,
                                selectionMode: SelectionMode.single,
                                navigationMode: GridNavigationMode.cell,
                                columnWidthMode: ColumnWidthMode.auto,
                                controller: _dataGridController,
                                // onQueryRowHeight: (details) {
                                //   return details.rowIndex == 0 ? 60.0 : 49.0;
                                // },
                                columns: [
                                  GridColumn(
                                    columnName: 'srNo',
                                    autoFitPadding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    allowEditing: false,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Sr No',
                                        overflow: TextOverflow.values.first,
                                        style: tableheader,

                                        //    textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'Activity',
                                    allowEditing: false,
                                    width: 100,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Activity',
                                        overflow: TextOverflow.values.first,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'OriginalDuration',
                                    allowEditing: false,
                                    width: 80,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Original Duration',
                                        overflow: TextOverflow.values.first,
                                        textAlign: TextAlign.center,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'StartDate',
                                    allowEditing: false,
                                    width: 85,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Start Date',
                                        overflow: TextOverflow.values.first,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'EndDate',
                                    allowEditing: false,
                                    width: 85,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'End Date',
                                        overflow: TextOverflow.values.first,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'ActualStart',
                                    allowEditing: false,
                                    width: 85,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Actual Start',
                                        overflow: TextOverflow.values.first,
                                        textAlign: TextAlign.center,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'ActualEnd',
                                    allowEditing: false,
                                    width: 85,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        'Actual End',
                                        overflow: TextOverflow.values.first,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'ActualDuration',
                                    allowEditing: false,
                                    width: 80,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Actual Duration',
                                        overflow: TextOverflow.values.first,
                                        textAlign: TextAlign.center,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'Delay',
                                    allowEditing: false,
                                    width: 80,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Delay',
                                        overflow: TextOverflow.values.first,
                                        textAlign: TextAlign.center,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'Progress',
                                    allowEditing: false,
                                    width: 80,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        '% of Progress',
                                        overflow: TextOverflow.values.first,
                                        textAlign: TextAlign.center,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                  GridColumn(
                                    columnName: 'Weightage',
                                    allowEditing: false,
                                    width: 80,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Weightage',
                                        overflow: TextOverflow.values.first,
                                        textAlign: TextAlign.center,
                                        style: tableheader,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                width: 300,
                                height: _employees.length * 75,
                                child: SingleChildScrollView(
                                  child: GanttChartView(
                                      scrollController: scrollController,
                                      scrollPhysics:
                                          const BouncingScrollPhysics(),
                                      maxDuration: null,
                                      // const Duration(days: 30 * 2),
                                      // optional, set to null for infinite horizontal scroll
                                      startDate:
                                          DateTime(2023, 8, 1), //required
                                      dayWidth: 40, //column width for each day
                                      dayHeaderHeight: 35,
                                      eventHeight: 25, //row height for events

                                      stickyAreaWidth: 50, //sticky area width
                                      showStickyArea:
                                          true, //show sticky area or not
                                      showDays: true, //show days or not
                                      startOfTheWeek: WeekDay
                                          .monday, //custom start of the week
                                      weekHeaderHeight: 30,
                                      weekEnds: const {
                                        // WeekDay.saturday,
                                        // WeekDay.sunday
                                      }, //custom weekends
                                      isExtraHoliday: (context, day) {
                                        //define custom holiday logic for each day
                                        return DateUtils.isSameDay(
                                            DateTime(2023, 7, 1), day);
                                      },
                                      events: ganttdata),
                                ))
                          ]));
                    }
                  }
                  _employees = getDefaultEmployeeData();
                  _KeyDataSourceKeyEvents =
                      KeyDataSourceKeyEvents(_employees, context);
                  _dataGridController = DataGridController();

                  return Container(
                      height: 580,
                      child: Row(children: [
                        Expanded(
                          child: SfDataGrid(
                            source: _KeyDataSourceKeyEvents,
                            onCellTap: (DataGridCellTapDetails details) {
                              final DataGridRow row =
                                  _KeyDataSourceKeyEvents.effectiveRows[
                                      details.rowColumnIndex.rowIndex - 1];

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                if (row.getCells()[0].value == 'A1') {
                                  return ViewAllPdf(
                                      userId: userId,
                                      cityName: widget.cityName,
                                      depoName: widget.depoName,
                                      title: 'Key Events',
                                      docId: row.getCells()[1].value);
                                } else {
                                  return StatutoryAprovalA2(
                                    events: row.getCells().first.value,
                                    depoName: widget.depoName,
                                  );
                                }
                              }
                                  // menuwidget[
                                  //     details.rowColumnIndex.rowIndex - 1]
                                  ));
                            },
                            allowEditing: true,
                            frozenColumnsCount: 2,
                            editingGestureType: EditingGestureType.tap,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            gridLinesVisibility: GridLinesVisibility.both,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.auto,
                            controller: _dataGridController,
                            // onQueryRowHeight: (details) {
                            //   return details.rowIndex == 0 ? 60.0 : 49.0;
                            // },
                            columns: [
                              GridColumn(
                                columnName: 'srNo',
                                autoFitPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                allowEditing: true,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Sr No',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.values.first,
                                    style: tableheader,
                                    //    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Activity',
                                width: 100,
                                allowEditing: true,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Activity',
                                    overflow: TextOverflow.values.first,
                                    style: tableheader,
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'OriginalDuration',
                                allowEditing: true,
                                width: 80,
                                autoFitPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Original Duration',
                                      overflow: TextOverflow.values.first,
                                      textAlign: TextAlign.center,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'StartDate',
                                allowEditing: false,
                                width: 85,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Start Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'EndDate',
                                allowEditing: false,
                                width: 85,
                                label: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text('End Date',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ActualStart',
                                allowEditing: false,
                                width: 140,
                                label: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Actual Start',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ActualEnd',
                                allowEditing: false,
                                width: 85,
                                label: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Actual End',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ActualDuration',
                                width: 80,
                                allowEditing: true,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Actual Duration',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Delay',
                                allowEditing: true,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Delay',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Unit',
                                allowEditing: true,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Unit',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'QtyScope',
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Oty as per scope',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'QtyExecuted',
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Qty executed',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'BalancedQty',
                                allowEditing: false,
                                label: Container(
                                  width: 80,
                                  alignment: Alignment.center,
                                  child: Text('Balanced Qty',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Progress',
                                allowEditing: false,
                                width: 80,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('% of Progress',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Weightage',
                                allowEditing: true,
                                label: Container(
                                  alignment: Alignment.center,
                                  child: Text('Weightage',
                                      overflow: TextOverflow.values.first,
                                      style: tableheader),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 300,
                            height: _employees.length * 75,
                            child: SingleChildScrollView(
                              child: GanttChartView(
                                  scrollController: scrollController,
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  maxDuration: null,
                                  // const Duration(days: 30 * 2),
                                  // optional, set to null for infinite horizontal scroll
                                  startDate: DateTime(2023, 8, 1), //required
                                  dayWidth: 40, //column width for each day
                                  dayHeaderHeight: 35,
                                  eventHeight: 25, //row height for events

                                  stickyAreaWidth: 50, //sticky area width
                                  showStickyArea:
                                      true, //show sticky area or not
                                  showDays: true, //show days or not
                                  startOfTheWeek:
                                      WeekDay.monday, //custom start of the week
                                  weekHeaderHeight: 30,
                                  weekEnds: const {
                                    // WeekDay.saturday,
                                    // WeekDay.sunday
                                  }, //custom weekends
                                  isExtraHoliday: (context, day) {
                                    //define custom holiday logic for each day
                                    return DateUtils.isSameDay(
                                        DateTime(2023, 7, 1), day);
                                  },
                                  events: ganttdata),
                            ))
                      ]));
                }));

    //     ? LoadingPage()
    //     :
  }

  // Future<void> getUserId() async {
  //   await AuthService().getCurrentUserId().then((value) {
  //     userId = value;
  //     setState(() {});
  //   });
  // }

  List<Employee> getDefaultEmployeeData() {
    return [
      Employee(
          srNo: 'A1',
          activity: 'Letter of Award reveived  from TML',
          originalDuration: 0,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          // reasonDelay: '',
          delay: 0,
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
          srNo: 'A2',
          activity:
              'Site Survey, Job scope finalization  and Proposed layout submission',
          originalDuration: 16,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          // reasonDelay: '',
          delay: 0,
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      // totalweightage),
      Employee(
          srNo: 'A3',
          activity:
              'Detailed Engineering for Approval of  Civil & Electrical  Layout, GA Drawing from TML',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          // reasonDelay: '',
          delay: 0,
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
          srNo: 'A4',
          activity: 'Site Mobalization activity Completed',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          delay: 0,
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
          srNo: 'A5',
          activity: 'Approval of statutory clearances of BUS Depot',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          delay: 0,
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
          srNo: 'A6',
          activity: 'Procurement of Order Finalisation Completed',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          delay: 0,
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
          srNo: 'A7',
          activity: 'Receipt of all Materials at Site',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          delay: 0,
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
          srNo: 'A8',
          activity: 'Civil Infra Development completed at Bus Depot',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          delay: 0,
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
          srNo: 'A9',
          activity: 'Electrical Infra Development completed at Bus Depot',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          delay: 0,
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 0,
          weightage: 0),
      Employee(
        srNo: 'A10',
        activity: 'Bus Depot work Completed & Handover to TML',
        originalDuration: 1,
        startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: 0,
        delay: 0,
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: 0,
        weightage: 0,
      ),
    ];
  }

  int durationParse(String fromtime, String todate) {
    DateTime startdate = DateFormat('dd-MM-yyyy').parse(fromtime);
    DateTime enddate = DateFormat('dd-MM-yyyy').parse(todate);
    return enddate.difference(startdate).inDays;
  }

  List<Employee> getEmployeeData() {
    return [
      Employee(
          srNo: 'A1',
          activity: 'Letter of Award reveived  from TML',
          originalDuration: 1,
          startDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: 0,
          delay: 0,
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: 100,
          weightage: 10),
      Employee(
          srNo: 'A2',
          activity:
              'Site Survey, Job scope finalization  and Proposed layout submission',
          originalDuration: durationParse(
              sdate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
              edate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
          startDate: sdate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
          endDate: edate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualstartDate:
              asdate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualendDate:
              aedate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
          actualDuration: durationParse(
              asdate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
              aedate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
          delay: durationParse(
              edate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
              aedate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
          // reasonDelay: '',
          unit: 0,
          scope: 0,
          qtyExecuted: 0,
          balanceQty: 0,
          percProgress: perc2!.toStringAsFixed(2),
          weightage: weight2.isNotEmpty
              ? double.parse(weight2[0].toStringAsFixed(4))
              : 0.0),
      Employee(
        srNo: 'A3',
        activity:
            'Detailed Engineering for Approval of  Civil & Electrical  Layout, GA Drawing from TML',
        originalDuration: durationParse(
            sdate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: durationParse(
            edate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate3 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc3!.toStringAsFixed(2),
        weightage: weight3.isNotEmpty
            ? double.parse(weight3[0].toStringAsFixed(4))
            : 0.0,
      ),
      Employee(
        srNo: 'A4',
        activity: 'Site Mobalization activity Completed',
        originalDuration: durationParse(
            sdate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: durationParse(
            edate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate4 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc4!.toStringAsFixed(2),
        weightage: weight4.isNotEmpty
            ? double.parse(weight4[0].toStringAsFixed(4))
            : 0.0,
      ),
      Employee(
        srNo: 'A5',
        activity: 'Approval of statutory clearances of BUS Depot',
        originalDuration: durationParse(
            sdate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: durationParse(
            edate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate5 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc5!.toStringAsFixed(2),
        weightage: weight5.isNotEmpty
            ? double.parse(weight5[0].toStringAsFixed(4))
            : 0.0,
      ),
      Employee(
        srNo: 'A6',
        activity: 'Procurement of Order Finalisation Completed',
        originalDuration: durationParse(
            sdate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: durationParse(
            edate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate6 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc6!.toStringAsFixed(2),
        weightage: weight6.isNotEmpty
            ? double.parse(weight6[0].toStringAsFixed(4))
            : 0.0,
      ),
      Employee(
        srNo: 'A7',
        activity: 'Receipt of all Materials at Site',
        originalDuration: durationParse(
            sdate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: durationParse(
            edate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate7 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc7!.toStringAsFixed(2),
        weightage: weight7.isNotEmpty
            ? double.parse(weight7[0].toStringAsFixed(4))
            : 0.0,
      ),
      Employee(
        srNo: 'A8',
        activity: 'Civil Infra Development completed at Bus Depot',
        originalDuration: durationParse(
            sdate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate8 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: 0,
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc8!.toStringAsFixed(2),
        weightage: weight8.isNotEmpty
            ? double.parse(weight8[0].toStringAsFixed(4))
            : 0.0,
      ),
      Employee(
        srNo: 'A9',
        activity: 'Electrical Infra Development completed at Bus Depot',
        originalDuration: durationParse(
            sdate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate9 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: durationParse(
            edate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate2 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc9!.toStringAsFixed(2),
        weightage: weight9.isNotEmpty
            ? double.parse(weight9[0].toStringAsFixed(4))
            : 0.0,
      ),
      Employee(
        srNo: 'A10',
        activity: 'Bus Depot work Completed & Handover to TML',
        originalDuration: durationParse(
            sdate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            edate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        startDate: sdate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        endDate: edate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualstartDate:
            asdate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualendDate:
            aedate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
        actualDuration: durationParse(
            asdate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        delay: durationParse(
            edate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now()),
            aedate10 ?? DateFormat('dd-MM-yyyy').format(DateTime.now())),
        // reasonDelay: '',
        unit: 0,
        scope: 0,
        qtyExecuted: 0,
        balanceQty: 0,
        percProgress: perc10!.toStringAsFixed(2),
        weightage: weight10.isNotEmpty
            ? double.parse(weight10[0].toStringAsFixed(4))
            : 0.0,
      ),
    ];
  }
}

class ChartData {
  ChartData(this.x, this.y, this.y1);
  final String x;
  final double y;
  final Color y1;
}
