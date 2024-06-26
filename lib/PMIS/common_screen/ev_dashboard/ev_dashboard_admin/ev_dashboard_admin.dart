import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:ev_pmis_app/components/Loading_page.dart';
import 'package:ev_pmis_app/PMIS/provider/scroll_top_provider.dart';
import 'package:ev_pmis_app/PMIS/provider/selected_row_index.dart';
import 'package:ev_pmis_app/style.dart';
import 'package:ev_pmis_app/PMIS/widgets/table_loading.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

List<dynamic> cityList = [];

class EVDashboardAdmin extends StatefulWidget {
  final bool showAppBar;
  final Function? callbackFun;
  String role;
 EVDashboardAdmin({Key? key, this.callbackFun, this.showAppBar = false,required this.role})
      : super(key: key);

  static const String id = 'admin-page';

  @override
  State<EVDashboardAdmin> createState() => _EVDashboardAdminState();
}

class _EVDashboardAdminState extends State<EVDashboardAdmin> {
  List estimatedEndDate = [];
  var currentPage = DrawerSection.evDashboard;

  List<String> pageNames = [
    'EV Dashboard Project',
    'O & M Dashboard',
    'Cities',
    'User'
  ];

  int selectedIndex = 0;

  List<String> tabNamesToStore = [
    'evTable',
    'budgetTable',
    'actualTable',
    'tmlJmrTable',
    'commercialTable',
    'assetTable'
  ];

  bool isTableLoading = false;
  List<dynamic> startDateList = [];
  List<dynamic> estimatedDateList = [];
  List<dynamic> actualEndDateList = [];
  List<dynamic> endDateList = [];
  final ScrollController _scrollController = ScrollController();
  dynamic depotProgress = '';
  List<double> depotProgressList = [];

  List<String> selectedDepoList = [];
  List<List<dynamic>> rowList = [];

  String selectedCity = '';

  List<String> evProgressTable = [
    'Name of Project',
    'Depot Name',
    '% of Physical\nprogress',
    'Planned Start\nDate',
    'Planned End\nDate',
    'Estimated Date of\nCompletion',
    'Project Actual End\nDate'
  ];

  double totalPlannedChargers = 0;
  double totalChargersCommissioned = 0;
  double totalBalancedCharger = 0;
  double totalTprelBudget = 0;
  double totalTpevslBudget = 0;
  double totalBudget = 0;
  double totalActualExpenseTprel = 0;
  double totalActualExpenseTpevsl = 0;
  double totalActualExpense = 0;
  double totalInfraAmount = 0;
  double totalEvChargerAmount = 0;
  double totalApprovedJmrAmount = 0;
  double totalPendingJmrAmount = 0;
  double totalFinancialProgress = 0;
  double totalPendingJmrPercent = 0;
  double totalTprelAssetCapitalised = 0;
  double totalTpevslAssetCapitalised = 0;
  double totalCumulativeAssetCapitalised = 0;
  double totalPendingAssetCapitlization = 0;

  List<dynamic> evTotalList = [];
  List<dynamic> budgetTotalList = [];
  List<dynamic> actualTotalList = [];
  List<dynamic> tmlTotalList = [];
  List<dynamic> assetTotalList = [];
  List<dynamic> budgetActualTotalList = [];
  List<dynamic> commercialTotalList = [];
  List<Color> colorList = [Colors.blue, Colors.blue[900]!];
  bool isExcelSelected = false;
  int totalForAllCol = 0;
  Map<String, dynamic> evBusProgressPieData = {};
  Map<String, dynamic> budgerPieData = {};
  Map<String, dynamic> actualExpensePieData = {};
  Map<String, dynamic> assetCapitalisedPieData = {};
  Map<String, dynamic> tmlApprovedPieData = {};

  List<String> evProgressLegendNames = [
    'Chargers \n  Commisioned',
    'Balance \n Chargers',
    'Chargers \n  Commisioned',
  ];

  List<String> evBottomValue = [
    'Planned Chargers',
    'Chargers Commisioned',
    'Balance Chargers'
  ];

  List<List<String>> budgetLegendNames = [
    ['TPREL\nBudget', 'TPEVSL\nBudget', 'Total\nBuget'],
    ['Actual\nExpense TPREL', 'Actual\nExpense TPEVSL', 'Total\nActual'],
  ];

  List<List<String>> budgetActualBottomValue = [
    ['TPREL Budget', 'TPEVSL Budget', 'Total Buget'],
    ['Actual Expense TPREL', 'Actual Expense TPEVSL', 'Total Actual TPEVSL'],
    ['TPREL Budget', 'TPEVSL Budget', 'Total Buget'],
    ['Actual Expense TPREL', 'Actual Expense TPEVSL', 'Total Actual TPEVSL'],
  ];

  List<String> actualExpenseLegendNames = [
    'Actual Expense \n TPREL',
    'Actual Expense \n TPEVSL',
    'Total Actual \n Expense'
  ];

  List<String> assetCapitalisedLegendNames = [
    'Cumulative Asset \n Capitalised Amount (FY24)',
    'Pending Asset \n Capitalisation Amount'
  ];

  List<String> tmlApprovedLegendNames = [
    'Approved \n JMR Amount',
    'Pending \n JMR Amount'
  ];

  List<String> tmlApprovedBottomValue = [
    'Infra Amount',
    'EV chargers Amount',
    'Approved JMR Amount',
    'Pending JMR Amount'
  ];

  List<String> commercialBottomValue = [
    '% of financial\nProgress',
    '% of pending JMR\nApproval'
  ];

  double piePercentSize = 13;
  double tableDataFontSize = 0;
  dynamic deviceHeight = 0;
  double fontSize = 0;
  double tableHeadingFontSize = 0;
  double chartRadius = 0;
  bool isLoading = true;

  List<dynamic> projectNameCol = [];
  int projectNameColLen = 0;
  List<dynamic> plannedChargersCol = [];
  List<dynamic> chargersComissioned = [];

  List<dynamic> budgetActualCol = [];

  List<dynamic> tprelBudgetCol = [];
  int tprelBudgetColLen = 0;
  List<dynamic> tpevslBudgetCol = [];
  List<dynamic> budgetCol = [];

  List<dynamic> actualExpenseTprelCol = [];
  List<dynamic> actualExpenseTpevslCol = [];
  List<dynamic> totalActualExpenseCol = [];

  List<dynamic> infraAmountCol = [];
  int infraAmountColLen = 0;
  List<dynamic> evChargersAmountCol = [];
  List<dynamic> totalApprovedJmrAmountCol = [];
  List<dynamic> totalPendingJmrAmountCol = [];

  List<dynamic> financialProgressCol = [];
  int financialProgressLen = 0;
  List<dynamic> pendingJmrApprovalCol = [];

  List<dynamic> assetCapitalisedTprelCol = [];
  int assetCapitalisedTprelLen = 0;
  List<dynamic> assetCapitalisedTpevslCol = [];
  List<dynamic> cumulativeAssetCapitalizedCol = [];
  List<dynamic> pendingAssetCapitalisationCol = [];

  List<String> dashboardTitle = [
    'Budget',
    'Actual Expense',
    'TML Approved JMR Status'
  ];

  List<List<String?>> secondSheetData = [];

  List<String> assetCapitalisationBottomValue = [
    ' Asset Capitalised (TPREL)',
    'Asset Capitalised (TPEVCSL)',
    'Cumulative Asset Capitalised',
    'Pending Asset Capitalised ',
    ' Asset Capitalised (TPREL)',
    'Asset Capitalised (TPEVCSL)',
    'Cumulative Asset Capitalised',
    'Pending Asset Capitalised ',
  ];

  List<String> assetCapitalisation = [
    ' Asset Capitalised\nAmount(TPREL)',
    'Asset Capitalised\nAmount\n(TPEVCSL)',
    'Cumulative Asset\nCapitalised\nAmount(FY24)',
    'Pending Asset \nCapitalisation\nAmount',
  ];

  List<List<String>> dashboardColNames = [
    ['TPREL Budget\n(FY24)', 'TPEVSL Budget\n(FY24)', 'Total Buget\n(FY24)'],
    [
      'Actual Expense\n(TPREL-FY24)',
      'Actual Expense\n(TPEVSL-FY24)',
      'Total Actual\nExpense(FY24)'
    ],
    [
      'Infra Amount\n(TPREL)',
      'EV chargers\nAmount\n(TPEVCSL)',
      'Approved\nJMR Amount',
      'Pending\nJMR Amount'
    ],
    ['Project Name', "Planned\nChargers", 'Chargers\nCommissioned']
  ];

  int touchIndex = 0;
  double _previousOffset = 0;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    getCityName();
    fetchExcelData();
    _scrollController.addListener(() {
      final provider = Provider.of<ScrollProvider>(context, listen: false);
      if (_scrollController.offset > _previousOffset) {
        setState(() {
          provider.setTop(true);
        });
      } else {
        setState(() {
          provider.setTop(false);
        });
      }
      _previousOffset = _scrollController.offset;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    deviceHeight = MediaQuery.of(context).size.height;
    if (deviceHeight < 700) {
      tableDataFontSize = 11;
      tableHeadingFontSize = 8;
      chartRadius = 60;
      fontSize = 8;
    } else {
      tableDataFontSize = 12;
      tableHeadingFontSize = 8;
      chartRadius = 90;
      fontSize = 11;
    }
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: AppBar(
            centerTitle: true,
            backgroundColor: blue,
            title: const Text(
              'EV Bus Project Analysis Dashboard',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // IconButton(
              //     onPressed: () {
              //       showSearch(
              //           context: context, delegate: CustomSearchDelegate());
              //     },
              //     icon: const Icon(Icons.search))
            ],
          ),
        ),
        body: isLoading
            ? const LoadingPage()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 245,
                                width: MediaQuery.of(context).size.width * 0.32,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 10,
                                        left: 0,
                                        child: Container(
                                          width: width * 0.32,
                                          height: 235,
                                          child: Card(
                                              elevation: 10,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                    20,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      5.0,
                                                    ),
                                                    height: 45,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: 2,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                ((context,
                                                                    index) {
                                                              return Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5.0,
                                                                        top:
                                                                            10.0),
                                                                child: RichText(
                                                                    text: TextSpan(
                                                                        children: [
                                                                      WidgetSpan(
                                                                          child: Container(
                                                                              height: 10,
                                                                              width: 10,
                                                                              color: colorList[index])),
                                                                      const WidgetSpan(
                                                                          child:
                                                                              SizedBox(
                                                                        width:
                                                                            5,
                                                                      )),
                                                                      TextSpan(
                                                                          text: evProgressLegendNames[
                                                                              index],
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 10))
                                                                    ])),
                                                              );
                                                            })),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        height: 130,
                                                        width: width * 0.195,
                                                        // MediaQuery.of(context)
                                                        //         .size
                                                        //         .width *
                                                        //     0.88 /
                                                        //     3.8,
                                                        child: DataTable2(
                                                            horizontalMargin: 5,
                                                            minWidth: 250,
                                                            headingRowColor:
                                                                MaterialStatePropertyAll(
                                                                    blue),
                                                            headingTextStyle:
                                                                TextStyle(
                                                                    color:
                                                                        white,
                                                                    fontSize:
                                                                        tableHeadingFontSize),
                                                            headingRowHeight:
                                                                25,
                                                            dataTextStyle:
                                                                TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: 8,
                                                                    color:
                                                                        black),
                                                            columnSpacing: 3,
                                                            showBottomBorder:
                                                                false,
                                                            dividerThickness: 0,
                                                            dataRowHeight: 20,
                                                            columns: [
                                                              DataColumn2(
                                                                  fixedWidth:
                                                                      80,
                                                                  label: Text(
                                                                    dashboardColNames[
                                                                        3][0],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  )),
                                                              DataColumn2(
                                                                  fixedWidth:
                                                                      70,
                                                                  label: Text(
                                                                    dashboardColNames[
                                                                        3][1],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  )),
                                                              DataColumn2(
                                                                  label: Text(
                                                                dashboardColNames[
                                                                    3][2],
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              )),
                                                            ],
                                                            rows: List.generate(
                                                                projectNameColLen,
                                                                (index) {
                                                              return DataRow2(
                                                                  color: index ==
                                                                          Provider.of<SelectedRowIndexModel>(context, listen: false)
                                                                              .selectedRowIndex
                                                                      ? const MaterialStatePropertyAll(Color.fromARGB(
                                                                          255,
                                                                          190,
                                                                          226,
                                                                          255))
                                                                      : MaterialStatePropertyAll(
                                                                          white),
                                                                  onTap:
                                                                      () async {
                                                                    String
                                                                        cityName;
                                                                    cityName = await getCityFromString(
                                                                        projectNameCol[index]
                                                                            .toString());

                                                                    getDepoName(
                                                                            cityName)
                                                                        .whenComplete(
                                                                            () {
                                                                      getRowsForFutureBuilder();
                                                                      Provider.of<SelectedRowIndexModel>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .setSelectedRowIndex(
                                                                              index);
                                                                    });
                                                                  },
                                                                  cells: [
                                                                    DataCell(Text(
                                                                        projectNameCol[index]
                                                                            .toString())),
                                                                    DataCell(Text(
                                                                        '${plannedChargersCol[index].toString()} Nos')),
                                                                    DataCell(Text(
                                                                        '${chargersComissioned[index].toString()} Nos')),
                                                                  ]);
                                                            })),
                                                      ),
                                                      Container(
                                                        child: PieChart(
                                                          dataMap: {
                                                            dashboardColNames[3]
                                                                    [1]:
                                                                isExcelSelected
                                                                    ? double.parse(
                                                                        chargersComissioned[
                                                                            totalForAllCol])
                                                                    : 0,
                                                            dashboardColNames[3]
                                                                    [2]:
                                                                isExcelSelected
                                                                    ? totalBalancedCharger
                                                                    : 0,
                                                          },
                                                          legendOptions:
                                                              const LegendOptions(
                                                                  showLegends:
                                                                      false),
                                                          animationDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      1500),
                                                          chartValuesOptions:
                                                              ChartValuesOptions(
                                                            showChartValueBackground:
                                                                false,
                                                            decimalPlaces: 0,
                                                            chartValueStyle:
                                                                TextStyle(
                                                                    color:
                                                                        white,
                                                                    fontSize:
                                                                        piePercentSize),
                                                            showChartValuesInPercentage:
                                                                true,
                                                          ),
                                                          chartRadius:
                                                              chartRadius,
                                                          colorList: colorList,
                                                          chartType:
                                                              ChartType.disc,
                                                          totalValue: isExcelSelected
                                                              ? double.parse(
                                                                  plannedChargersCol[
                                                                      totalForAllCol])
                                                              : 0,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    // color: red,
                                                    width: width * 0.31,
                                                    //  MediaQuery.of(context)
                                                    //         .size
                                                    //         .width *
                                                    //     0.99 /
                                                    //     3.2,
                                                    height: 50,
                                                    child: GridView.builder(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing: 0.0,
                                                        childAspectRatio: 4.5,
                                                      ),
                                                      itemCount: 3,
                                                      itemBuilder:
                                                          (context, index3) {
                                                        return RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              // WidgetSpan(
                                                              //   child:
                                                              //       ConstrainedBox(
                                                              //     constraints:
                                                              //         BoxConstraints(
                                                              //             maxWidth:
                                                              //                 60),
                                                              //     child: Text(
                                                              //       evBottomValue[
                                                              //           index3],
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               8,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .bold,
                                                              //           color:
                                                              //               black),
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                              TextSpan(
                                                                  text:
                                                                      '${evBottomValue[index3]}:',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          black)),
                                                              const WidgetSpan(
                                                                  child:
                                                                      SizedBox(
                                                                width: 5,
                                                              )),
                                                              TextSpan(
                                                                  text: isExcelSelected
                                                                      ? '${evTotalList[index3].toString()} Nos'
                                                                      : '0',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          9,
                                                                      color:
                                                                          blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ],
                                              )),
                                        )),
                                    Positioned(
                                      top: 0,
                                      left: 15,
                                      child: Card(
                                        shadowColor: Colors.black,
                                        elevation: 5,
                                        color: blue,
                                        child: Container(
                                          height: 25,
                                          padding: const EdgeInsets.all(5.0),
                                          child: const Text(
                                            'EV Bus Project Progress Status',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                height: 250,
                                width: MediaQuery.of(context).size.width * 0.33,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 10,
                                        left: 0,
                                        child: Container(
                                          width: width * 0.33,
                                          height: 235,
                                          child: Card(
                                              elevation: 10,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.95,
                                                    height: 45,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            itemCount: 2,
                                                            itemBuilder:
                                                                ((context,
                                                                    index) {
                                                              return Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5.0,
                                                                        top:
                                                                            10.0),
                                                                child: RichText(
                                                                    text: TextSpan(
                                                                        children: [
                                                                      WidgetSpan(
                                                                          child: Container(
                                                                              height: 10,
                                                                              width: 10,
                                                                              color: colorList[index])),
                                                                      const WidgetSpan(
                                                                          child:
                                                                              SizedBox(
                                                                        width:
                                                                            5,
                                                                      )),
                                                                      TextSpan(
                                                                          text: tmlApprovedLegendNames[
                                                                              index],
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                              fontSize: 10))
                                                                    ])),
                                                              );
                                                            })),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        height: 130,
                                                        width: width * 0.2,
                                                        child: DataTable2(
                                                            horizontalMargin: 5,
                                                            minWidth: 320,
                                                            headingRowColor:
                                                                MaterialStatePropertyAll(
                                                                    blue),
                                                            headingTextStyle:
                                                                TextStyle(
                                                                    letterSpacing:
                                                                        0.5,
                                                                    color:
                                                                        white,
                                                                    fontSize:
                                                                        tableHeadingFontSize),
                                                            headingRowHeight:
                                                                28,
                                                            dataTextStyle: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    tableDataFontSize,
                                                                color: black),
                                                            columnSpacing: 2,
                                                            showBottomBorder:
                                                                false,
                                                            dividerThickness: 0,
                                                            dataRowHeight: 20,
                                                            columns: [
                                                              DataColumn2(
                                                                  label: Text(
                                                                dashboardColNames[
                                                                    2][0],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              )),
                                                              DataColumn2(
                                                                  label: Text(
                                                                dashboardColNames[
                                                                    2][1],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              )),
                                                              DataColumn2(
                                                                  label: Text(
                                                                dashboardColNames[
                                                                    2][2],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              )),
                                                              DataColumn2(
                                                                  label: Text(
                                                                dashboardColNames[
                                                                    2][3],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              )),
                                                            ],
                                                            rows: List.generate(
                                                                infraAmountColLen,
                                                                (index) {
                                                              return DataRow2(
                                                                  color: index ==
                                                                          Provider.of<SelectedRowIndexModel>(context, listen: false)
                                                                              .selectedRowIndex
                                                                      ? const MaterialStatePropertyAll(Color.fromARGB(
                                                                          255,
                                                                          190,
                                                                          226,
                                                                          255))
                                                                      : MaterialStatePropertyAll(
                                                                          white),
                                                                  cells: [
                                                                    DataCell(Text(
                                                                        formatNum(
                                                                            double.parse(infraAmountCol[index])))),
                                                                    DataCell(Text(
                                                                        formatNum(
                                                                            double.parse(evChargersAmountCol[index])))),
                                                                    DataCell(Text(
                                                                        formatNum(
                                                                            double.parse(totalApprovedJmrAmountCol[index])))),
                                                                    DataCell(Text(
                                                                        formatNum(
                                                                            double.parse(totalPendingJmrAmountCol[index])))),
                                                                  ]);
                                                            })),
                                                      ),
                                                      PieChart(
                                                        dataMap: {
                                                          tmlApprovedLegendNames[
                                                                  0]:
                                                              isExcelSelected
                                                                  ? double.parse(
                                                                      totalApprovedJmrAmountCol[
                                                                          totalForAllCol])
                                                                  : 0,
                                                          tmlApprovedLegendNames[
                                                                  1]:
                                                              isExcelSelected
                                                                  ? double.parse(
                                                                      totalPendingJmrAmountCol[
                                                                          totalForAllCol])
                                                                  : 0,
                                                        },
                                                        legendOptions:
                                                            const LegendOptions(
                                                                showLegends:
                                                                    false),
                                                        animationDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1500),
                                                        chartValuesOptions:
                                                            ChartValuesOptions(
                                                          decimalPlaces: 0,
                                                          showChartValueBackground:
                                                              false,
                                                          chartValueStyle:
                                                              TextStyle(
                                                                  color: white,
                                                                  fontSize:
                                                                      piePercentSize),
                                                          showChartValuesInPercentage:
                                                              true,
                                                        ),
                                                        chartRadius:
                                                            chartRadius,
                                                        colorList: colorList,
                                                        chartType:
                                                            ChartType.disc,
                                                        totalValue: isExcelSelected
                                                            ? double.parse(
                                                                    totalApprovedJmrAmountCol[
                                                                        totalForAllCol]) +
                                                                double.parse(
                                                                    totalPendingJmrAmountCol[
                                                                        totalForAllCol])
                                                            : 0,
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    width: width * 0.308,
                                                    height: 50,
                                                    child: GridView.builder(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2,
                                                                crossAxisSpacing:
                                                                    0,
                                                                childAspectRatio:
                                                                    6),
                                                        itemCount: 4,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                WidgetSpan(
                                                                  child: Text(
                                                                    tmlApprovedBottomValue[
                                                                        index],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          black,
                                                                    ),
                                                                  ),
                                                                ),

                                                                // TextSpan(
                                                                //     text:
                                                                //         //  '${MoneyFormatter(amount: double.parse(budgetActualTotalList[index1][index3].toString()), settings: MoneyFormatterSettings(symbol: '₹')).output.symbolOnLeft}'
                                                                //         '${tmlApprovedBottomValue[index]}:',
                                                                //     style: TextStyle(
                                                                //         fontSize:
                                                                //             10,
                                                                //         fontWeight:
                                                                //             FontWeight
                                                                //                 .bold,
                                                                //         color:
                                                                //             black,),),

                                                                const WidgetSpan(
                                                                    child:
                                                                        SizedBox(
                                                                  width: 5,
                                                                )),
                                                                TextSpan(
                                                                    text: isExcelSelected
                                                                        ? formatNum(double.parse(tmlTotalList[index]
                                                                            .toString()))
                                                                        : '0',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            9,
                                                                        color:
                                                                            blue,
                                                                        fontWeight:
                                                                            FontWeight.bold))
                                                              ]));
                                                        }),
                                                  )
                                                ],
                                              )),
                                        )),
                                    Positioned(
                                        top: 0,
                                        left: 15,
                                        child: Card(
                                            shadowColor: Colors.black,
                                            elevation: 5,
                                            color: blue,
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  dashboardTitle[2],
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.67,
                                height: 245,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: 2,
                                    itemBuilder: ((context, index1) {
                                      return Container(
                                        width: width * 0.33,
                                        height: 245,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                                top: 10,
                                                child: Container(
                                                  width: width * 0.33,
                                                  height: 235,
                                                  child: Card(
                                                      elevation: 10,
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.84,
                                                            height: 45,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                ListView
                                                                    .builder(
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemCount:
                                                                            2,
                                                                        itemBuilder:
                                                                            ((context,
                                                                                index) {
                                                                          return Container(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 5.0, top: 10.0),
                                                                            child: RichText(
                                                                                text: TextSpan(children: [
                                                                              WidgetSpan(child: Container(height: 10, width: 10, color: colorList[index])),
                                                                              const WidgetSpan(
                                                                                  child: SizedBox(
                                                                                width: 5,
                                                                              )),
                                                                              TextSpan(
                                                                                  text: budgetLegendNames[index1][index],
                                                                                  style: const TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontSize: 9,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ))
                                                                            ])),
                                                                          );
                                                                        })),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                height: 130,
                                                                width:
                                                                    width * 0.2,
                                                                child:
                                                                    DataTable2(
                                                                        minWidth:
                                                                            280,
                                                                        headingRowColor:
                                                                            MaterialStatePropertyAll(
                                                                                blue),
                                                                        headingTextStyle: TextStyle(
                                                                            color:
                                                                                white,
                                                                            fontSize:
                                                                                tableHeadingFontSize),
                                                                        headingRowHeight:
                                                                            25,
                                                                        dataTextStyle: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                tableDataFontSize,
                                                                            color:
                                                                                black),
                                                                        columnSpacing:
                                                                            2,
                                                                        showBottomBorder:
                                                                            false,
                                                                        dividerThickness:
                                                                            0,
                                                                        dataRowHeight:
                                                                            20,
                                                                        columns: [
                                                                          DataColumn2(
                                                                              label: Text(
                                                                            dashboardColNames[index1][0],
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                          )),
                                                                          DataColumn2(
                                                                              label: Text(
                                                                            dashboardColNames[index1][1],
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                          )),
                                                                          DataColumn2(
                                                                              label: Text(
                                                                            dashboardColNames[index1][2],
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                          )),
                                                                        ],
                                                                        rows: List.generate(
                                                                            tprelBudgetColLen,
                                                                            (index2) {
                                                                          return DataRow2(
                                                                              color: index2 == Provider.of<SelectedRowIndexModel>(context, listen: false).selectedRowIndex ? const MaterialStatePropertyAll(Color.fromARGB(255, 190, 226, 255)) : MaterialStatePropertyAll(white),
                                                                              cells: [
                                                                                DataCell(Text(formatNum(double.parse(budgetActualCol[index1][0][index2].toString())))),
                                                                                DataCell(Text(formatNum(double.parse(budgetActualCol[index1][1][index2].toString())))),
                                                                                DataCell(Text(formatNum(double.parse(budgetActualCol[index1][2][index2].toString())))),
                                                                              ]);
                                                                        })),
                                                              ),
                                                              Container(
                                                                child: PieChart(
                                                                  dataMap: {
                                                                    budgetActualBottomValue[index1]
                                                                            [0]:
                                                                        isExcelSelected
                                                                            ? index1 == 0
                                                                                ? double.parse(tprelBudgetCol[totalForAllCol])
                                                                                : double.parse(actualExpenseTprelCol[totalForAllCol])
                                                                            : 0,
                                                                    budgetActualBottomValue[index1]
                                                                            [1]:
                                                                        isExcelSelected
                                                                            ? index1 == 0
                                                                                ? double.parse(tpevslBudgetCol[totalForAllCol])
                                                                                : double.parse(actualExpenseTpevslCol[totalForAllCol])
                                                                            : 0,
                                                                  },
                                                                  legendOptions:
                                                                      const LegendOptions(
                                                                          showLegends:
                                                                              false),
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              1500),
                                                                  chartValuesOptions:
                                                                      ChartValuesOptions(
                                                                    decimalPlaces:
                                                                        0,
                                                                    showChartValueBackground:
                                                                        false,
                                                                    chartValueStyle: TextStyle(
                                                                        color:
                                                                            white,
                                                                        fontSize:
                                                                            piePercentSize),
                                                                    showChartValuesInPercentage:
                                                                        true,
                                                                  ),
                                                                  chartRadius:
                                                                      chartRadius,
                                                                  colorList:
                                                                      colorList,
                                                                  chartType:
                                                                      ChartType
                                                                          .disc,
                                                                  totalValue: isExcelSelected
                                                                      ? index1 == 0
                                                                          ? double.parse(tprelBudgetCol[totalForAllCol]) + double.parse(tpevslBudgetCol[totalForAllCol])
                                                                          : index1 == 1
                                                                              ? double.parse(actualExpenseTprelCol[totalForAllCol]) + double.parse(actualExpenseTpevslCol[totalForAllCol])
                                                                              : 0
                                                                      : 0,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 5),
                                                            width: width * 0.31,
                                                            height: 50,
                                                            child: GridView
                                                                .builder(
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            0),
                                                                    shrinkWrap:
                                                                        true,
                                                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                        crossAxisCount:
                                                                            2,
                                                                        crossAxisSpacing:
                                                                            0,
                                                                        childAspectRatio:
                                                                            5),
                                                                    itemCount:
                                                                        3,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index3) {
                                                                      return RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                            TextSpan(
                                                                                text: '${budgetActualBottomValue[index1][index3]}',
                                                                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: black)),
                                                                            const WidgetSpan(
                                                                                child: SizedBox(
                                                                              width: 5,
                                                                            )),
                                                                            TextSpan(
                                                                                text: isExcelSelected ? formatNum(double.parse(budgetActualTotalList[index1][index3].toString())) : '0',
                                                                                style: TextStyle(fontSize: 9, color: blue, fontWeight: FontWeight.bold))
                                                                          ]));
                                                                    }),
                                                          )
                                                        ],
                                                      )),
                                                )),
                                            Positioned(
                                                top: 0,
                                                left: 15,
                                                child: Card(
                                                    shadowColor: Colors.black,
                                                    elevation: 5,
                                                    color: blue,
                                                    child: Container(
                                                        height: 25,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Text(
                                                          dashboardTitle[
                                                              index1],
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )))),
                                          ],
                                        ),
                                      );
                                    })),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Commercial Achievement

                                  Container(
                                    padding: EdgeInsets.only(top: 5),
                                    width: width * 0.26,
                                    height: 255,
                                    child: Stack(
                                      alignment: Alignment.topLeft,
                                      children: [
                                        Positioned(
                                          top: 10,
                                          left: 0,
                                          child: Container(
                                            width: width * 0.26,
                                            height: 235,
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                    20,
                                                  ),
                                                ),
                                              ),
                                              elevation: 10,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 25),
                                                    height: 150,
                                                    width: width * 0.26,
                                                    child: DataTable2(
                                                        horizontalMargin: 5,
                                                        headingRowHeight: 28,
                                                        headingRowColor:
                                                            MaterialStatePropertyAll(
                                                                blue),
                                                        columnSpacing: 10,
                                                        dataTextStyle: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                tableDataFontSize,
                                                            color: black),
                                                        dataRowHeight: 20,
                                                        headingTextStyle: TextStyle(
                                                            color: white,
                                                            fontSize:
                                                                tableHeadingFontSize),
                                                        showBottomBorder: false,
                                                        dividerThickness: 0,
                                                        columns: const [
                                                          DataColumn2(
                                                              label: Text(
                                                            '% of Financial Progress\nof EV Bus Project',
                                                            textAlign: TextAlign
                                                                .center,
                                                          )),
                                                          DataColumn2(
                                                              label: Text(
                                                            '% of pending JMR\napproval form TML',
                                                            textAlign: TextAlign
                                                                .center,
                                                          )),
                                                        ],
                                                        rows: List.generate(
                                                            financialProgressLen,
                                                            (index) {
                                                          return DataRow2(
                                                              color: index ==
                                                                      Provider.of<SelectedRowIndexModel>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .selectedRowIndex
                                                                  ? const MaterialStatePropertyAll(
                                                                      Color.fromARGB(
                                                                          255,
                                                                          190,
                                                                          226,
                                                                          255))
                                                                  : MaterialStatePropertyAll(
                                                                      white),

                                                              // onSelectChanged: (isSelected) {
                                                              //   Provider.of<SelectedRowIndexModel>(
                                                              //           context,
                                                              //           listen: false)
                                                              //       .setSelectedRowIndex(index);
                                                              // },
                                                              cells: [
                                                                DataCell(Text(
                                                                    '${financialProgressCol[index].toString()}%')),
                                                                DataCell(Text(
                                                                    '${pendingJmrApprovalCol[index]}%')),
                                                              ]);
                                                        })),
                                                  ),
                                                  Container(
                                                    width: width * 0.25,
                                                    height: 50,
                                                    child: GridView.builder(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2,
                                                                crossAxisSpacing:
                                                                    0,
                                                                childAspectRatio:
                                                                    2),
                                                        itemCount: 2,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Column(
                                                            children: [
                                                              Text(
                                                                commercialBottomValue[
                                                                    index],
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        10,
                                                                    color:
                                                                        blue),
                                                              ),
                                                              Text(
                                                                isExcelSelected
                                                                    ? '${commercialTotalList[index].toString()}%'
                                                                    : '0%',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 10,
                                                                ),
                                                              )
                                                            ],
                                                          );
                                                        }),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            left: 15,
                                            child: Card(
                                                shadowColor: Colors.black,
                                                elevation: 5,
                                                color: blue,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: const Text(
                                                      'Commercial Achievement',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )))),
                                      ],
                                    ),
                                  ),

                                  //Asset Capitalized

                                  Container(
                                    width: width * 0.41,
                                    height: 250,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 10,
                                          left: 0,
                                          child: Container(
                                            width: width * 0.4,
                                            height: 240,
                                            child: Card(
                                                elevation: 10,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.82,
                                                      height: 45,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          ListView.builder(
                                                              scrollDirection:
                                                                  Axis
                                                                      .horizontal,
                                                              shrinkWrap: true,
                                                              itemCount: 2,
                                                              itemBuilder:
                                                                  ((context,
                                                                      index) {
                                                                return Container(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 5.0,
                                                                      top:
                                                                          10.0),
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        WidgetSpan(
                                                                            child: Container(
                                                                                height: 10,
                                                                                width: 10,
                                                                                color: colorList[index])),
                                                                        const WidgetSpan(
                                                                            child:
                                                                                SizedBox(
                                                                          width:
                                                                              5,
                                                                        )),
                                                                        TextSpan(
                                                                            text:
                                                                                assetCapitalisedLegendNames[index],
                                                                            style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.bold,
                                                                            ))
                                                                      ])),
                                                                );
                                                              })),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          height: 130,
                                                          width: width * 0.27,
                                                          child: DataTable2(
                                                              horizontalMargin:
                                                                  8,
                                                              minWidth: 330,
                                                              headingRowColor:
                                                                  MaterialStatePropertyAll(
                                                                      blue),
                                                              headingTextStyle: TextStyle(
                                                                  color: white,
                                                                  fontSize:
                                                                      tableHeadingFontSize),
                                                              headingRowHeight:
                                                                  30,
                                                              dataTextStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      tableDataFontSize,
                                                                  color: black),
                                                              columnSpacing: 2,
                                                              showBottomBorder:
                                                                  false,
                                                              dividerThickness:
                                                                  0,
                                                              dataRowHeight: 20,
                                                              columns: [
                                                                DataColumn2(
                                                                    label: Text(
                                                                  assetCapitalisation[
                                                                      0],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                )),
                                                                DataColumn2(
                                                                    label: Text(
                                                                  assetCapitalisation[
                                                                      1],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                )),
                                                                DataColumn2(
                                                                    label: Text(
                                                                  assetCapitalisation[
                                                                      2],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                )),
                                                                DataColumn2(
                                                                    label: Text(
                                                                  assetCapitalisation[
                                                                      3],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                )),
                                                              ],
                                                              rows: List.generate(
                                                                  assetCapitalisedTprelLen,
                                                                  (index) {
                                                                return DataRow2(
                                                                    color: index ==
                                                                            Provider.of<SelectedRowIndexModel>(context, listen: true)
                                                                                .selectedRowIndex
                                                                        ? const MaterialStatePropertyAll(Color.fromARGB(
                                                                            255,
                                                                            190,
                                                                            226,
                                                                            255))
                                                                        : MaterialStatePropertyAll(
                                                                            white),
                                                                    cells: [
                                                                      DataCell(Text(
                                                                          formatNum(
                                                                              double.parse(assetCapitalisedTprelCol[index].toString())))),
                                                                      DataCell(Text(
                                                                          formatNum(
                                                                              double.parse(assetCapitalisedTpevslCol[index].toString())))),
                                                                      DataCell(Text(
                                                                          formatNum(
                                                                              double.parse(cumulativeAssetCapitalizedCol[index].toString())))),
                                                                      DataCell(Text(
                                                                          formatNum(
                                                                              double.parse(pendingAssetCapitalisationCol[index].toString())))),
                                                                    ]);
                                                              })),
                                                        ),
                                                        PieChart(
                                                            dataMap: {
                                                              assetCapitalisedLegendNames[
                                                                      0]:
                                                                  isExcelSelected
                                                                      ? double.parse(
                                                                          cumulativeAssetCapitalizedCol[
                                                                              totalForAllCol])
                                                                      : 0,
                                                              assetCapitalisedLegendNames[
                                                                      1]:
                                                                  isExcelSelected
                                                                      ? double.parse(
                                                                          pendingAssetCapitalisationCol[
                                                                              totalForAllCol])
                                                                      : 0,
                                                            },
                                                            legendOptions:
                                                                const LegendOptions(
                                                                    showLegends:
                                                                        false),
                                                            animationDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        1500),
                                                            chartValuesOptions:
                                                                ChartValuesOptions(
                                                              decimalPlaces: 0,
                                                              showChartValueBackground:
                                                                  false,
                                                              chartValueStyle:
                                                                  TextStyle(
                                                                      color:
                                                                          white,
                                                                      fontSize:
                                                                          piePercentSize),
                                                              showChartValuesInPercentage:
                                                                  true,
                                                            ),
                                                            chartRadius:
                                                                chartRadius,
                                                            colorList:
                                                                colorList,
                                                            chartType:
                                                                ChartType.disc,
                                                            totalValue: isExcelSelected
                                                                ? double.parse(
                                                                        cumulativeAssetCapitalizedCol[
                                                                            totalForAllCol]) +
                                                                    double.parse(
                                                                        pendingAssetCapitalisationCol[
                                                                            totalForAllCol])
                                                                : 0),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: width * 0.37,
                                                      height: 50,
                                                      child: GridView.builder(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 0),
                                                          shrinkWrap: true,
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                                  crossAxisCount:
                                                                      2,
                                                                  crossAxisSpacing:
                                                                      0,
                                                                  childAspectRatio:
                                                                      5),
                                                          itemCount: 4,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return RichText(
                                                                text: TextSpan(
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          '${assetCapitalisationBottomValue[index]} :',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              9,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              black)),
                                                                  const WidgetSpan(
                                                                    child:
                                                                        SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                      text: isExcelSelected
                                                                          ? formatNum(double.parse(assetTotalList[index]
                                                                              .toString()))
                                                                          : '0',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              9,
                                                                          color:
                                                                              blue,
                                                                          fontWeight:
                                                                              FontWeight.bold))
                                                                ]));
                                                          }),
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            left: 15,
                                            child: Card(
                                                shadowColor: Colors.black,
                                                elevation: 5,
                                                color: blue,
                                                child: Container(
                                                    height: 25,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: const Text(
                                                      'Asset Capitalised',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      // EV BUS PROGRESS REPORT

                      //See Table Button

                      // Container(
                      //   height: 50,
                      //   padding:
                      //       const EdgeInsets.only(right: 25, top: 5, bottom: 5),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       ElevatedButton(
                      //         onPressed: () {
                      //           _scrollTable();
                      //         },
                      //         child: const Text('See Table'),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'EV BUS Project Progress Report',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        endIndent: 10,
                        indent: 5,
                        color: blue,
                        thickness: 2,
                      ),
                      isTableLoading
                          ? const TableLoading()
                          : Container(
                              padding: const EdgeInsets.only(
                                top: 10,
                              ),
                              width: width * 0.98,
                              height: 600,
                              child: Consumer<SelectedRowIndexModel>(
                                builder: (context, value, child) {
                                  return DataTable2(
                                      columnSpacing: 16,
                                      horizontalMargin: 10,
                                      dataTextStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: blue,
                                          fontSize: 12),
                                      headingRowColor: MaterialStatePropertyAll(
                                        blue,
                                      ),
                                      dividerThickness: 0,
                                      minWidth: 900,
                                      // dataRowHeight: 40,
                                      headingRowHeight: 50,
                                      border: TableBorder.all(),
                                      headingTextStyle: TextStyle(
                                        fontSize: 12,
                                        color: white,
                                        letterSpacing: 0.5,
                                      ),
                                      columns:
                                          evProgressTable.map((columnNames) {
                                        return DataColumn2(
                                            fixedWidth: columnNames ==
                                                    '% of Physical\nprogress'
                                                ? 140
                                                : null,
                                            label: Text(columnNames));
                                      }).toList(),
                                      rows: List.generate(
                                          selectedDepoList.length, (index) {
                                        return DataRow2(cells: [
                                          DataCell(Text(selectedCity)),
                                          DataCell(
                                              Text(selectedDepoList[index])),
                                          DataCell(Text(
                                              '${depotProgressList[index].toStringAsFixed(1)}%')),
                                          DataCell(Text(startDateList[index])),
                                          DataCell(
                                              Text(actualEndDateList[index])),
                                          DataCell(
                                            Text(
                                              estimatedEndDate[index] == 'W.I.P'
                                                  ? actualEndDateList[index]
                                                  : 'Completed ✔',
                                              style: TextStyle(
                                                  color:
                                                      estimatedEndDate[index] !=
                                                              'W.I.P'
                                                          ? Colors.green
                                                          : Colors.black),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              estimatedEndDate[index],
                                            ),
                                          ),
                                          // DataCell(
                                          //     Text(actualEndDateList[index])),
                                        ]);
                                      }));
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<ScrollProvider>(
              builder: (context, value, child) {
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: value.isVisible ? 1.0 : 0.0,
                  child: InkWell(
                    onTap: () {
                      _goToTop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: blue,
                        shape: BoxShape.circle,

                        // borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.arrow_upward_sharp, color: white),
                      height: 50,
                      width: 50,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 35,
              width: 100,
              child: InkWell(
                onTap: () {
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]).whenComplete(() {
                    Navigator.pop(context);
                  });
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: white,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Back', style: TextStyle(color: white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 35,
              width: 140,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: pickAndProcessFile,
                child: Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.upload_file_outlined,
                        color: white,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child:
                          Text('Upload Excel', style: TextStyle(color: white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDepoName(selectCity) async {
    QuerySnapshot depoListQuery = await FirebaseFirestore.instance
        .collection('DepoName')
        .doc(selectCity)
        .collection('AllDepots')
        .get();

    List<String> depoList =
        depoListQuery.docs.map((deponame) => deponame.id).toList();
    selectedDepoList = depoList;
    print(selectedDepoList);
  }

  void _goToTop() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut);
  }

  Future<void> pickAndProcessFile() async {
    List<List<dynamic>> tempList1 = [];
    List<List<dynamic>> tempList2 = [];

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowedExtensions: ['xlsx'], type: FileType.custom);

      if (result != null) {
        //Clear All List
        projectNameCol.clear();
        plannedChargersCol.clear();
        chargersComissioned.clear();
        tprelBudgetCol.clear();
        tpevslBudgetCol.clear();
        budgetCol.clear();
        actualExpenseTprelCol.clear();
        actualExpenseTpevslCol.clear();
        totalActualExpenseCol.clear();
        infraAmountCol.clear();
        evChargersAmountCol.clear();
        totalApprovedJmrAmountCol.clear();
        totalPendingJmrAmountCol.clear();
        financialProgressCol.clear();
        pendingJmrApprovalCol.clear();
        assetCapitalisedTprelCol.clear();
        assetCapitalisedTpevslCol.clear();
        cumulativeAssetCapitalizedCol.clear();
        pendingAssetCapitalisationCol.clear();

        final List<int> bytes = result.files.single.bytes!;
        final excel = Excel.decodeBytes(bytes);
        var sheet1 = excel.tables.keys.elementAt(0);

        if (excel.tables[sheet1]!.maxCols != 20) {
          showCustomAlert();
        } else {
          isExcelSelected = true;
          for (var row in excel.tables[sheet1]!.rows.skip(2)) {
            projectNameCol.add(row[1]?.value.toString());
            plannedChargersCol.add(row[2]?.value.toString());
            chargersComissioned.add(row[3]?.value.toString());

            tprelBudgetCol.add(double.parse(row[4]?.value.toString() ?? "")
                .toStringAsFixed(2)
                .toString());
            tpevslBudgetCol.add(double.parse(row[5]?.value.toString() ?? "")
                .toStringAsFixed(2)
                .toString());
            budgetCol.add(double.parse(row[6]?.value.toString() ?? "")
                .toStringAsFixed(2)
                .toString());

            actualExpenseTprelCol.add(
                double.parse(row[7]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());
            actualExpenseTpevslCol.add(
                double.parse(row[8]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());
            totalActualExpenseCol.add(
                double.parse(row[9]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());

            infraAmountCol.add(double.parse(row[10]?.value.toString() ?? "")
                .toStringAsFixed(2)
                .toString());
            evChargersAmountCol.add(
                double.parse(row[11]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());
            totalApprovedJmrAmountCol.add(
                double.parse(row[12]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());

            totalPendingJmrAmountCol.add(
                double.parse(row[13]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());

            financialProgressCol.add(
                double.parse(row[14]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());

            pendingJmrApprovalCol.add(
                double.parse(row[15]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());

            assetCapitalisedTprelCol.add(
                double.parse(row[16]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());
            assetCapitalisedTpevslCol.add(
                double.parse(row[17]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());
            cumulativeAssetCapitalizedCol.add(
                double.parse(row[18]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());
            pendingAssetCapitalisationCol.add(
                double.parse(row[19]?.value.toString() ?? "")
                    .toStringAsFixed(2)
                    .toString());
          }

          tempList1.add(tprelBudgetCol);
          tempList1.add(tpevslBudgetCol);
          tempList1.add(budgetCol);

          tempList2.add(actualExpenseTprelCol);
          tempList2.add(actualExpenseTpevslCol);
          tempList2.add(totalActualExpenseCol);

          budgetActualCol.add(tempList1);
          budgetActualCol.add(tempList2);

          totalForAllCol = plannedChargersCol.length - 1;
          projectNameColLen = projectNameCol.length - 1;
          tprelBudgetColLen = tprelBudgetCol.length - 1;
          infraAmountColLen = infraAmountCol.length - 1;
          financialProgressLen = financialProgressCol.length - 1;
          assetCapitalisedTprelLen = assetCapitalisedTprelCol.length - 1;

          totalPlannedChargers =
              double.parse(plannedChargersCol[totalForAllCol]);
          totalChargersCommissioned =
              double.parse(chargersComissioned[totalForAllCol]);
          totalBalancedCharger =
              totalPlannedChargers - totalChargersCommissioned;

          evTotalList.add(totalPlannedChargers);
          evTotalList.add(totalChargersCommissioned);
          evTotalList.add(totalBalancedCharger);

          totalTprelBudget = double.parse(tprelBudgetCol[totalForAllCol]);
          totalTpevslBudget = double.parse(tpevslBudgetCol[totalForAllCol]);
          totalBudget = double.parse(budgetCol[totalForAllCol]);

          budgetTotalList.add(totalTprelBudget);
          budgetTotalList.add(totalTpevslBudget);
          budgetTotalList.add(totalBudget);

          totalActualExpenseTprel =
              double.parse(actualExpenseTprelCol[totalForAllCol]);
          totalActualExpenseTpevsl =
              double.parse(actualExpenseTpevslCol[totalForAllCol]);
          totalActualExpense =
              double.parse(totalActualExpenseCol[totalForAllCol]);

          actualTotalList.add(totalActualExpenseTprel);
          actualTotalList.add(totalActualExpenseTpevsl);
          actualTotalList.add(totalActualExpense);

          totalInfraAmount = double.parse(infraAmountCol[totalForAllCol]);
          totalEvChargerAmount =
              double.parse(evChargersAmountCol[totalForAllCol]);
          totalApprovedJmrAmount =
              double.parse(totalApprovedJmrAmountCol[totalForAllCol]);
          totalPendingJmrAmount =
              double.parse(totalPendingJmrAmountCol[totalForAllCol]);

          tmlTotalList.add(totalInfraAmount);
          tmlTotalList.add(totalEvChargerAmount);
          tmlTotalList.add(totalApprovedJmrAmount);
          tmlTotalList.add(totalPendingJmrAmount);

          totalFinancialProgress =
              double.parse(financialProgressCol[totalForAllCol]);
          totalPendingJmrPercent =
              double.parse(pendingJmrApprovalCol[totalForAllCol]);

          commercialTotalList.add(totalFinancialProgress);
          commercialTotalList.add(totalPendingJmrPercent);

          totalTprelAssetCapitalised =
              double.parse(assetCapitalisedTprelCol[totalForAllCol]);
          totalTpevslAssetCapitalised =
              double.parse(assetCapitalisedTpevslCol[totalForAllCol]);
          totalCumulativeAssetCapitalised =
              double.parse(cumulativeAssetCapitalizedCol[totalForAllCol]);
          totalPendingAssetCapitlization =
              double.parse(pendingAssetCapitalisationCol[totalForAllCol]);

          assetTotalList.add(totalTprelAssetCapitalised);
          assetTotalList.add(totalTpevslAssetCapitalised);
          assetTotalList.add(totalCumulativeAssetCapitalised);
          assetTotalList.add(totalPendingAssetCapitlization);

          budgetActualTotalList.add(budgetTotalList);
          budgetActualTotalList.add(actualTotalList);
        }
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
                content: const Text('No Excel File Selected'),
              );
            });
      }

      //Storing Excel Data into Firestore Database
      await storeExcel();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error decoding Excel file: $e');
      print(stackTrace);
      // Handle the error as needed
    }
  }

  Future<void> fetchExcelData() async {
    List<dynamic> tempList1 = [];
    List<dynamic> tempList2 = [];
    CollectionReference dashboardRef =
        FirebaseFirestore.instance.collection('dashboard');

//Fetching EV Table Data
    DocumentSnapshot evSnap = await dashboardRef.doc(tabNamesToStore[0]).get();
    Map<String, dynamic> evData = evSnap.data() as Map<String, dynamic>;
    List<dynamic> evList = evData['evData'];
    projectNameCol = evList[0]['projectName'];
    plannedChargersCol = evList[1]['plannedChargers'];
    chargersComissioned = evList[2]['chargersCommissioned'];

//Fetching Budget Table Data
    DocumentSnapshot budgetSnap =
        await dashboardRef.doc(tabNamesToStore[1]).get();
    Map<String, dynamic> budgetData = budgetSnap.data() as Map<String, dynamic>;
    List<dynamic> budgetList = budgetData['budgetData'];
    tprelBudgetCol = budgetList[0]['tprelBudget'];
    tpevslBudgetCol = budgetList[1]['tpevslBudget'];
    budgetCol = budgetList[2]['totalBudget'];

//Fetching Actual Expense Table Data
    DocumentSnapshot actualSnap =
        await dashboardRef.doc(tabNamesToStore[2]).get();
    Map<String, dynamic> actualData = actualSnap.data() as Map<String, dynamic>;
    List<dynamic> actualList = actualData['actualData'];
    actualExpenseTprelCol = actualList[0]['tprelActual'];
    actualExpenseTpevslCol = actualList[1]['tpevslActual'];
    totalActualExpenseCol = actualList[2]['totalActual'];

//Fetching TML Approved JMR Expense Table Data
    DocumentSnapshot tmlJmrSnap =
        await dashboardRef.doc(tabNamesToStore[3]).get();
    Map<String, dynamic> tmlJmrData = tmlJmrSnap.data() as Map<String, dynamic>;
    List<dynamic> tmlJmrList = tmlJmrData['tmlJmrData'];
    infraAmountCol = tmlJmrList[0]['infra'];
    evChargersAmountCol = tmlJmrList[1]['evChargers'];
    totalApprovedJmrAmountCol = tmlJmrList[2]['approvedJmr'];
    totalPendingJmrAmountCol = tmlJmrList[3]['pendingJmr'];

//Fetching Commercial Achievement Table Data
    DocumentSnapshot commercialSnap =
        await dashboardRef.doc(tabNamesToStore[4]).get();
    Map<String, dynamic> commercialData =
        commercialSnap.data() as Map<String, dynamic>;
    List<dynamic> commercialList = commercialData['commercialData'];
    financialProgressCol = commercialList[0]['financialProgress'];
    pendingJmrApprovalCol = commercialList[1]['pendingJmr'];

//Fetching Asset Capitalised Table Data
    DocumentSnapshot assetSnap =
        await dashboardRef.doc(tabNamesToStore[5]).get();
    Map<String, dynamic> assetData = assetSnap.data() as Map<String, dynamic>;
    List<dynamic> assetList = assetData['assetData'];
    assetCapitalisedTprelCol = assetList[0]['tprelAsset'];
    assetCapitalisedTpevslCol = assetList[1]['tpevslAsset'];
    cumulativeAssetCapitalizedCol = assetList[2]['cumulativeAsset'];
    pendingAssetCapitalisationCol = assetList[3]['pendingAsset'];

//If Row Length is not empty
    if (plannedChargersCol.isNotEmpty) {
      isExcelSelected = true;
      tempList1.add(tprelBudgetCol);
      tempList1.add(tpevslBudgetCol);
      tempList1.add(budgetCol);

      tempList2.add(actualExpenseTprelCol);
      tempList2.add(actualExpenseTpevslCol);
      tempList2.add(totalActualExpenseCol);

      budgetActualCol.add(tempList1);
      budgetActualCol.add(tempList2);

      totalForAllCol = plannedChargersCol.length - 1;
      projectNameColLen = projectNameCol.length - 1;
      tprelBudgetColLen = tprelBudgetCol.length - 1;
      infraAmountColLen = infraAmountCol.length - 1;
      financialProgressLen = financialProgressCol.length - 1;
      assetCapitalisedTprelLen = assetCapitalisedTprelCol.length - 1;

      totalPlannedChargers = double.parse(plannedChargersCol[totalForAllCol]);
      totalChargersCommissioned =
          double.parse(chargersComissioned[totalForAllCol]);
      totalBalancedCharger = totalPlannedChargers - totalChargersCommissioned;

      evTotalList.add(totalPlannedChargers);
      evTotalList.add(totalChargersCommissioned);
      evTotalList.add(totalBalancedCharger);

      totalTprelBudget = double.parse(tprelBudgetCol[totalForAllCol]);
      totalTpevslBudget = double.parse(tpevslBudgetCol[totalForAllCol]);
      totalBudget = double.parse(budgetCol[totalForAllCol]);

      budgetTotalList.add(totalTprelBudget);
      budgetTotalList.add(totalTpevslBudget);
      budgetTotalList.add(totalBudget);

      totalActualExpenseTprel =
          double.parse(actualExpenseTprelCol[totalForAllCol]);
      totalActualExpenseTpevsl =
          double.parse(actualExpenseTpevslCol[totalForAllCol]);
      totalActualExpense = double.parse(totalActualExpenseCol[totalForAllCol]);

      actualTotalList.add(totalActualExpenseTprel);
      actualTotalList.add(totalActualExpenseTpevsl);
      actualTotalList.add(totalActualExpense);

      totalInfraAmount = double.parse(infraAmountCol[totalForAllCol]);
      totalEvChargerAmount = double.parse(evChargersAmountCol[totalForAllCol]);
      totalApprovedJmrAmount =
          double.parse(totalApprovedJmrAmountCol[totalForAllCol]);
      totalPendingJmrAmount =
          double.parse(totalPendingJmrAmountCol[totalForAllCol]);

      tmlTotalList.add(totalInfraAmount);
      tmlTotalList.add(totalEvChargerAmount);
      tmlTotalList.add(totalApprovedJmrAmount);
      tmlTotalList.add(totalPendingJmrAmount);

      totalFinancialProgress =
          double.parse(financialProgressCol[totalForAllCol]);
      totalPendingJmrPercent =
          double.parse(pendingJmrApprovalCol[totalForAllCol]);

      commercialTotalList.add(totalFinancialProgress);
      commercialTotalList.add(totalPendingJmrPercent);

      totalTprelAssetCapitalised =
          double.parse(assetCapitalisedTprelCol[totalForAllCol]);
      totalTpevslAssetCapitalised =
          double.parse(assetCapitalisedTpevslCol[totalForAllCol]);
      totalCumulativeAssetCapitalised =
          double.parse(cumulativeAssetCapitalizedCol[totalForAllCol]);
      totalPendingAssetCapitlization =
          double.parse(pendingAssetCapitalisationCol[totalForAllCol]);

      assetTotalList.add(totalTprelAssetCapitalised);
      assetTotalList.add(totalTpevslAssetCapitalised);
      assetTotalList.add(totalCumulativeAssetCapitalised);
      assetTotalList.add(totalPendingAssetCapitlization);

      budgetActualTotalList.add(budgetTotalList);
      budgetActualTotalList.add(actualTotalList);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showCustomAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              height: 130,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 60,
                    color: blue,
                  ),
                  const Text(
                    'Excel Should Contain Only 20 Columns',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<String> getCityFromString(String sentence) async {
    String fetchedDepo = '';
    cityList.any((word) {
      bool containsWord = sentence.contains(word);
      if (sentence.contains('Bangalore')) {
        fetchedDepo = 'Bengaluru';
      } else if (sentence.contains('TML Dhadwad')) {
        fetchedDepo = 'TML Dharwad ';
      } else if (containsWord) {
        fetchedDepo = word;
      }
      print(fetchedDepo);

      return containsWord;
    });

    selectedCity = fetchedDepo;
    return fetchedDepo;
  }

  //Store Excel Data in Firebase
  Future<void> storeExcel() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('dashboard');

    //Storing EV Table Data
    await collectionReference.doc(tabNamesToStore[0]).set({
      'evData': [
        {
          "projectName": projectNameCol,
        },
        {"plannedChargers": plannedChargersCol},
        {"chargersCommissioned": chargersComissioned}
      ]
    });

    //Storing budget Table data
    await collectionReference.doc(tabNamesToStore[1]).set({
      'budgetData': [
        {"tprelBudget": tprelBudgetCol},
        {"tpevslBudget": tpevslBudgetCol},
        {"totalBudget": budgetCol}
      ]
    });

    //Storing actual Table Data
    await collectionReference.doc(tabNamesToStore[2]).set({
      'actualData': [
        {"tprelActual": actualExpenseTprelCol},
        {"tpevslActual": actualExpenseTpevslCol},
        {"totalActual": totalActualExpenseCol}
      ]
    });

    //Storing Tml Approved Table Data
    await collectionReference.doc(tabNamesToStore[3]).set({
      'tmlJmrData': [
        {"infra": infraAmountCol},
        {"evChargers": evChargersAmountCol},
        {"approvedJmr": totalApprovedJmrAmountCol},
        {"pendingJmr": totalPendingJmrAmountCol}
      ]
    });

    //Storing Commercial Table Data
    await collectionReference.doc(tabNamesToStore[4]).set({
      'commercialData': [
        {"financialProgress": financialProgressCol},
        {"pendingJmr": pendingJmrApprovalCol}
      ]
    });

    //Storing Asset Table Data
    await collectionReference.doc(tabNamesToStore[5]).set({
      'assetData': [
        {"tprelAsset": assetCapitalisedTprelCol},
        {"tpevslAsset": assetCapitalisedTpevslCol},
        {"cumulativeAsset": cumulativeAssetCapitalizedCol},
        {"pendingAsset": pendingAssetCapitalisationCol}
      ]
    });
  }

  void getCityName() async {
    QuerySnapshot cityListQuery =
        await FirebaseFirestore.instance.collection('DepoName').get();
    cityList = cityListQuery.docs.map((e) => e.id).toList();
  }

  String formatNumber(double number) {
    final format = NumberFormat.compact();
    return format.format(number);
  }

  String formatNum(double number) {
    String convertedNum = '';
    if (number == 0) {
      convertedNum = '0';
    } else if (number >= 100000 && number < 10000000) {
      dynamic num = number.round() / 100000;
      String roundedNum = double.parse(num.toString()).toStringAsFixed(1);

      convertedNum = '${roundedNum} Lakh';
    } else if (number > 10000000) {
      dynamic num = number.round() / 10000000;
      String roundedNum = double.parse(num.toString()).toStringAsFixed(1);
      convertedNum = '$roundedNum Cr';
    }
    return convertedNum;
  }

  Future<void> getRowsForFutureBuilder() async {
    estimatedEndDate.clear();
    actualEndDateList.clear();
    estimatedDateList.clear();
    startDateList.clear();
    endDateList.clear();
    List<dynamic> planningStartDate = [];
    List<dynamic> planningEndDate = [];
    List<dynamic> estimatedDate = [];
    List<dynamic> actualEndDate = [];

    bool isDateStored = false;
    depotProgressList.clear();
    setState(() {
      isTableLoading = true;
    });
    double totalperc = 0.0;

    for (int i = 0; i < selectedDepoList.length; i++) {
      planningStartDate.clear();
      planningEndDate.clear();
      estimatedDate.clear();
      actualEndDate.clear();
      isDateStored = false;
      totalperc = 0.0;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('KeyEventsTable')
          .doc(selectedDepoList[i])
          .collection('KeyDataTable')
          .get();

      List<dynamic> userIdList = querySnapshot.docs.map((e) => e.id).toList();
      for (int j = 0; j < userIdList.length; j++) {
        print('Point1');

        await FirebaseFirestore.instance
            .collection('KeyEventsTable')
            .doc(selectedDepoList[i])
            .collection('KeyDataTable')
            .doc(userIdList[j])
            .collection('KeyAllEvents')
            .get()
            .then((value) {
          print('Point2');

          value.docs.forEach((element) {
            var alldata = element.data()['data'];
            List<int> indicesToSkip = [0, 2, 6, 13, 18, 28, 32, 38, 64, 76];
            totalperc = 0.0;
            for (int k = 0; k < alldata.length; k++) {
              if (!isDateStored) {
                planningStartDate.add(alldata[k]['StartDate']);
                planningEndDate.add(alldata[k]['EndDate']);
                estimatedDate.add(alldata[k]['ActualStart']);
                actualEndDate.add(alldata[k]['ActualEnd']);
              }

              // print('skipe${indicesToSkip.contains(k)}');
              if (indicesToSkip.contains(k)) {
                print('Point3');

                num qtyExecuted = alldata[k]['QtyExecuted'];

                num weightage = alldata[k]['Weightage'];
                print('Point3.1');

                num scope = alldata[k]['QtyScope'];
                print('Point3.2');

                dynamic perc = ((qtyExecuted / scope) * weightage);
                num value = perc ?? 0.0;
                totalperc = totalperc + value.toDouble();
                print('Point4');

                // print(totalperc.toStringAsFixed(2));
              }
            }
          });
        });
      }

      if (userIdList.length > 1) {
        depotProgress = totalperc / userIdList.length;
        depotProgressList.add(depotProgress);
        // print('Average - $depotProgress');
      } else if (totalperc > 0) {
        depotProgressList.add(totalperc);
        // print('totalperc${selectedDepoList[i]}-${totalperc}');
      } else {
        depotProgressList.add(0);
      }

      if (planningStartDate.isNotEmpty) {
        planningStartDate.sort();
        startDateList.add(planningStartDate.first);
      } else {
        startDateList.add('00-00-0000');
      }

      if (planningEndDate.isNotEmpty) {
        planningEndDate.sort();
        endDateList.add(planningEndDate.last);
      } else {
        endDateList.add('00-00-0000');
      }

      if (estimatedDate.isNotEmpty) {
        estimatedDate.sort();
        estimatedDateList.add(estimatedDate.first);
      } else {
        estimatedDateList.add('00-00-0000');
      }

      if (actualEndDate.isNotEmpty) {
        actualEndDate.sort();
        actualEndDateList.add(actualEndDate.last);
      } else {
        actualEndDateList.add('00-00-0000');
      }

      if (userIdList.isNotEmpty) {
        //Fetching Estimated End Date
        DocumentSnapshot estDateSnap = await FirebaseFirestore.instance
            .collection('KeyEventsTable')
            .doc(selectedDepoList[i])
            .collection('KeyDataTable')
            .doc(userIdList[0])
            .collection('ClosureDates')
            .doc('keyEvents')
            .get();

        if (estDateSnap.exists) {
          Map<String, dynamic> estDateData =
              estDateSnap.data() as Map<String, dynamic>;

          estimatedEndDate.add(estDateData['ClosureDate']);
        } else {
          estimatedEndDate.add('W.I.P');
        }

        // Map<String, dynamic> estDateMap =
        //     estDateSnap.data() as Map<String, dynamic>;
      } else {
        estimatedEndDate.add('W.I.P');
      }
    }

    setState(() {
      isTableLoading = false;
    });
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms = [
    'Apple',
    'Banana',
    'Pear',
    'Watermelons',
    'Oranges',
    'BlueBerries',
    'Strawberries',
    'Raspberries',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchedList = [];
    for (var fruit in cityList) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchedList.add(fruit);
      }
    }
    return ListView.builder(
        itemCount: matchedList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: ListTile(
              title: Text(matchedList[index]),
            ),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchedList = [];
    for (var fruit in cityList) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchedList.add(fruit);
      }
    }
    return ListView.builder(
        itemCount: matchedList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: ListTile(
              title: Text(matchedList[index]),
            ),
          );
        });
  }
}

enum DrawerSection { evDashboard, oandmDashboard, cities, users }
