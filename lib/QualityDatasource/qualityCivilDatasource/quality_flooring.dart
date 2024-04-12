import 'package:collection/collection.dart';
import 'package:ev_pmis_app/views/citiespage/depot.dart';
import 'package:ev_pmis_app/views/overviewpage/view_AllFiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../style.dart';
import '../../models/quality_checklistModel.dart';
import '../../widgets/upload.dart';

class QualityflooringDataSource extends DataGridSource {
  // BuildContext mainContext;
  String cityName;
  String depoName;
  QualityflooringDataSource(
      this._checklistModel, this.cityName, this.depoName) {
    buildDataGridRows();
  }
  void buildDataGridRows() {
    dataGridRows = _checklistModel
        .map<DataGridRow>((dataGridRow) => dataGridRow.getDataGridRow())
        .toList();
  }

  @override
  List<QualitychecklistModel> _checklistModel = [];

  List<DataGridRow> dataGridRows = [];
  final _dateFormatter = DateFormat.yMd();

  /// [DataGridCell] on [onSubmitCell] method.
  dynamic newCellValue;

  /// Help to control the editable text in [TextField] widget.
  TextEditingController editingController = TextEditingController();
  final DateRangePickerController _controller = DateRangePickerController();

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    DateTime? rangeStartDate = DateTime.now();
    DateTime? rangeEndDate = DateTime.now();
    DateTime? date;
    DateTime? endDate;
    DateTime? rangeStartDate1 = DateTime.now();
    DateTime? rangeEndDate1 = DateTime.now();
    DateTime? date1;
    DateTime? endDate1;
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment:

              Alignment.center,
          // : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: dataGridCell.columnName == 'Upload'
              ? LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    width: 50,
                    child: ElevatedButton(
                        style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(EdgeInsets.zero)
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UploadDocument(
                              title: 'QualityChecklist',
                              subtitle: 'civil_Engineer',
                              cityName: cityName,
                              depoName: depoName,
                              userId: userId,
                              fldrName: 'Flooring Table',
                              date: currentDate,
                              srNo: row.getCells()[0].value,
                            ),
                          ));
                        },
                        child: Text(
                          'Upload',
                          style:uploadViewStyle
                        )),
                  );
                })
              : dataGridCell.columnName == 'View'
                  ? LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                      return SizedBox(width: 50,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(EdgeInsets.zero)
                        ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ViewAllPdf(
                                  title: 'QualityChecklist',
                                  subtitle: 'civil_Engineer',
                                  cityName: cityName,
                                  depoName: depoName,
                                  userId: userId,
                                  fldrName: 'Flooring Table',
                                  date: currentDate,
                                  srNo: row.getCells()[0].value,
                                ),
                              ));
                            },
                            child: Text(
                              'View',
                              style:uploadViewStyle
                            )),
                      );
                    })

                 
                  : Text(
                      dataGridCell.value.toString(),
                      style: tablefontsize,
                    ));
    }).toList());
  }

  void updateDatagridSource() {
    notifyListeners();
  }

  void updateDataGrid({required RowColumnIndex rowColumnIndex}) {
    notifyDataSourceListeners(rowColumnIndex: rowColumnIndex);
  }

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value ??
        '';

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }
    if (column.columnName == 'srNo') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'srNo', value: newCellValue);
      _checklistModel[dataRowIndex].srNo = newCellValue as int;
    } else if (column.columnName == 'checklist') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'checklist', value: newCellValue);
      _checklistModel[dataRowIndex].checklist = newCellValue.toString();
    } else if (column.columnName == 'responsibility') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(
              columnName: 'responsibility', value: newCellValue);
      _checklistModel[dataRowIndex].responsibility = newCellValue.toString();
    } else if (column.columnName == 'Reference') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<dynamic>(columnName: 'Reference', value: newCellValue);
      _checklistModel[dataRowIndex].reference = newCellValue;
    } else {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'observation', value: newCellValue);
      _checklistModel[dataRowIndex].observation = newCellValue;
    }
  }

  @override
  bool canSubmitCell(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    // Return false, to retain in edit mode.
    return true; // or super.canSubmitCell(dataGridRow, rowColumnIndex, column);
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value
            ?.toString() ??
        '';

    newCellValue = '';

    final bool isNumericType = column.columnName == 'srNo' ||
        column.columnName == 'Rate' ||
        column.columnName == 'TotalQty' ||
        column.columnName == 'TotalAmount' ||
        column.columnName == 'RefNo';

    final bool isDateTimeType = column.columnName == 'StartDate' ||
        column.columnName == 'EndDate' ||
        column.columnName == 'ActualStart' ||
        column.columnName == 'ActualEnd';
    // Holds regular expression pattern based on the column type.
    final RegExp regExp =
        _getRegExp(isNumericType, isDateTimeType, column.columnName);

    return Container(
      alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        style: tablefontsize,
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: isNumericType ? TextAlign.right : TextAlign.left,
        autocorrect: false,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(regExp),
        ],
         decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(
            5.0,
          ),
        ),
        keyboardType: isNumericType
            ? TextInputType.number
            : isDateTimeType
                ? TextInputType.datetime
                : TextInputType.text,
        onTapOutside: (event) {
          newCellValue = editingController.text;
        },
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType) {
              newCellValue = int.parse(value);
            } else if (isDateTimeType) {
              newCellValue = value;
            } else {
              newCellValue = value;
            }
          }
        },
        onSubmitted: (String value) {
          /// Call [CellSubmit] callback to fire the canSubmitCell and
          /// onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  RegExp _getRegExp(
      bool isNumericKeyBoard, bool isDateTimeBoard, String columnName) {
    return isNumericKeyBoard
        ? RegExp('[0-9]')
        : isDateTimeBoard
            ? RegExp('[0-9/]')
            : RegExp('[a-zA-Z0-9.@!#^&*(){+-}%|<>?_=+,/ )]');
  }
}
