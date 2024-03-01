import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_pmis_app/components/loading_pdf.dart';
import 'package:ev_pmis_app/date_format.dart';
import 'package:ev_pmis_app/widgets/custom_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../datasource/energymanagement_datasource.dart';
import '../../viewmodels/energy_management.dart';
import '../../views/authentication/authservice.dart';
import '../../components/Loading_page.dart';
import '../../datasource/dailyproject_datasource.dart';
import '../../datasource/monthlyproject_datasource.dart';
import '../../datasource/safetychecklist_datasource.dart';
import '../../viewmodels/daily_projectModel.dart';
import '../../viewmodels/monthly_projectModel.dart';
import '../../viewmodels/safety_checklistModel.dart';
import '../../provider/summary_provider.dart';
import '../../style.dart';
import '../../widgets/nodata_available.dart';
import '../qualitychecklist/quality_checklist.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ViewSummary extends StatefulWidget {
  String? depoName;
  String? cityName;
  String? id;
  String? selectedtab;
  bool isHeader;
  String? currentDate;
  dynamic userId;
  ViewSummary(
      {super.key,
      required this.depoName,
      required this.cityName,
      required this.id,
      this.userId,
      this.selectedtab,
      this.currentDate,
      this.isHeader = false});

  @override
  State<ViewSummary> createState() => _ViewSummaryState();
}

class _ViewSummaryState extends State<ViewSummary> {
  ProgressDialog? pr;
  String pathToOpenFile = '';
  SummaryProvider? _summaryProvider;
  Future<List<DailyProjectModel>>? _dailydata;
  Future<List<EnergyManagementModel>>? _energydata;

  DateTime? startdate = DateTime.now();
  DateTime? enddate = DateTime.now();
  DateTime? rangestartDate;
  DateTime? rangeEndDate;
  Uint8List? pdfData;
  String? pdfPath;

  List<MonthlyProjectModel> monthlyProject = <MonthlyProjectModel>[];
  List<SafetyChecklistModel> safetylisttable = <SafetyChecklistModel>[];
  late MonthlyDataSource monthlyDataSource;
  late SafetyChecklistDataSource _safetyChecklistDataSource;
  late DataGridController _dataGridController;
  List<DailyProjectModel> dailyproject = <DailyProjectModel>[];
  List<EnergyManagementModel> energymanagement = <EnergyManagementModel>[];
  late EnergyManagementDatasource _energyManagementDatasource;
  late DailyDataSource _dailyDataSource;
  List<dynamic> tabledata2 = [];
  var alldata;
  dynamic userId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _summaryProvider = Provider.of<SummaryProvider>(context, listen: false);
    pr = ProgressDialog(context,
        customBody:
            Container(height: 200, width: 100, child: const LoadingPdf()));

    getUserId().then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    _summaryProvider!
        .fetchdailydata(widget.depoName!, widget.userId, startdate!, enddate!);
    _summaryProvider!.fetchEnergyData(widget.cityName!, widget.depoName!,
        widget.userId, startdate!, enddate!);

    return Scaffold(
        appBar: CustomAppBar(
          isDownload: true,
          depoName: widget.depoName,
          title: widget.id.toString(),
          height: 30,
          isSync: false,
          isCentered: false,
          downloadFun: downloadPDF,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: widget.id == 'Daily Report' ||
                      widget.id == 'Energy Management'
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                // width: 200,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: blue)),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title:
                                                      const Text('Choose Date'),
                                                  content: SizedBox(
                                                    width: 400,
                                                    height: 500,
                                                    child: SfDateRangePicker(
                                                      view: DateRangePickerView
                                                          .year,
                                                      showTodayButton: false,
                                                      showActionButtons: true,
                                                      selectionMode:
                                                          DateRangePickerSelectionMode
                                                              .range,
                                                      onSelectionChanged:
                                                          (DateRangePickerSelectionChangedArgs
                                                              args) {
                                                        if (args.value
                                                            is PickerDateRange) {
                                                          rangestartDate = args
                                                              .value.startDate;
                                                          rangeEndDate = args
                                                              .value.endDate;
                                                        }
                                                      },
                                                      onSubmit: (value) {
                                                        dailyproject.clear();
                                                        setState(() {
                                                          startdate =
                                                              DateTime.parse(
                                                                  rangestartDate
                                                                      .toString());
                                                          enddate = DateTime
                                                              .parse(rangeEndDate
                                                                  .toString());
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      onCancel: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.today)),
                                        Text(widget.id == 'Monthly Report'
                                            ? DateFormat.yMMMM()
                                                .format(startdate!)
                                            : DateFormat.yMMMMd()
                                                .format(startdate!))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                // width: 180,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: blue)),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat.yMMMMd().format(enddate!),
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 250,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: blue)),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('choose Date'),
                                        content: SizedBox(
                                          width: 400,
                                          height: 500,
                                          child: SfDateRangePicker(
                                            view: DateRangePickerView.year,
                                            showTodayButton: false,
                                            showActionButtons: true,
                                            selectionMode:
                                                DateRangePickerSelectionMode
                                                    .single,
                                            onSelectionChanged:
                                                (DateRangePickerSelectionChangedArgs
                                                    args) {
                                              if (args.value
                                                  is PickerDateRange) {
                                                rangestartDate =
                                                    args.value.startDate;
                                              }
                                            },
                                            onSubmit: (value) {
                                              setState(() {
                                                startdate = DateTime.parse(
                                                    value.toString());
                                              });
                                              Navigator.pop(context);
                                            },
                                            onCancel: () {},
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.today)),
                              Text(widget.id == 'Monthly Report'
                                  ? DateFormat.yMMMM().format(startdate!)
                                  : DateFormat.yMMMMd().format(startdate!))
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            widget.id == 'Monthly Report'
                ? Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('MonthlyProjectReport2')
                            .doc('${widget.depoName}')
                            // .collection('AllMonthData')
                            .collection('userId')
                            .doc(widget.userId)
                            .collection('Monthly Data')
                            // .collection('MonthData')
                            .doc(DateFormat.yMMM().format(startdate!))
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingPage();
                          } else if (!snapshot.hasData ||
                              snapshot.data!.exists == false) {
                            return const NodataAvailable();
                          } else {
                            alldata = snapshot.data!['data'] as List<dynamic>;
                            monthlyProject.clear();
                            alldata.forEach((element) {
                              monthlyProject
                                  .add(MonthlyProjectModel.fromjson(element));
                              monthlyDataSource =
                                  MonthlyDataSource(monthlyProject, context);
                              _dataGridController = DataGridController();
                            });
                            return Column(
                              children: [
                                Expanded(
                                    child: SfDataGridTheme(
                                  data: SfDataGridThemeData(
                                      headerColor: white, gridLineColor: blue),
                                  child: SfDataGrid(
                                      source: monthlyDataSource,
                                      allowEditing: true,
                                      frozenColumnsCount: 1,
                                      gridLinesVisibility:
                                          GridLinesVisibility.both,
                                      headerGridLinesVisibility:
                                          GridLinesVisibility.both,
                                      selectionMode: SelectionMode.single,
                                      navigationMode: GridNavigationMode.cell,
                                      columnWidthMode: ColumnWidthMode.auto,
                                      editingGestureType:
                                          EditingGestureType.tap,
                                      controller: _dataGridController,
                                      onQueryRowHeight: (details) {
                                        return details.getIntrinsicRowHeight(
                                            details.rowIndex);
                                      },
                                      columns: [
                                        GridColumn(
                                          columnName: 'ActivityNo',
                                          autoFitPadding: tablepadding,
                                          allowEditing: true,
                                          width: 160,
                                          label: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Activities SI. No as per Gant Chart',
                                              overflow:
                                                  TextOverflow.values.first,
                                              textAlign: TextAlign.center,
                                              style: tableheaderwhitecolor,
                                            ),
                                          ),
                                        ),
                                        GridColumn(
                                          columnName: 'ActivityDetails',
                                          autoFitPadding: tablepadding,
                                          allowEditing: true,
                                          width: 240,
                                          label: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            alignment: Alignment.center,
                                            child: Text('Activities Details',
                                                textAlign: TextAlign.center,
                                                overflow:
                                                    TextOverflow.values.first,
                                                style: tableheaderwhitecolor),
                                          ),
                                        ),
                                        GridColumn(
                                          columnName: 'Progress',
                                          autoFitPadding: tablepadding,
                                          allowEditing: true,
                                          width: 250,
                                          label: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            alignment: Alignment.center,
                                            child: Text('Progress',
                                                overflow:
                                                    TextOverflow.values.first,
                                                style: tableheaderwhitecolor
                                                //    textAlign: TextAlign.center,
                                                ),
                                          ),
                                        ),
                                        GridColumn(
                                          columnName: 'Status',
                                          autoFitPadding: tablepadding,
                                          allowEditing: true,
                                          width: 250,
                                          label: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            alignment: Alignment.center,
                                            child: Text('Remark/Status',
                                                overflow:
                                                    TextOverflow.values.first,
                                                style: tableheaderwhitecolor
                                                //    textAlign: TextAlign.center,
                                                ),
                                          ),
                                        ),
                                        GridColumn(
                                          columnName: 'Action',
                                          autoFitPadding: tablepadding,
                                          allowEditing: true,
                                          width: 250,
                                          label: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            alignment: Alignment.center,
                                            child: Text(
                                                'Next Month Action Plan',
                                                overflow:
                                                    TextOverflow.values.first,
                                                style: tableheaderwhitecolor
                                                //    textAlign: TextAlign.center,
                                                ),
                                          ),
                                        ),
                                      ]),
                                )),
                              ],
                            );
                          }
                        }),
                  )
                : widget.id == 'Daily Report'
                    ? Expanded(
                        child: Consumer<SummaryProvider>(
                          builder: (context, value, child) {
                            return FutureBuilder(
                                future: _dailydata,
                                builder: (context, snapshot) {
                                  if (value.dailydata.length != 0) {
                                    dailyproject = value.dailydata;
                                    _dailyDataSource = DailyDataSource(
                                      dailyproject,
                                      context,
                                      widget.cityName!,
                                      widget.depoName!,
                                      widget.userId,
                                      selecteddate.toString(),
                                    );

                                    _dataGridController = DataGridController();

                                    return SfDataGridTheme(
                                      data: SfDataGridThemeData(
                                          headerColor: white,
                                          gridLineColor: blue),
                                      child: SfDataGrid(
                                          source: _dailyDataSource,
                                          allowEditing: true,
                                          frozenColumnsCount: 2,
                                          gridLinesVisibility:
                                              GridLinesVisibility.both,
                                          headerGridLinesVisibility:
                                              GridLinesVisibility.both,
                                          selectionMode: SelectionMode.single,
                                          navigationMode:
                                              GridNavigationMode.cell,
                                          columnWidthMode: ColumnWidthMode.auto,
                                          editingGestureType:
                                              EditingGestureType.tap,
                                          controller: _dataGridController,
                                          onQueryRowHeight: (details) {
                                            return details
                                                .getIntrinsicRowHeight(
                                                    details.rowIndex);
                                          },
                                          columns: [
                                            GridColumn(
                                              columnName: 'Date',
                                              visible: true,
                                              autoFitPadding: tablepadding,
                                              allowEditing: true,
                                              width: 150,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Date',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    textAlign: TextAlign.center,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              visible: false,
                                              columnName: 'SiNo',
                                              autoFitPadding: tablepadding,
                                              allowEditing: true,
                                              width: 70,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('SI No.',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    textAlign: TextAlign.center,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'TypeOfActivity',
                                              autoFitPadding: tablepadding,
                                              allowEditing: true,
                                              width: 200,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Type of Activity',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'ActivityDetails',
                                              autoFitPadding: tablepadding,
                                              allowEditing: true,
                                              width: 220,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Activity Details',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'Progress',
                                              autoFitPadding: tablepadding,
                                              allowEditing: true,
                                              width: 320,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Progress',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'Status',
                                              allowEditing: true,
                                              width: 320,
                                              label: Container(
                                                alignment: Alignment.center,
                                                child: Text('Remark / Status',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              visible: false,
                                              columnName: 'upload',
                                              autoFitPadding: tablepadding,
                                              allowEditing: false,
                                              width: 150,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Upload Image',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'view',
                                              autoFitPadding: tablepadding,
                                              allowEditing: false,
                                              width: 120,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('View Image',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              visible: false,
                                              columnName: 'Add',
                                              autoFitPadding: tablepadding,
                                              allowEditing: false,
                                              width: 120,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Add Row',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'Delete',
                                              autoFitPadding: tablepadding,
                                              allowEditing: true,
                                              visible: false,
                                              width: 120,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Delete Row',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style: tableheaderwhitecolor
                                                    //    textAlign: TextAlign.center,
                                                    ),
                                              ),
                                            ),
                                          ]),
                                    );
                                  } else {
                                    return const Center(
                                      child: Text(
                                          'No Data Available For Selected Date'),
                                    );
                                  }
                                }

                                //1              },
                                );
                          },
                        ),
                      )
                    : widget.id == 'Quality Checklist'
                        ? Expanded(
                            child: QualityChecklist(
                                currentDate:
                                    DateFormat.yMMMMd().format(startdate!),
                                isHeader: widget.isHeader,
                                cityName: widget.cityName,
                                depoName: widget.depoName),
                          )
                        : widget.id == 'Energy Management'
                            ? Expanded(
                                child: Consumer<SummaryProvider>(
                                  builder: (context, value, child) {
                                    return FutureBuilder(
                                      future: _energydata,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data == null ||
                                              snapshot.data!.length == 0) {
                                            return const Center(
                                              child: Text(
                                                "No Data Found!!",
                                                style:
                                                    TextStyle(fontSize: 25.0),
                                              ),
                                            );
                                          } else {
                                            return const LoadingPage();
                                          }
                                        } else {
                                          energymanagement = value.energyData;

                                          _energyManagementDatasource =
                                              EnergyManagementDatasource(
                                                  energymanagement,
                                                  context,
                                                  widget.userId,
                                                  widget.cityName,
                                                  widget.depoName);

                                          _dataGridController =
                                              DataGridController();

                                          return Column(
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(5.0),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.48,
                                                child: SfDataGridTheme(
                                                    data: SfDataGridThemeData(
                                                        gridLineColor: blue,
                                                        gridLineStrokeWidth: 2,
                                                        frozenPaneLineColor:
                                                            blue,
                                                        frozenPaneLineWidth: 3),
                                                    child: SfDataGrid(
                                                      source:
                                                          _energyManagementDatasource,
                                                      allowEditing: false,
                                                      frozenColumnsCount: 1,
                                                      gridLinesVisibility:
                                                          GridLinesVisibility
                                                              .both,
                                                      headerGridLinesVisibility:
                                                          GridLinesVisibility
                                                              .both,
                                                      headerRowHeight: 40,

                                                      selectionMode:
                                                          SelectionMode.single,
                                                      navigationMode:
                                                          GridNavigationMode
                                                              .cell,
                                                      columnWidthMode:
                                                          ColumnWidthMode.auto,
                                                      editingGestureType:
                                                          EditingGestureType
                                                              .tap,
                                                      controller:
                                                          _dataGridController,
                                                      // onQueryRowHeight:
                                                      //     (details) {
                                                      //   return details
                                                      //       .getIntrinsicRowHeight(
                                                      //           details
                                                      //               .rowIndex);
                                                      // },
                                                      columns: [
                                                        GridColumn(
                                                          visible: true,
                                                          columnName: 'srNo',
                                                          allowEditing: false,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text('Sr No',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor
                                                                //    textAlign: TextAlign.center,
                                                                ),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'DepotName',
                                                          width: 180,
                                                          allowEditing: false,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Depot Name',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'VehicleNo',
                                                          width: 180,
                                                          allowEditing: true,
                                                          label: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Veghicle No',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName: 'pssNo',
                                                          width: 80,
                                                          allowEditing: true,
                                                          label: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'PSS No',
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'chargerId',
                                                          width: 80,
                                                          allowEditing: true,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Charger ID',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'startSoc',
                                                          allowEditing: true,
                                                          width: 80,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Start SOC',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName: 'endSoc',
                                                          allowEditing: true,
                                                          columnWidthMode:
                                                              ColumnWidthMode
                                                                  .fitByCellValue,
                                                          width: 80,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'End SOC',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'startDate',
                                                          allowEditing: false,
                                                          width: 230,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Start Date & Time',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName: 'endDate',
                                                          allowEditing: false,
                                                          width: 230,
                                                          label: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                  'End Date & Time',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .values
                                                                          .first,
                                                                  style:
                                                                      tableheaderwhitecolor),
                                                            ),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'totalTime',
                                                          allowEditing: false,
                                                          width: 180,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Total time of Charging',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'energyConsumed',
                                                          allowEditing: true,
                                                          width: 160,
                                                          label: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Engery Consumed (inkW)',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName:
                                                              'timeInterval',
                                                          allowEditing: false,
                                                          width: 150,
                                                          label: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Interval',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName: 'Add',
                                                          visible: false,
                                                          autoFitPadding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          allowEditing: false,
                                                          width: 120,
                                                          label: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Add Row',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor
                                                                //    textAlign: TextAlign.center,
                                                                ),
                                                          ),
                                                        ),
                                                        GridColumn(
                                                          columnName: 'Delete',
                                                          visible: false,
                                                          autoFitPadding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          allowEditing: false,
                                                          width: 120,
                                                          label: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'Delete Row',
                                                                overflow:
                                                                    TextOverflow
                                                                        .values
                                                                        .first,
                                                                style:
                                                                    tableheaderwhitecolor),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                              Consumer<SummaryProvider>(builder:
                                                  (context, value, child) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 5.0),
                                                  height: 300,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Scrollbar(
                                                    thickness: 3,
                                                    radius:
                                                        const Radius.circular(
                                                      1,
                                                    ),
                                                    thumbVisibility: true,
                                                    trackVisibility: true,
                                                    interactive: true,
                                                    scrollbarOrientation:
                                                        ScrollbarOrientation
                                                            .bottom,
                                                    controller:
                                                        _scrollController,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        controller:
                                                            _scrollController,
                                                        itemCount: 1,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            height: 250,
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10.0),
                                                            width: _energyManagementDatasource
                                                                    .dataGridRows
                                                                    .length *
                                                                110,
                                                            child: BarChart(
                                                              swapAnimationCurve:
                                                                  Curves.linear,
                                                              swapAnimationDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              BarChartData(
                                                                backgroundColor:
                                                                    white,
                                                                barTouchData:
                                                                    BarTouchData(
                                                                  enabled: true,
                                                                  allowTouchBarBackDraw:
                                                                      true,
                                                                  touchTooltipData:
                                                                      BarTouchTooltipData(
                                                                    tooltipRoundedRadius:
                                                                        5,
                                                                    tooltipBgColor:
                                                                        Colors
                                                                            .transparent,
                                                                    tooltipMargin:
                                                                        5,
                                                                  ),
                                                                ),
                                                                minY: 0,
                                                                titlesData:
                                                                    FlTitlesData(
                                                                  bottomTitles:
                                                                      AxisTitles(
                                                                    sideTitles:
                                                                        SideTitles(
                                                                      showTitles:
                                                                          true,
                                                                      getTitlesWidget:
                                                                          (data1,
                                                                              meta) {
                                                                        return Text(
                                                                          value.intervalData[
                                                                              data1.toInt()],
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 12),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  rightTitles:
                                                                      AxisTitles(
                                                                    sideTitles: SideTitles(
                                                                        showTitles:
                                                                            false),
                                                                  ),
                                                                  topTitles:
                                                                      AxisTitles(
                                                                    sideTitles:
                                                                        SideTitles(
                                                                      showTitles:
                                                                          false,
                                                                      getTitlesWidget:
                                                                          (data2,
                                                                              meta) {
                                                                        return Text(
                                                                          value.energyConsumedData[
                                                                              data2.toInt()],
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                gridData:
                                                                    FlGridData(
                                                                  drawHorizontalLine:
                                                                      false,
                                                                  drawVerticalLine:
                                                                      false,
                                                                ),
                                                                borderData:
                                                                    FlBorderData(
                                                                  border:
                                                                      const Border(
                                                                    left:
                                                                        BorderSide(),
                                                                    bottom:
                                                                        BorderSide(),
                                                                  ),
                                                                ),
                                                                maxY: (value.intervalData
                                                                            .isEmpty &&
                                                                        value
                                                                            .energyConsumedData
                                                                            .isEmpty)
                                                                    ? 50000.0
                                                                    : value.energyConsumedData.reduce((max,
                                                                            current) =>
                                                                        max > current
                                                                            ? max
                                                                            : current +
                                                                                5000.0),
                                                                barGroups:
                                                                    barChartGroupData(
                                                                        value
                                                                            .energyConsumedData),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                );
                                              })
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('SafetyChecklistTable2')
                                      .doc(widget.depoName!)
                                      .collection('userId')
                                      .doc(userId)
                                      .collection('date')
                                      .doc(DateFormat.yMMMMd()
                                          .format(startdate!))
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LoadingPage();
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.exists == false) {
                                      return const NodataAvailable();
                                    } else {
                                      alldata = '';
                                      alldata = snapshot.data!['data']
                                          as List<dynamic>;
                                      safetylisttable.clear();
                                      alldata.forEach((element) {
                                        safetylisttable.add(
                                            SafetyChecklistModel.fromJson(
                                                element));
                                        _safetyChecklistDataSource =
                                            SafetyChecklistDataSource(
                                                safetylisttable,
                                                widget.cityName!,
                                                widget.depoName!,
                                                userId,
                                                selecteddate.toString());
                                        _dataGridController =
                                            DataGridController();
                                      });
                                      return SfDataGridTheme(
                                        data: SfDataGridThemeData(
                                            gridLineColor: blue,
                                            gridLineStrokeWidth: 2,
                                            frozenPaneLineColor: blue,
                                            frozenPaneLineWidth: 3),
                                        child: SfDataGrid(
                                          source: _safetyChecklistDataSource,
                                          //key: key,

                                          allowEditing: true,
                                          frozenColumnsCount: 2,
                                          gridLinesVisibility:
                                              GridLinesVisibility.both,
                                          headerGridLinesVisibility:
                                              GridLinesVisibility.both,
                                          selectionMode: SelectionMode.single,
                                          navigationMode:
                                              GridNavigationMode.cell,
                                          columnWidthMode: ColumnWidthMode.auto,
                                          editingGestureType:
                                              EditingGestureType.tap,
                                          controller: _dataGridController,
                                          onQueryRowHeight: (details) {
                                            return details
                                                .getIntrinsicRowHeight(
                                                    details.rowIndex);
                                          },
                                          columns: [
                                            GridColumn(
                                              columnName: 'srNo',
                                              autoFitPadding: tablepadding,
                                              allowEditing: true,
                                              width: 80,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Sr No',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style:
                                                        tableheaderwhitecolor),
                                              ),
                                            ),
                                            GridColumn(
                                              width: 550,
                                              columnName: 'Details',
                                              allowEditing: true,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    'Details of Enclosure ',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style:
                                                        tableheaderwhitecolor),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'Status',
                                              allowEditing: true,
                                              width: 230,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    'Status of Submission of information/ documents ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: white,
                                                    )),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'Remark',
                                              allowEditing: true,
                                              width: 230,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Remarks',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style:
                                                        tableheaderwhitecolor),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'Photo',
                                              allowEditing: false,
                                              visible: false,
                                              width: 160,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('Upload Photo',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style:
                                                        tableheaderwhitecolor),
                                              ),
                                            ),
                                            GridColumn(
                                              columnName: 'ViewPhoto',
                                              allowEditing: false,
                                              width: 180,
                                              label: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                alignment: Alignment.center,
                                                child: Text('View Photo',
                                                    overflow: TextOverflow
                                                        .values.first,
                                                    style:
                                                        tableheaderwhitecolor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
          ],
        ));
  }

  Future<Uint8List> _generateEnergyPDF() async {
    final headerStyle =
        pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold);

    final fontData1 =
        await rootBundle.load('assets/fonts/Montserrat-Medium.ttf');
    final fontData2 = await rootBundle.load('assets/fonts/Montserrat-Bold.ttf');

    const cellStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: 14,
    );

    final profileImage = pw.MemoryImage(
      (await rootBundle.load('assets/Tata-Power.jpeg')).buffer.asUint8List(),
    );

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text('Depot Name',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.only(
                  top: 4, bottom: 4, left: 2, right: 2),
              child: pw.Center(
                  child: pw.Text('Vehicle No',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text('PSS No.',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text('Charger Id',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'Start SOC',
              ))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'End SOC',
              ))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'Start Date & Time',
              ))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'End Date & Time',
              ))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'Total time of charging',
              ))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'Energy Consumed',
              ))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'Interval',
              ))),
        ],
      ),
    );

    if (energymanagement.isNotEmpty) {
      for (EnergyManagementModel mapData in energymanagement) {
        //Text Rows of PDF Table
        rows.add(pw.TableRow(children: [
          pw.Container(
              padding: const pw.EdgeInsets.all(3.0),
              child: pw.Center(
                  child: pw.Text(mapData.depotName.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(5.0),
              child: pw.Center(
                  child: pw.Text(mapData.vehicleNo,
                      style: const pw.TextStyle(
                        fontSize: 13,
                      )))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.pssNo.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.chargerId.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.startSoc.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.endSoc.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.startDate.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.endDate.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.totalTime.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.energyConsumed.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.timeInterval.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
        ]));
      }
    }

    final pdf = pw.Document(
      pageMode: PdfPageMode.outlines,
    );

    //First Half Page

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(fontData1), bold: pw.Font.ttf(fontData2)),
        pageFormat: const PdfPageFormat(1300, 900,
            marginLeft: 70, marginRight: 70, marginBottom: 80, marginTop: 40),
        orientation: pw.PageOrientation.natural,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(width: 0.5, color: PdfColors.grey))),
              child: pw.Column(children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Demand Energy Report',
                          textScaleFactor: 2,
                          style: const pw.TextStyle(color: PdfColors.blue700)),
                      pw.Container(
                        width: 120,
                        height: 120,
                        child: pw.Image(profileImage),
                      ),
                    ]),
              ]));
        },
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: pw.Text('User ID - $userId',
                  // 'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.black)));
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Column(children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    const pw.TextSpan(
                        text: 'Place : ',
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 17)),
                    pw.TextSpan(
                        text: '${widget.cityName} / ${widget.depoName}',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15))
                  ])),
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    const pw.TextSpan(
                        text: 'Date : ',
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 17)),
                    pw.TextSpan(
                        text:
                            '${startdate!.day}-${startdate!.month}-${startdate!.year} to ${enddate!.day}-${enddate!.month}-${enddate!.year}',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15))
                  ])),
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'UserID : $userId',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15)),
                  ])),
                ]),
            pw.SizedBox(height: 20)
          ]),
          pw.SizedBox(height: 10),
          pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(100),
                1: const pw.FixedColumnWidth(50),
                2: const pw.FixedColumnWidth(50),
                3: const pw.FixedColumnWidth(50),
                4: const pw.FixedColumnWidth(70),
                5: const pw.FixedColumnWidth(70),
                6: const pw.FixedColumnWidth(70),
                7: const pw.FixedColumnWidth(70),
                8: const pw.FixedColumnWidth(70),
                9: const pw.FixedColumnWidth(70),
                10: const pw.FixedColumnWidth(70),
              },
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              tableWidth: pw.TableWidth.max,
              border: pw.TableBorder.all(),
              children: rows)
        ],
      ),
    );

    pdfData = await pdf.save();
    pdfPath = 'DemandEnergyReport.pdf';

    return pdfData!;
  }

  Future<Uint8List> _generateDailyPDF() async {
    print('generating daily pdf');
    pr!.style(
      progressWidgetAlignment: Alignment.center,
      // message: 'Loading Data....',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: const LoadingPdf(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      maxProgress: 100.0,
      progressTextStyle: const TextStyle(
          color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
      messageTextStyle: const TextStyle(
          color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600),
    );

    final summaryProvider =
        Provider.of<SummaryProvider>(context, listen: false);
    dailyproject = summaryProvider.dailydata;

    final headerStyle =
        pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold);

    final fontData1 =
        await rootBundle.load('assets/fonts/Montserrat-Medium.ttf');
    final fontData2 = await rootBundle.load('assets/fonts/Montserrat-Bold.ttf');

    final profileImage = pw.MemoryImage(
      (await rootBundle.load('assets/Tata-Power.jpeg')).buffer.asUint8List(),
    );

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
              child: pw.Text('Sr No',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      pw.Container(
          padding:
              const pw.EdgeInsets.only(top: 4, bottom: 4, left: 2, right: 2),
          child: pw.Center(
              child: pw.Text('Date',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      pw.Container(
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
              child: pw.Text('Type of Activity',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      pw.Container(
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
              child: pw.Text('Activity Details',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      pw.Container(
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
              child: pw.Text('Progress',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      pw.Container(
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
              child: pw.Text('Remark / Status',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      pw.Container(
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
              child: pw.Text('Image1',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      pw.Container(
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
              child: pw.Text('Image2',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
    ]));

    List<pw.Widget> imageUrls = [];

    for (int i = 0; i < dailyproject.length; i++) {
      String imagesPath =
          '/Daily Report/${widget.cityName}/${widget.depoName}/${widget.userId}/${dailyproject[i].date}/${globalRowIndex[i]}';
      print(imagesPath);

      ListResult result =
          await FirebaseStorage.instance.ref().child(imagesPath).listAll();

      if (result.items.isNotEmpty) {
        for (var image in result.items) {
          String downloadUrl = await image.getDownloadURL();
          if (image.name.endsWith('.pdf')) {
            imageUrls.add(
              pw.Container(
                  width: 60,
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: pw.UrlLink(
                      child: pw.Text(image.name,
                          style: const pw.TextStyle(color: PdfColors.blue)),
                      destination: downloadUrl)),
            );
          } else {
            final myImage = await networkImage(downloadUrl);
            imageUrls.add(
              pw.Container(
                  padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                  width: 60,
                  height: 80,
                  child: pw.Center(
                    child: pw.Image(myImage),
                  )),
            );
          }
        }

        if (imageUrls.length < 2) {
          int imageLoop = 2 - imageUrls.length;
          for (int i = 0; i < imageLoop; i++) {
            imageUrls.add(
              pw.Container(
                  padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                  width: 60,
                  height: 80,
                  child: pw.Text('')),
            );
          }
        } else if (imageUrls.length > 2) {
          int imageLoop = 10 - imageUrls.length;
          for (int i = 0; i < imageLoop; i++) {
            imageUrls.add(
              pw.Container(
                  padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                  width: 80,
                  height: 100,
                  child: pw.Text('')),
            );
          }
        }
      } else {
        for (int i = 0; i < 2; i++) {
          imageUrls.add(
            pw.Container(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                width: 60,
                height: 80,
                child: pw.Text('')),
          );
        }
      }
      result.items.clear();

      //Text Rows of PDF Table
      rows.add(pw.TableRow(children: [
        pw.Container(
            padding: const pw.EdgeInsets.all(3.0),
            child: pw.Center(
                child: pw.Text((i + 1).toString(),
                    style: const pw.TextStyle(fontSize: 14)))),
        pw.Container(
            padding: const pw.EdgeInsets.all(2.0),
            child: pw.Center(
                child: pw.Text(dailyproject[i].date.toString(),
                    style: const pw.TextStyle(fontSize: 14)))),
        pw.Container(
            padding: const pw.EdgeInsets.all(2.0),
            child: pw.Center(
                child: pw.Text(dailyproject[i].typeOfActivity.toString(),
                    style: const pw.TextStyle(fontSize: 14)))),
        pw.Container(
            padding: const pw.EdgeInsets.all(2.0),
            child: pw.Center(
                child: pw.Text(dailyproject[i].activityDetails.toString(),
                    style: const pw.TextStyle(fontSize: 14)))),
        pw.Container(
            padding: const pw.EdgeInsets.all(2.0),
            child: pw.Center(
                child: pw.Text(dailyproject[i].progress.toString(),
                    style: const pw.TextStyle(fontSize: 14)))),
        pw.Container(
            padding: const pw.EdgeInsets.all(2.0),
            child: pw.Center(
                child: pw.Text(dailyproject[i].status.toString(),
                    style: const pw.TextStyle(fontSize: 14)))),
        imageUrls[0],
        imageUrls[1]
      ]));

      if (imageUrls.length - 2 > 0) {
        //Image Rows of PDF Table
        rows.add(pw.TableRow(children: [
          pw.Container(
              padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: pw.Text('')),
          pw.Container(
              padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
              width: 60,
              height: 100,
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    imageUrls[2],
                    imageUrls[3],
                  ])),
          imageUrls[4],
          imageUrls[5],
          imageUrls[6],
          imageUrls[7],
          imageUrls[8],
          imageUrls[9]
        ]));
      }
      imageUrls.clear();
    }

    final pdf = pw.Document(
      pageMode: PdfPageMode.outlines,
    );

    //First Half Page

    pdf.addPage(
      pw.MultiPage(
        maxPages: 100,
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(fontData1), bold: pw.Font.ttf(fontData2)),
        pageFormat: const PdfPageFormat(1300, 900,
            marginLeft: 70, marginRight: 70, marginBottom: 80, marginTop: 40),
        orientation: pw.PageOrientation.natural,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(width: 0.5, color: PdfColors.grey))),
              child: pw.Column(children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Daily Report Table',
                          textScaleFactor: 2,
                          style: const pw.TextStyle(color: PdfColors.blue700)),
                      pw.Container(
                        width: 120,
                        height: 120,
                        child: pw.Image(profileImage),
                      ),
                    ]),
              ]));
        },
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: pw.Text('User ID - $userId',
                  // 'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.black)));
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Column(children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    const pw.TextSpan(
                        text: 'Place : ',
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 17)),
                    pw.TextSpan(
                        text: '${widget.cityName} / ${widget.depoName}',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15))
                  ])),
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    const pw.TextSpan(
                        text: 'Date : ',
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 17)),
                    pw.TextSpan(
                        text:
                            '${startdate!.day}-${startdate!.month}-${startdate!.year} to ${enddate!.day}-${enddate!.month}-${enddate!.year}',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15))
                  ])),
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'UserID : $userId',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15)),
                  ])),
                ]),
            pw.SizedBox(height: 20)
          ]),
          pw.SizedBox(height: 10),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FixedColumnWidth(160),
              2: const pw.FixedColumnWidth(70),
              3: const pw.FixedColumnWidth(70),
              4: const pw.FixedColumnWidth(70),
              5: const pw.FixedColumnWidth(70),
              6: const pw.FixedColumnWidth(70),
              7: const pw.FixedColumnWidth(70),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            tableWidth: pw.TableWidth.max,
            border: pw.TableBorder.all(),
            children: rows,
          )
        ],
      ),
    );

    pdfData = await pdf.save();
    pdfPath = 'Daily Report.pdf';

    return pdfData!;
  }

  Future<Uint8List> _generateMonthlyPdf() async {
    final headerStyle =
        pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold);

    final fontData1 =
        await rootBundle.load('assets/fonts/Montserrat-Medium.ttf');
    final fontData2 = await rootBundle.load('assets/fonts/Montserrat-Bold.ttf');

    const cellStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: 14,
    );

    final profileImage = pw.MemoryImage(
      (await rootBundle.load('assets/Tata-Power.jpeg')).buffer.asUint8List(),
    );

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text('Sr No',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.only(
                  top: 4, bottom: 4, left: 2, right: 2),
              child: pw.Center(
                  child: pw.Text('Activity Details',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text('Progress',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text('Remark/Status',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(
                'Next Month Action Plan',
              ))),
        ],
      ),
    );

    if (monthlyProject.isNotEmpty) {
      for (MonthlyProjectModel mapData in monthlyProject) {
        // String selectedDate = DateFormat.yMMMMd().format(startdate!);

        //Text Rows of PDF Table

        rows.add(pw.TableRow(children: [
          pw.Container(
              padding: const pw.EdgeInsets.all(3.0),
              child: pw.Center(
                  child: pw.Text(mapData.activityNo.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(5.0),
              child: pw.Center(
                  child: pw.Text(mapData.activityDetails.toString(),
                      style: const pw.TextStyle(
                        fontSize: 13,
                      )))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.progress.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.status.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
          pw.Container(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                  child: pw.Text(mapData.action.toString(),
                      style: const pw.TextStyle(fontSize: 13)))),
        ]));
      }
    }

    final pdf = pw.Document(
      pageMode: PdfPageMode.outlines,
    );

    //First Half Page

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(fontData1), bold: pw.Font.ttf(fontData2)),
        pageFormat: const PdfPageFormat(1300, 900,
            marginLeft: 70, marginRight: 70, marginBottom: 80, marginTop: 40),
        orientation: pw.PageOrientation.natural,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(width: 0.5, color: PdfColors.grey))),
              child: pw.Column(children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Monthly Report',
                          textScaleFactor: 2,
                          style: const pw.TextStyle(color: PdfColors.blue700)),
                      pw.Container(
                        width: 120,
                        height: 120,
                        child: pw.Image(profileImage),
                      ),
                    ]),
              ]));
        },
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: pw.Text('User ID - $userId',
                  // 'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.black)));
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Column(children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    const pw.TextSpan(
                        text: 'Place : ',
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 17)),
                    pw.TextSpan(
                        text: '${widget.cityName} / ${widget.depoName}',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15))
                  ])),
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    const pw.TextSpan(
                        text: 'Date : ',
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 17)),
                    pw.TextSpan(
                        text:
                            '${startdate!.day}-${startdate!.month}-${startdate!.year} to ${enddate!.day}-${enddate!.month}-${enddate!.year}',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15))
                  ])),
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'UserID : $userId',
                        style: const pw.TextStyle(
                            color: PdfColors.blue700, fontSize: 15)),
                  ])),
                ]),
            pw.SizedBox(height: 20)
          ]),
          pw.SizedBox(height: 10),
          pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(160),
                2: const pw.FixedColumnWidth(70),
                3: const pw.FixedColumnWidth(70),
                4: const pw.FixedColumnWidth(70),
                5: const pw.FixedColumnWidth(70),
                6: const pw.FixedColumnWidth(70),
                7: const pw.FixedColumnWidth(70),
              },
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              tableWidth: pw.TableWidth.max,
              border: pw.TableBorder.all(),
              children: rows)
        ],
      ),
    );

    pdfData = await pdf.save();
    pdfPath = 'MonthlyReport.pdf';

    // Save the PDF file to device storage
    if (kIsWeb) {
    } else {
      const Text('Sorry it is not ready for mobile platform');
    }

    return pdfData!;
  }

  Future<void> downloadPDF() async {
    if (await Permission.storage.request().isGranted) {
      final pr = ProgressDialog(context);
      pr.style(
        progressWidgetAlignment: Alignment.center,
        message: 'Downloading file...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const LoadingPdf(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600),
      );

      await pr.show();

      final pdfData = widget.id == 'Daily Report'
          ? await _generateDailyPDF()
          : widget.id == 'Monthly Report'
              ? await _generateMonthlyPdf()
              : await _generateEnergyPDF();

      String fileName = widget.id == 'Daily Report'
          ? 'DailyReport.pdf'
          : widget.id == 'Monthly Report'
              ? 'MonthlyReport.pdf'
              : widget.id == 'Energy Management'
                  ? 'EnergyManagement.pdf'
                  : '';

      final savedPDFFile = await savePDFToFile(pdfData, fileName);

      await pr.hide();
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await FlutterLocalNotificationsPlugin().show(
        0, '${widget.id} Downloaded', 'Tap to open', notificationDetails,
        payload: pathToOpenFile);
  }

  Future<File> savePDFToFile(Uint8List pdfData, String fileName) async {
    if (await Permission.storage.request().isGranted) {
      final documentDirectory =
          (await DownloadsPath.downloadsDirectory())?.path;
      final file = File('$documentDirectory/$fileName');

      int counter = 1;
      String newFilePath = file.path;
      // if (await File(newFilePath).exists()) {
      //   final baseName = fileName.split('.').first;
      //   final extension = fileName.split('.').last;
      //   while (await File(newFilePath).exists()) {
      //     counter++;
      //     newFilePath =
      //         '$documentDirectory/$baseName-${counter.toString()}.$extension';
      //   }
      //   pathToOpenFile = newFilePath.toString();
      //   await file.copy(newFilePath);
      //   await file.writeAsBytes(pdfData);
      // } else {
      await file.writeAsBytes(pdfData);
      pathToOpenFile = newFilePath.toString();
      return file;
      // }
    }
    return File('');
  }

  Future<void> getUserId() async {
    await AuthService().getCurrentUserId().then((value) {
      userId = value;
    });
  }
}

List<BarChartGroupData> barChartGroupData(List<dynamic> data) {
  return List.generate(
    data.length,
    ((index) {
      return BarChartGroupData(
        x: index,
        showingTooltipIndicators: [0],
        barRods: [
          BarChartRodData(
              borderSide: BorderSide(color: white),
              backDrawRodData: BackgroundBarChartRodData(
                toY: 0,
                fromY: 0,
                show: true,
              ),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 16, 81, 231),
                  Color.fromARGB(255, 190, 207, 252)
                ],
              ),
              width: 8,
              borderRadius: BorderRadius.circular(2),
              toY: double.parse(data[index].toString())),
        ],
      );
    }),
  );
}