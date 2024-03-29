import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_pmis_app/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../authentication/authservice.dart';
import '../../components/Loading_page.dart';
import '../../datasource/detailedengEV_datasource.dart';
import '../../datasource/detailedengShed_datasource.dart';
import '../../datasource/detailedeng_datasource.dart';
import '../../date_format.dart';
import '../../model/detailed_engModel.dart';
import '../../provider/cities_provider.dart';
import '../../style.dart';
import '../homepage/gallery.dart';

class DetailedEng extends StatefulWidget {
  String? depoName;
  String? role;
  DetailedEng({super.key, required this.depoName, required this.role});

  @override
  State<DetailedEng> createState() => _DetailedEngtState();
}

class _DetailedEngtState extends State<DetailedEng>
    with TickerProviderStateMixin {
  List<DetailedEngModel> DetailedProject = <DetailedEngModel>[];
  List<DetailedEngModel> DetailedProjectev = <DetailedEngModel>[];
  List<DetailedEngModel> DetailedProjectshed = <DetailedEngModel>[];
  late DetailedEngSourceShed _detailedEngSourceShed;
  late DetailedEngSource _detailedDataSource;
  late DetailedEngSourceEV _detailedEngSourceev;
  late DataGridController _dataGridController;
  List<dynamic> tabledata2 = [];
  List<dynamic> ev_tabledatalist = [];
  List<dynamic> shed_tabledatalist = [];
  TabController? _controller;
  int _selectedIndex = 0;
  Stream? _stream;
  Stream? _stream1;
  Stream? _stream2;
  var alldata;
  bool _isloading = true;
  bool checkTable = true;
  String? cityName;

  @override
  void initState() {
    cityName = Provider.of<CitiesProvider>(context, listen: false).getName;

    // getmonthlyReport();
    // getmonthlyReportEv();

    getTableDataRfc().whenComplete(() {
      // _stream = FirebaseFirestore.instance
      //     .collection('DetailEngineering')
      //     .doc('${widget.depoName}')
      //     .collection('RFC LAYOUT DRAWING')
      //     .doc(userId)
      //     .snapshots();

      _detailedDataSource = DetailedEngSource(DetailedProject, context,
          cityName!, widget.depoName!, userId, widget.role!);
      _dataGridController = DataGridController();
    });

    getTableDataEv().whenComplete(() {
      _stream1 = FirebaseFirestore.instance
          .collection('DetailEngineering')
          .doc('${widget.depoName}')
          .collection('EV LAYOUT DRAWING')
          .doc(userId)
          .snapshots();

      _detailedEngSourceev = DetailedEngSourceEV(DetailedProjectev, context,
          cityName!, widget.depoName!, userId, widget.role);
      _dataGridController = DataGridController();
    });

    getTableDataShed().whenComplete(() {
      _stream2 = FirebaseFirestore.instance
          .collection('DetailEngineering')
          .doc('${widget.depoName}')
          .collection('Shed LAYOUT DRAWING')
          .doc(userId)
          .snapshots();

      _detailedEngSourceShed = DetailedEngSourceShed(DetailedProjectshed,
          context, cityName!, widget.depoName!, userId, widget.role);
    });

    getUserId().whenComplete(() {
      // DetailedProject = getmonthlyReport();
      _detailedDataSource = DetailedEngSource(
          DetailedProject,
          context,
          cityName.toString(),
          widget.depoName.toString(),
          userId,
          widget.role!);
      _dataGridController = DataGridController();

      // DetailedProjectev = getmonthlyReportEv();
      _detailedEngSourceev = DetailedEngSourceEV(DetailedProjectev, context,
          cityName!, widget.depoName.toString(), userId, widget.role);
      _dataGridController = DataGridController();

      // DetailedProjectshed = getmonthlyReportEv();
      _detailedEngSourceShed = DetailedEngSourceShed(DetailedProjectshed,
          context, cityName!, widget.depoName.toString(), userId, widget.role);
      _dataGridController = DataGridController();
      _controller = TabController(length: 3, vsync: this);

      _stream = FirebaseFirestore.instance
          .collection('DetailEngineering')
          .doc('${widget.depoName}')
          .collection('RFC LAYOUT DRAWING')
          .doc(userId)
          .snapshots();

      _stream1 = FirebaseFirestore.instance
          .collection('DetailEngineering')
          .doc('${widget.depoName}')
          .collection('EV LAYOUT DRAWING')
          .doc(userId)
          .snapshots();

      _stream2 = FirebaseFirestore.instance
          .collection('DetailEngineering')
          .doc('${widget.depoName}')
          .collection('Shed LAYOUT DRAWING')
          .doc(userId)
          .snapshots();

      _isloading = false;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: blue,
            title: Text(
              '${widget.depoName}/Detailed Engineering',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              InkWell(
                onTap: () {
                  _showDialog(context);
                  StoreData();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/appbar/sync.jpeg',
                    height: 35,
                    width: 35,
                  ),
                ),
              ),
              // Padding(
              //     padding: const EdgeInsets.only(right: 140),
              //     child: GestureDetector(
              //         onTap: () {
              //           onWillPop(context);
              //         },
              //         child: Image.asset(
              //           'assets/logout.png',
              //           height: 20,
              //           width: 20,
              //         ))
              //     //  IconButton(
              //     //   icon: Icon(
              //     //     Icons.logout_rounded,
              //     //     size: 25,
              //     //     color: white,
              //     //   ),
              //     //   onPressed: () {
              //     //     onWillPop(context);
              //     //   },
              //     // )
              //     )
            ],
            bottom: TabBar(
              onTap: (value) {
                _selectedIndex = value;
              },
              tabs: const [
                Tab(text: "RFC Drawings of Civil Activities"),
                Tab(text: "EV Layout Drawings of Electrical Activities"),
                Tab(text: "Shed Lighting Drawings & Specification"),
              ],
            )),
        drawer: const NavbarDrawer(),

        body: TabBarView(children: [
          tabScreen(),
          tabScreen1(),
          tabScreen2(),
        ]),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (() {
            if (_selectedIndex == 0) {
              DetailedProject.add(DetailedEngModel(
                siNo: _detailedDataSource.dataGridRows.length + 1,
                title: '',
                number: 'null',
                preparationDate:
                    DateFormat('dd-MM-yyyy').format(DateTime.now()),
                submissionDate: dmy,
                approveDate: dmy,
                releaseDate: dmy,
              ));
              _detailedDataSource.buildDataGridRows();
              _detailedDataSource.updateDatagridSource();
            }
            if (_selectedIndex == 1) {
              DetailedProjectev.add(DetailedEngModel(
                siNo: _detailedEngSourceev.dataGridRows.length + 1,
                title: '',
                number: 'null',
                preparationDate: dmy,
                submissionDate: dmy,
                approveDate: dmy,
                releaseDate: dmy,
              ));
              _detailedEngSourceev.buildDataGridRowsEV();
              _detailedEngSourceev.updateDatagridSource();
            } else {
              DetailedProjectshed.add(DetailedEngModel(
                siNo: _detailedEngSourceShed.dataGridRows.length + 1,
                title: '',
                number: 'null',
                preparationDate: dmy,
                submissionDate: dmy,
                approveDate: dmy,
                releaseDate: dmy,
              ));
              _detailedEngSourceShed.buildDataGridRowsShed();
              _detailedEngSourceShed.updateDatagridSource();
            }
          }),
        ),

        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: (() {
        //     DetailedProject.add(DetailedEngModel(
        //       siNo: 1,
        //       title: '',
        //       number: 12345,
        //       preparationDate: dmy,
        //       submissionDate: dmy,
        //       approveDate: dmy,
        //       releaseDate: dmy,
        //     ));
        //     _detailedDataSource.buildDataGridRows();
        //     _detailedDataSource.updateDatagridSource();
        //   }),
        // ),
      ),
    );
  }

  Future<void> getUserId() async {
    await AuthService().getCurrentUserId().then((value) {
      userId = value;
    });
  }

  void _showDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: SizedBox(
          height: 50,
          width: 50,
          child: Center(
            child: CircularProgressIndicator(
              color: blue,
            ),
          ),
        ),
      ),
    );
  }

  void StoreData() {
    Map<String, dynamic> tableData = Map();
    Map<String, dynamic> evTableData = Map();
    Map<String, dynamic> shedTableData = Map();

    for (var i in _detailedDataSource.dataGridRows) {
      for (var data in i.getCells()) {
        if (data.columnName != 'button' ||
            data.columnName != 'ViewDrawing' ||
            data.columnName != "Delete") {
          tableData[data.columnName] = data.value;
        }
      }

      tabledata2.add(tableData);
      tableData = {};
    }

    FirebaseFirestore.instance
        .collection('DetailEngineering')
        .doc('${widget.depoName}')
        .collection('RFC LAYOUT DRAWING')
        .doc(userId)
        .set({
      'data': tabledata2,
    }).whenComplete(() {
      tabledata2.clear();

      for (var i in _detailedEngSourceev.dataGridRows) {
        for (var data in i.getCells()) {
          if (data.columnName != 'button' ||
              data.columnName != 'ViewDrawing' ||
              data.columnName != "Delete") {
            evTableData[data.columnName] = data.value;
          }
        }

        ev_tabledatalist.add(evTableData);
        evTableData = {};
      }

      FirebaseFirestore.instance
          .collection('DetailEngineering')
          .doc('${widget.depoName}')
          .collection('EV LAYOUT DRAWING')
          .doc(userId)
          .set({
        'data': ev_tabledatalist,
      }).whenComplete(() {
        ev_tabledatalist.clear();

        for (var i in _detailedEngSourceShed.dataGridRows) {
          for (var data in i.getCells()) {
            if (data.columnName != 'button' ||
                data.columnName != 'ViewDrawing' ||
                data.columnName != "Delete") {
              shedTableData[data.columnName] = data.value;
            }
          }

          shed_tabledatalist.add(shedTableData);
          shedTableData = {};
        }

        FirebaseFirestore.instance
            .collection('DetailEngineering')
            .doc('${widget.depoName}')
            .collection('Shed LAYOUT DRAWING')
            .doc(userId)
            .set({
          'data': shed_tabledatalist,
        }).whenComplete(() {
          shed_tabledatalist.clear();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Data are synced'),
            backgroundColor: blue,
          ));
        });
      });
      // tabledata2.clear();
      // Navigator.pop(context);
    });
  }

  List<DetailedEngModel> getmonthlyReportEv() {
    return [
      DetailedEngModel(
        siNo: 2,
        title: '',
        number: null,
        preparationDate: dmy,
        submissionDate: dmy,
        approveDate: dmy,
        releaseDate: dmy,
      ),
    ];
  }

  List<DetailedEngModel> getmonthlyReportShed() {
    return [
      DetailedEngModel(
        siNo: 2,
        title: '',
        number: null,
        preparationDate: dmy,
        submissionDate: dmy,
        approveDate: dmy,
        releaseDate: dmy,
      ),
    ];
  }

  List<DetailedEngModel> getmonthlyReport() {
    return [
      // DetailedEngModel(
      //   siNo: 1,
      //   title: 'RFC Drawings of Civil Activities',
      //   number: 0,
      //   preparationDate: '',
      //   submissionDate: '',
      //   approveDate: '',
      //   releaseDate: '',
      // ),
      DetailedEngModel(
        siNo: 1,
        title: '',
        number: null,
        preparationDate: dmy,
        submissionDate: dmy,
        approveDate: dmy,
        releaseDate: dmy,
      ),
      // DetailedEngModel(
      //   siNo: 3,
      //   title: 'EV Layout Drawings of Electrical Activities',
      //   number: 0,
      //   preparationDate: '',
      //   submissionDate: '',
      //   approveDate: '',
      //   releaseDate: '',
      // ),
      // DetailedEngModel(
      //   siNo: 2,
      //   title: 'Electrical Work',
      //   number: 12345,
      //   preparationDate: dmy,
      //   submissionDate: dmy,
      //   approveDate: dmy,
      //   releaseDate: dmy,
      // ),
      // DetailedEngModel(
      //   siNo: 5,
      //   title: 'Shed Lighting Drawings & Specification',
      //   number: 0,
      //   preparationDate: '',
      //   submissionDate: '',
      //   approveDate: '',
      //   releaseDate: '',
      // ),
      // DetailedEngModel(
      //   siNo: 3,
      //   title: 'Illumination Design',
      //   number: 12345,
      //   preparationDate: dmy,
      //   submissionDate: dmy,
      //   approveDate: dmy,
      //   releaseDate: dmy,
      // ),
    ];
  }

  tabScreen() {
    return Scaffold(
      body: _isloading
          ? LoadingPage()
          : Column(children: [
              SfDataGridTheme(
                data: SfDataGridThemeData(headerColor: blue),
                child: Expanded(
                  child: StreamBuilder(
                    stream: _stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.exists == false) {
                        return SfDataGrid(
                            source: _selectedIndex == 0
                                ? _detailedDataSource
                                : _detailedEngSourceev,
                            allowEditing: true,
                            frozenColumnsCount: 2,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.auto,
                            editingGestureType: EditingGestureType.tap,
                            controller: _dataGridController,
                            onQueryRowHeight: (details) {
                              return details
                                  .getIntrinsicRowHeight(details.rowIndex);
                            },
                            columns: [
                              GridColumn(
                                visible: false,
                                columnName: 'SiNo',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('SI No.',
                                      overflow: TextOverflow.values.first,
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'button',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Upload Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ViewDrawing',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('View Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Title',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 300,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Description',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Number',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 140,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Drawing Number',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'PreparationDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Preparation Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'SubmissionDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Submission Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ApproveDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Approve Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ReleaseDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Release Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Add',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Add Row',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor,

                                    //    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Delete',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Delete Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                            ]);
                      } else {
                        alldata = '';
                        alldata = snapshot.data['data'] as List<dynamic>;
                        DetailedProject.clear();
                        _detailedDataSource.buildDataGridRows();
                        _detailedDataSource.updateDatagridSource();
                        alldata.forEach((element) {
                          DetailedProject.add(
                              DetailedEngModel.fromjson(element));
                          _detailedDataSource = DetailedEngSource(
                              DetailedProject,
                              context,
                              cityName!,
                              widget.depoName.toString(),
                              userId,
                              widget.role!);
                          _dataGridController = DataGridController();
                        });

                        return SfDataGrid(
                            source: _selectedIndex == 0
                                ? _detailedDataSource
                                : _detailedEngSourceev,
                            allowEditing: true,
                            frozenColumnsCount: 2,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.auto,
                            editingGestureType: EditingGestureType.tap,
                            controller: _dataGridController,
                            onQueryRowHeight: (details) {
                              return details
                                  .getIntrinsicRowHeight(details.rowIndex);
                            },
                            columns: [
                              GridColumn(
                                visible: false,
                                columnName: 'SiNo',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('SI No.',
                                      overflow: TextOverflow.values.first,
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'button',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Upload Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ViewDrawing',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('View Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Title',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 300,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Description',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Number',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 140,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Drawing Number',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'PreparationDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Preparation Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'SubmissionDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Submission Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ApproveDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Approve Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ReleaseDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Release Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Add',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Add Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Delete',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Delete Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                            ]);
                      }
                    },
                  ),
                ),
              ),
            ]),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: (() {
      //     DetailedProject.add(DetailedEngModel(
      //       siNo: 1,
      //       title: '',
      //       number: 12345,
      //       preparationDate: dmy,
      //       submissionDate: dmy,
      //       approveDate: dmy,
      //       releaseDate: dmy,
      //     ));
      //     _detailedDataSource.buildDataGridRows();
      //     _detailedDataSource.updateDatagridSource();
      //   }),
      // )
    );
  }

  tabScreen1() {
    return Scaffold(
      body: _isloading
          ? LoadingPage()
          : Column(children: [
              SfDataGridTheme(
                data: SfDataGridThemeData(headerColor: blue),
                child: Expanded(
                  child: StreamBuilder(
                    stream: _stream1,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.exists == false) {
                        return SfDataGrid(
                            source: _selectedIndex == 0
                                ? _detailedDataSource
                                : _detailedEngSourceev,
                            allowEditing: true,
                            frozenColumnsCount: 2,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.auto,
                            editingGestureType: EditingGestureType.tap,
                            controller: _dataGridController,
                            onQueryRowHeight: (details) {
                              return details
                                  .getIntrinsicRowHeight(details.rowIndex);
                            },
                            columns: [
                              GridColumn(
                                visible: false,
                                columnName: 'SiNo',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('SI No.',
                                      overflow: TextOverflow.values.first,
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'button',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Upload Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ViewDrawing',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('View Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Title',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 300,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Description',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Number',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 140,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Drawing Number',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'PreparationDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Preparation Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'SubmissionDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Submission Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ApproveDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Approve Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ReleaseDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Release Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Add',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Add Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Delete',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Delete Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                            ]);
                      } else {
                        alldata = '';
                        alldata = snapshot.data['data'] as List<dynamic>;
                        DetailedProjectev.clear();
                        _detailedEngSourceev.buildDataGridRowsEV();
                        _detailedEngSourceev.updateDatagridSource();
                        alldata.forEach((element) {
                          DetailedProjectev.add(
                              DetailedEngModel.fromjson(element));
                          _detailedEngSourceev = DetailedEngSourceEV(
                              DetailedProjectev,
                              context,
                              cityName!,
                              widget.depoName.toString(),
                              userId,
                              widget.role);
                          _dataGridController = DataGridController();
                        });

                        return SfDataGrid(
                            source: _selectedIndex == 0
                                ? _detailedDataSource
                                : _detailedEngSourceev,
                            allowEditing: true,
                            frozenColumnsCount: 2,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.auto,
                            editingGestureType: EditingGestureType.tap,
                            controller: _dataGridController,
                            onQueryRowHeight: (details) {
                              return details
                                  .getIntrinsicRowHeight(details.rowIndex);
                            },
                            columns: [
                              GridColumn(
                                visible: false,
                                columnName: 'SiNo',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('SI No.',
                                      overflow: TextOverflow.values.first,
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'button',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Upload Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ViewDrawing',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('View Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Title',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 300,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Description',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Number',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 140,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Drawing Number',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'PreparationDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Preparation Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'SubmissionDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Submission Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ApproveDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Approve Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ReleaseDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Released Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Add',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Add Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Delete',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Delete Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                            ]);
                      }
                    },
                  ),
                ),
              ),
            ]),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: (() {
      //     if (_selectedIndex == 0) {
      //       DetailedProjectev.add(DetailedEngModel(
      //         siNo: 1,
      //         title: '',
      //         number: 123456878,
      //         preparationDate: dmy,
      //         submissionDate: dmy,
      //         approveDate: dmy,
      //         releaseDate: dmy,
      //       ));
      //       _detailedDataSource.buildDataGridRows();
      //       _detailedDataSource.updateDatagridSource();
      //     }
      //     if (_selectedIndex == 1) {
      //       DetailedProjectev.add(DetailedEngModel(
      //         siNo: 1,
      //         title: '',
      //         number: 12345,
      //         preparationDate: dmy,
      //         submissionDate: dmy,
      //         approveDate: dmy,
      //         releaseDate: dmy,
      //       ));
      //       _detailedEngSourceev.buildDataGridRowsEV();
      //       _detailedEngSourceev.updateDatagridSource();
      //     }
      //   }),
      // ),
    );
  }

  tabScreen2() {
    return Scaffold(
      body: _isloading
          ? const LoadingPage()
          : Column(children: [
              SfDataGridTheme(
                data: SfDataGridThemeData(headerColor: blue),
                child: Expanded(
                  child: StreamBuilder(
                    stream: _stream2,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data.exists == false) {
                        return SfDataGrid(
                            source: _selectedIndex == 0
                                ? _detailedDataSource
                                : _detailedEngSourceShed,
                            allowEditing: true,
                            frozenColumnsCount: 2,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.auto,
                            editingGestureType: EditingGestureType.tap,
                            controller: _dataGridController,
                            onQueryRowHeight: (details) {
                              return details
                                  .getIntrinsicRowHeight(details.rowIndex);
                            },
                            columns: [
                              GridColumn(
                                visible: false,
                                columnName: 'SiNo',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('SI No.',
                                      overflow: TextOverflow.values.first,
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'button',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Upload Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ViewDrawing',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('View Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Title',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 300,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Description',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Number',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 140,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Drawing Number',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'PreparationDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Preparation Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'SubmissionDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Submission Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ApproveDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Approve Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ReleaseDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Release Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Add',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Add Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Delete',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Add Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                            ]);
                      } else {
                        alldata = '';
                        alldata = snapshot.data['data'] as List<dynamic>;
                        DetailedProjectshed.clear();
                        _detailedEngSourceShed.buildDataGridRowsShed();
                        _detailedEngSourceShed.updateDatagridSource();
                        alldata.forEach((element) {
                          DetailedProjectshed.add(
                              DetailedEngModel.fromjson(element));
                          _detailedEngSourceShed = DetailedEngSourceShed(
                              DetailedProjectshed,
                              context,
                              cityName!,
                              widget.depoName.toString(),
                              userId,
                              widget.role);
                          _dataGridController = DataGridController();
                        });

                        return SfDataGrid(
                            source: _selectedIndex == 0
                                ? _detailedDataSource
                                : _detailedEngSourceShed,
                            allowEditing: true,
                            frozenColumnsCount: 2,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.auto,
                            editingGestureType: EditingGestureType.tap,
                            controller: _dataGridController,
                            onQueryRowHeight: (details) {
                              return details
                                  .getIntrinsicRowHeight(details.rowIndex);
                            },
                            columns: [
                              GridColumn(
                                visible: false,
                                columnName: 'SiNo',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 80,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('SI No.',
                                      overflow: TextOverflow.values.first,
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'button',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Upload Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ViewDrawing',
                                width: 140,
                                allowEditing: false,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('View Drawing ',
                                      textAlign: TextAlign.center,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Title',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 300,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Description',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Number',
                                autoFitPadding: tablepadding,
                                allowEditing: true,
                                width: 140,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Drawing Number',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'PreparationDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Preparation Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'SubmissionDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Submission Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ApproveDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 150,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Approved Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'ReleaseDate',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 160,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Released Date',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Add',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Add Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'Delete',
                                autoFitPadding: tablepadding,
                                allowEditing: false,
                                width: 120,
                                label: Container(
                                  padding: tablepadding,
                                  alignment: Alignment.center,
                                  child: Text('Delete Row',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor
                                      //    textAlign: TextAlign.center,
                                      ),
                                ),
                              ),
                            ]);
                      }
                    },
                  ),
                ),
              ),
            ]),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: (() {
      //     DetailedProjectshed.add(DetailedEngModel(
      //       siNo: 1,
      //       title: 'EV Layout',
      //       number: 12345,
      //       preparationDate: dmy,
      //       submissionDate: dmy,
      //       approveDate: dmy,
      //       releaseDate: dmy,
      //     ));
      //     _detailedEngSourceShed.buildDataGridRowsEV();
      //     _detailedEngSourceShed.updateDatagridSource();
      //   }),
      // )
    );
  }

  Future<void> getTableDataRfc() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('DetailEngineering')
        .doc('${widget.depoName}')
        .collection('RFC LAYOUT DRAWING')
        .doc(userId)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> tempData =
          documentSnapshot.data() as Map<String, dynamic>;

      List<dynamic> mapData = tempData['data'];

      DetailedProject =
          mapData.map((map) => DetailedEngModel.fromjson(map)).toList();
      checkTable = false;
    }

    _isloading = false;
    setState(() {});
  }

  Future<void> getTableDataEv() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('DetailEngineering')
        .doc('${widget.depoName}')
        .collection('EV LAYOUT DRAWING')
        .doc(userId)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> tempData =
          documentSnapshot.data() as Map<String, dynamic>;

      List<dynamic> mapData = tempData['data'];

      DetailedProjectev =
          mapData.map((map) => DetailedEngModel.fromjson(map)).toList();
      checkTable = false;
    }

    _isloading = false;
    setState(() {});
  }

  Future<void> getTableDataShed() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('DetailEngineering')
        .doc('${widget.depoName}')
        .collection('EV LAYOUT DRAWING')
        .doc(userId)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> tempData =
          documentSnapshot.data() as Map<String, dynamic>;

      List<dynamic> mapData = tempData['data'];

      DetailedProjectshed =
          mapData.map((map) => DetailedEngModel.fromjson(map)).toList();
      checkTable = false;
    }

    _isloading = false;
    setState(() {});
  }
}
