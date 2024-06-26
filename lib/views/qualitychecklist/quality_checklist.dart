import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../style.dart';
import '../../PMIS/summary.dart';

class QualityChecklist extends StatefulWidget {
  String? userId;
  String? cityName;
  String? depoName;
  String? currentDate;
  bool? isHeader;

  QualityChecklist(
      {super.key,
      this.userId,
      required this.cityName,
      required this.depoName,
      this.currentDate,
      this.isHeader = true});

  @override
  State<QualityChecklist> createState() => _QualityChecklistState();
}

TextEditingController ename = TextEditingController();
dynamic empName,
    distev,
    vendorname,
    date,
    olano,
    panel,
    serialno,
    depotname,
    customername;

dynamic alldata;
int? _selectedIndex = 0;

List<String> title = [
  'CHECKLIST FOR INSTALLATION OF PSS',
  'CHECKLIST FOR INSTALLATION OF RMU',
  'CHECKLIST FOR INSTALLATION OF  COVENTIONAL TRANSFORMER',
  'CHECKLIST FOR INSTALLATION OF CTPT METERING UNIT',
  'CHECKLIST FOR INSTALLATION OF ACDB',
  'CHECKLIST FOR  CABLE INSTALLATION ',
  'CHECKLIST FOR  CABLE DRUM / ROLL INSPECTION',
  'CHECKLIST FOR MCCB PANEL',
  'CHECKLIST FOR CHARGER PANEL',
  'CHECKLIST FOR INSTALLATION OF  EARTH PIT',
];
// ignore: non_constant_identifier_names
List<String> civil_title = [
  'CHECKLIST FOR INSTALLATION OF EXCAVATION WORK',
  'CHECKLIST FOR INSTALLATION OF EARTH WORK - BACKFILLING',
  'CHECKLIST FOR INSTALLATION OF BRICK & BLOCK MASSONARY',
  'CHECKLIST FOR INSTALLATION OF BLDG DOORS, WINDOWS, HARDWARE, GLAZING',
  'CHECKLIST FOR INSTALLATION OF FALSE CEILING',
  'CHECKLIST FOR FLOORING & TILING',
  'CHECKLIST FOR GROUT INSPECTION',
  'CHECKLIST FOR INRONITE FLOORING CHECK',
  'CHECKLIST FOR PAINTING',
  'CHECKLIST FOR PAVING WORK',
  'CHECKLIST FOR WALL CLADDING & ROOFING',
  'CHECKLIST FOR WALL WATER PROOFING',
];

// Main
class _QualityChecklistState extends State<QualityChecklist> {
  @override
  void initState() {
    // getUserId().whenComplete(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.currentDate =
        widget.currentDate ?? DateFormat.yMMMMd().format(DateTime.now());

    // _isloading = false;
    // _stream = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('PSS TABLE DATA')
    //     .doc('PSS')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream1 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('RMU TABLE DATA')
    //     .doc('RMU')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream2 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('CONVENTIONAL TRANSFORMER TABLE DATA')
    //     .doc('CONVENTIONAL TRANSFORMER')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream3 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('CTPT METERING UNIT TABLE DATA')
    //     .doc('CTPT METERING UNIT')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream4 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('ACDB TABLE DATA')
    //     .doc('ACDB DATA')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream5 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('CABLE INSTALLATION TABLE DATA')
    //     .doc('CABLE INSTALLATION')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream6 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('CDI TABLE DATA')
    //     .doc('CDI DATA')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream7 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('MSP TABLE DATA')
    //     .doc('MSP DATA')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream8 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('CHARGER TABLE DATA')
    //     .doc('CHARGER DATA')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // _stream9 = FirebaseFirestore.instance
    //     .collection('QualityChecklist')
    //     .doc('${widget.depoName}')
    //     .collection('EARTH TABLE DATA')
    //     .doc('EARTH DATA')
    //     .collection(userId)
    //     .doc(widget.currentDate)
    //     .snapshots();

    // qualitylisttable1 = getData();
    // _qualityExcavationDataSource =QualityExcavationDataSource(qualitylisttable1);
    // _dataGridController = DataGridController();

    // qualitylisttable2 = getData();
    // _qualityBackFillingDataSource = QualityBackFillingDataSource(qualitylisttable2);
    // _dataGridController = DataGridController();

    // qualitylisttable3 = getData();
    // _qualityMassonaryDataSource = QualityMassonaryDataSource(qualitylisttable2);
    // _dataGridController = DataGridController();

    // qualitylisttable4 = getData();
    // _qualityGlazzingDataSource = QualityGlazzingDataSource(qualitylisttable4);
    // _dataGridController = DataGridController();

    // qualitylisttable5 = getData();
    // _qualityCeillingDataSource= = QualityCeillingDataSource(qualitylisttable5);
    // _dataGridController = DataGridController();

    // qualitylisttable6 = getData();
    // _QualityflooringDataSource = QualityflooringDataSource(qualitylisttable6);
    // _dataGridController = DataGridController();

    // qualitylisttable7 = getData();
    // _qualityInspectionDataSource = QualityInspectionDataSource(qualitylisttable7);
    // _dataGridController = DataGridController();

    // qualitylisttable8 = getData();
    // _qualityIroniteflooringDataSource = QualityIroniteflooringDataSource(qualitylisttable8);
    // _dataGridController = DataGridController();

    // qualitylisttable9 = getData();
    // _qualityPaintingDataSource = QualityPaintingDataSource(qualitylisttable9);
    // _dataGridController = DataGridController();

    // qualitylisttable10 = getData();
    //_qualityPavingDataSource = QualityPavingDataSource(qualitylisttable10);
    // _dataGridController = DataGridController();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              automaticallyImplyLeading:
                  widget.isHeader! ? widget.isHeader! : false,
              backgroundColor: blue,
              title: widget.isHeader!
                  ? Text(
                      '${widget.cityName}/${widget.depoName}/Quality Checklist',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  : const Text(''),

              actions: [
                widget.isHeader!
                    ? Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 40, top: 10, bottom: 10),
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue),
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewSummary(
                                            depoName: widget.depoName,
                                            cityName: widget.cityName,
                                            id: 'Quality Checklist',
                                            selectedtab:
                                                _selectedIndex.toString(),
                                            isHeader: false,
                                          ),
                                        ));
                                  },
                                  child: Text(
                                    'View Summary',
                                    style:
                                        TextStyle(color: white, fontSize: 20),
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 20, top: 10, bottom: 10),
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: lightblue),
                              child: TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection(
                                            'QualityChecklistCollection')
                                        .doc('${widget.depoName}')
                                        .collection('ChecklistData')
                                        .doc(widget.currentDate)
                                        .set({
                                      'EmployeeName':
                                          empName ?? 'Enter Employee Name',
                                      'Dist EV': distev ?? 'Enter Dist EV',
                                      'VendorName':
                                          vendorname ?? 'Enter Vendor Name',
                                      'Date': date ?? 'Enter Date',
                                      'OlaNo': olano ?? 'Enter Ola No',
                                      'PanelNo': panel ?? 'Enter Panel',
                                      'DepotName':
                                          depotname ?? 'Enter depot Name Name',
                                      'CustomerName':
                                          customername ?? 'Enter Customer Name'
                                    });
                                    // _selectedIndex == 0
                                    //     ? CivilstoreData(
                                    //         context,
                                    //         widget.depoName!,
                                    //         widget.currentDate!)
                                    //     : storeData(context, widget.depoName!,
                                    //         widget.currentDate!);
                                  },
                                  child: Text(
                                    'Sync Data',
                                    style:
                                        TextStyle(color: white, fontSize: 20),
                                  )),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(right: 150),
                              child: GestureDetector(
                                  onTap: () {
                                    // onWillPop(context);
                                  },
                                  child: Image.asset(
                                    'assets/logout.png',
                                    height: 20,
                                    width: 20,
                                  )))
                        ],
                      )
                    : Container(),
              ],
              // leading:
              bottom: PreferredSize(
                preferredSize: const Size(double.infinity, 50),
                child: Column(
                  children: [
                    TabBar(
                      labelColor: white,
                      labelStyle: buttonWhite,
                      unselectedLabelColor: Colors.black,
                      indicator: MaterialIndicator(
                          horizontalPadding: 24,
                          bottomLeftRadius: 8,
                          bottomRightRadius: 8,
                          color: white,
                          paintingStyle: PaintingStyle.fill),
                      tabs: const [
                        Tab(text: 'Civil Engineer'),
                        Tab(text: 'Electrical Engineer'),
                      ],
                      onTap: (value) {
                        _selectedIndex = value;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: const TabBarView(children: [
              // CivilQualityChecklist(
              //     cityName: widget.cityName, depoName: widget.depoName),
              // ElectricalQualityChecklist(
              //     cityName: widget.cityName,
              //     depoName: widget.depoName,
              //     userId: userId)
            ]),
          )),
    );
  }

  // Future<void> getUserId() async {
  //   await AuthService().getCurrentUserId().then((value) {
  //     userId = value;
  //   });
  // }
}
