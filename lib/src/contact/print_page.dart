// import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:help_app/src/contact/settings_page.dart';
import 'package:help_app/src/contact/view_page.dart';
import 'package:help_app/src/home/home_bloc.dart';
import 'package:help_app/src/home/home_module.dart';
import 'package:help_app/src/shared/repository/contact_repository.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:numeral/numeral.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:dart_date/dart_date.dart';

// import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:permission_handler/permission_handler.dart';
// import 'package:open_file/open_file.dart';

import '../app_module.dart';

class Assisstent {
  int id;
  String name;
  String startDate;
  String endDate;
  String nationalId;
  String helpType;
  String helpAmount;
  String helpDuration;
  String phoneNumber;
  var viewContactId;

  Assisstent(
      {this.id,
      this.name,
      this.startDate,
      this.endDate,
      this.nationalId,
      this.helpType,
      this.helpAmount,
      this.helpDuration,
      this.phoneNumber,
      this.viewContactId});
}

class PrintPage extends StatefulWidget {
  const PrintPage({Key key}) : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  HomeBloc bloc;

  ContactRepository contactRepository;
  bool permissionGranted;

  var rangeOfDates;
  List foundedDates = [];
  List foundedContactsDates = [];
  List<Assisstent> _assisstents = [];
  // List<DataRow> dataRows = [];
  List<DataColumn> myColumns = [];
  bool showNationalIdDataCell = false;
  bool show = false;

  bool _sortNameAsc = true;
  bool _sortStartDateAsc = true;
  bool _sortEndDateAsc = true;
  bool _sortTypeAsc = true;

  bool _sortAmountAsc = true;
  bool _sortDurationAsc = true;
  bool _sortAsc = true;
  int _sortColumnIndex;

  openDBList() async {
    Database db = await contactRepository.getDb();
    List<Map> items = await db.rawQuery(
        'SELECT id, name, helpAmount, helpDate, nationalId, helpType, helpDuration, phoneNumber FROM contacts');

    List<Map> contactItems = await db.rawQuery('SELECT * FROM contacts');

    print(items);
    List myListOfDates = [];
    List myListOfContactMaps = [];

    for (var i = 0; i < items.length; i++) {
      var id = items[i].values.elementAt(0).toString().trim();
      var name = items[i].values.elementAt(1).toString().trim();
      var helpAmount = items[i].values.elementAt(2).toString().trim();
      var splitedDate =
          items[i].values.elementAt(3).toString().trim().split("-");
      var nationalId =
          items[i].values.elementAt(4).toString().trim().split("-");
      var helpType = items[i].values.elementAt(5).toString().trim().split("-");
      var helpDuration =
          items[i].values.elementAt(6).toString().trim().split("-");
      var phoneNumber =
          items[i].values.elementAt(7).toString().trim().split("-");

      var startDate = splitedDate[0]
          .trim()
          .split("/")
          .reversed
          .join("/")
          .trim()
          .replaceAll("/", "-");
      var endDate = splitedDate[1]
          .trim()
          .split("/")
          .reversed
          .join("/")
          .trim()
          .replaceAll("/", "-");

      print(name);
      print(myListOfDates);
      // var fullNameSeprated = titleName.trim().split(" ");

      // var lastName = fullNameSeprated.last == "" ||
      //         fullNameSeprated.last.trim() == null ||
      //         fullNameSeprated.last.trim().isEmpty
      //     ? null
      //     : fullNameSeprated.last.trim();

      // var firstName = fullNameSeprated.first.trim() == "" ||
      //         fullNameSeprated.first.trim() == null ||
      //         fullNameSeprated.first.trim().isEmpty
      //     ? null
      //     : fullNameSeprated.first;

      myListOfDates.add(
          "$startDate - $endDate - $name - $helpAmount - $id - ${nationalId[0]} - ${helpType[0]} - ${helpDuration[0]} - ${phoneNumber[0]}");
      myListOfContactMaps.add(contactItems[i]);
    }

    return [myListOfDates, myListOfContactMaps];
  }

  getDatesBetweenRange(DateTime firstInputDate, DateTime secondInputDate,
      List listOfDates, List listOfContacts) {
    var inputstartDate = _chelpDateController.selectedRange != null
        ? _chelpDateController.selectedRange.startDate
        : DateTime.now();
    var inputendDate = _chelpDateController.selectedRange != null
        ? _chelpDateController.selectedRange.endDate
        : DateTime.now().add(Duration(days: 10));

    for (var i = 0; i < listOfDates.length; i++) {
      var firstDate = DateTime.parse(listOfDates[i].split(" - ")[0]);
      var secondDate = DateTime.parse(listOfDates[i].split(" - ")[1]);
      if (firstDate.isSameOrAfter(inputstartDate)) {
        if (secondDate.isSameOrBefore(inputendDate)) {
          foundedDates.add(listOfDates[i]);
          foundedContactsDates.add(listOfContacts[i]);
        }
      }
    }

    _assisstents = [];
    for (var i = 0; i < foundedDates.length; i++) {
      _assisstents.add(Assisstent(
          id: int.parse(foundedDates[i].split(" - ")[4]),
          name: foundedDates[i].split(" - ")[2],
          startDate: foundedDates[i].split(" - ")[0],
          endDate: foundedDates[i].split(" - ")[1],
          nationalId: foundedDates[i].split(" - ")[5],
          helpType: foundedDates[i].split(" - ")[6],
          helpAmount: foundedDates[i].split(" - ")[3] != 0
              ? foundedDates[i].split(" - ")[3]
              : "0",
          helpDuration: foundedDates[i].split(" - ")[7],
          phoneNumber: foundedDates[i].split(" - ")[8],
          viewContactId: foundedContactsDates[i]));

      myColumns = <DataColumn>[
        DataColumn(
          label: Text('الأسم'),
          onSort: (columnIndex, sortAscending) {
            setState(() {
              if (columnIndex == _sortColumnIndex) {
                _sortAsc = _sortNameAsc = sortAscending;
              } else {
                _sortColumnIndex = columnIndex;
                _sortAsc = _sortNameAsc;
              }
              _assisstents.sort((a, b) => a.name.compareTo(b.name));
              if (!_sortAsc) {
                _assisstents = _assisstents.reversed.toList();
              }
            });
          },
        ),
        DataColumn(
            label: Text('تاريخ البداية'),
            onSort: (columnIndex, sortAscending) {
              setState(() {
                if (columnIndex == _sortColumnIndex) {
                  _sortAsc = _sortStartDateAsc = sortAscending;
                } else {
                  _sortColumnIndex = columnIndex;
                  _sortAsc = _sortStartDateAsc;
                }
                _assisstents.sort((a, b) => a.startDate.compareTo(b.startDate));
                if (!_sortAsc) {
                  _assisstents = _assisstents.reversed.toList();
                }
              });
            }),
        DataColumn(
            label: Text('تاريخ النهاية'),
            onSort: (columnIndex, sortAscending) {
              setState(() {
                if (columnIndex == _sortColumnIndex) {
                  _sortAsc = _sortEndDateAsc = sortAscending;
                } else {
                  _sortColumnIndex = columnIndex;
                  _sortAsc = _sortEndDateAsc;
                }
                _assisstents.sort((a, b) => a.endDate.compareTo(b.endDate));
                if (!_sortAsc) {
                  _assisstents = _assisstents.reversed.toList();
                }
              });
            }),
        DataColumn(
          label: Text(
            'رقم الهوية',
          ),
        ),
        DataColumn(
          label: Text('النوع'),
          onSort: (columnIndex, sortAscending) {
            setState(() {
              if (columnIndex == _sortColumnIndex) {
                _sortAsc = _sortTypeAsc = sortAscending;
              } else {
                _sortColumnIndex = columnIndex;
                _sortAsc = _sortTypeAsc;
              }
              _assisstents.sort((a, b) => a.helpType.compareTo(b.helpType));
              if (!_sortAsc) {
                _assisstents = _assisstents.reversed.toList();
              }
            });
          },
        ),
        DataColumn(
          label: Text('المقدار'),
          onSort: (columnIndex, sortAscending) {
            setState(() {
              if (columnIndex == _sortColumnIndex) {
                _sortAsc = _sortAmountAsc = sortAscending;
              } else {
                _sortColumnIndex = columnIndex;
                _sortAsc = _sortAmountAsc;
              }
              _assisstents.sort((a, b) {
                print(a.helpAmount);
                print(b.helpAmount);
                return int.parse(a.helpAmount)
                    .compareTo(int.parse(b.helpAmount));
              });

              if (!_sortAsc) {
                _assisstents = _assisstents.reversed.toList();
              }
            });
          },
        ),
        DataColumn(
          label: Text('المدة'),
          onSort: (columnIndex, sortAscending) {
            setState(() {
              if (columnIndex == _sortColumnIndex) {
                _sortAsc = _sortDurationAsc = sortAscending;
              } else {
                _sortColumnIndex = columnIndex;
                _sortAsc = _sortDurationAsc;
              }
              _assisstents
                  .sort((a, b) => a.helpDuration.compareTo(b.helpDuration));
              if (!_sortAsc) {
                _assisstents = _assisstents.reversed.toList();
              }
            });
          },
        ),
        DataColumn(
          label: Text(
            'رقم الهاتف',
          ),
        ),
        DataColumn(
          label: Text(
            'عرض',
          ),
        ),
      ];
    }
  }

  var contactsList;

  void initState() {
    contactRepository = AppModule.to.getDependency<ContactRepository>();
    bloc = HomeModule.to.getBloc<HomeBloc>();

    super.initState();
    asyncMethod();
  }

  void asyncMethod() async {
    var list = await openDBList();
    setState(() {
      rangeOfDates = list[0];
      contactsList = list[1];
    });
  }

  var _chelpDateController = DateRangePickerController();
  var selectedDateRange;
  var selectedHijriDateRange;

  @override
  Widget build(BuildContext context) {
    var myRows = _assisstents.map((person) {
      return DataRow(cells: [
        DataCell(Text(person.name)),
        DataCell(Text('${person.startDate}')),
        DataCell(Text('${person.endDate}')),
        DataCell(Text('${person.nationalId}')),
        DataCell(Text('${person.helpType}')),
        DataCell(Text(
            '\u202B${Numeral(int.parse(person.helpAmount)).value().replaceAll('K', ' ألف').replaceAll('M', ' مليون').replaceAll('B', ' مليار').replaceAll('T', ' ترليون ')}\u202C')),
        DataCell(Text('${person.helpDuration}')),
        DataCell(Text('${person.phoneNumber}')),
        DataCell(IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () {
              bloc.setContact(person.viewContactId);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ViewPage()));
            })),
      ]);
    });

    final mySettings = Provider.of<MySettings>(context);

    return Directionality(
      textDirection:
          mySettings.leftToRight ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("طباعة"),
          leading: IconButton(
              icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ),
        body: ListView(
          children: [
            Center(child: Text("فترة المساعدات")),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                    ),
                    icon: Icon(Icons.date_range),
                    label: Text("اختر المدة"),
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return Dialog(
                              child: SizedBox(
                                width: 700,
                                height: 400,
                                child: SfDateRangePicker(
                                  backgroundColor: Colors.white,
                                  controller: _chelpDateController,
                                  view: DateRangePickerView.month,
                                  monthViewSettings:
                                      DateRangePickerMonthViewSettings(
                                          firstDayOfWeek: 6,
                                          viewHeaderStyle:
                                              DateRangePickerViewHeaderStyle(
                                                  backgroundColor:
                                                      Colors.grey[350])),
                                  headerStyle: DateRangePickerHeaderStyle(
                                      backgroundColor: Colors.grey[300],
                                      textStyle: TextStyle(
                                          color: Colors.black, fontSize: 30)),
                                  navigationDirection:
                                      DateRangePickerNavigationDirection
                                          .vertical,
                                  navigationMode:
                                      DateRangePickerNavigationMode.scroll,
                                  selectionMode: DateRangePickerSelectionMode
                                      .extendableRange,
                                  showActionButtons: true,
                                  confirmText: "حفظ",
                                  cancelText: "إلغاء",
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                  onSubmit: (value) {
                                    setState(() {
                                      selectedDateRange =
                                          "${intl.DateFormat('dd-MM-yyyy').format(_chelpDateController.selectedRange.endDate)} - ${intl.DateFormat('dd-MM-yyyy').format(_chelpDateController.selectedRange.startDate)}";
                                      foundedDates = [];
                                      List helpDateArray =
                                          selectedDateRange.split(" - ");
                                      print(helpDateArray);

                                      var storedStartDate =
                                          helpDateArray[0].split("-");
                                      print(storedStartDate);
                                      var storedStartDay =
                                          int.parse(storedStartDate[0]);
                                      var storedStartMonth =
                                          int.parse(storedStartDate[1]);
                                      var storedStartYear =
                                          int.parse(storedStartDate[2]);

                                      var storedEndDate =
                                          helpDateArray[1].split("-");
                                      var storedEndDay =
                                          int.parse(storedEndDate[0]);
                                      var storedEndMonth =
                                          int.parse(storedEndDate[1]);
                                      var storedEndYear =
                                          int.parse(storedEndDate[2]);

                                      var hijriStartDate =
                                          HijriCalendar.fromDate(DateTime(
                                                  storedStartYear,
                                                  storedStartMonth,
                                                  storedStartDay))
                                              .toFormat("yyyy-mm-dd");

                                      var hijriEndDate = HijriCalendar.fromDate(
                                              DateTime(storedEndYear,
                                                  storedEndMonth, storedEndDay))
                                          .toFormat("dd-mm-yyyy");

                                      selectedHijriDateRange =
                                          "$hijriStartDate - $hijriEndDate";
                                    });

                                    getDatesBetweenRange(
                                        _chelpDateController
                                            .selectedRange.startDate,
                                        _chelpDateController
                                            .selectedRange.endDate,
                                        rangeOfDates,
                                        contactsList);

                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          });
                    }),
                SizedBox(width: 30),
                IconButton(
                    onPressed: () async {
                      Future _getStoragePermission() async {
                        if (await Permission.storage.request().isGranted) {
                          setState(() {
                            permissionGranted = true;
                          });
                        } else if (await Permission.storage
                            .request()
                            .isPermanentlyDenied) {
                          await openAppSettings();
                        } else if (await Permission.storage
                            .request()
                            .isDenied) {
                          setState(() {
                            permissionGranted = false;
                          });
                        }
                      }

                      Future<Uint8List> _generatePdf(String title) async {
                        final pdf = pw.Document();

                        var list1 = [];
                        for (int i = 0; i < foundedDates.length; i++) {
                          list1.add("<tr>");
                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[8] +
                              "</th>");
                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[7] +
                              "</th>");

                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[3] +
                              "</th>");
                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[6] +
                              "</th>");
                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[5] +
                              "</th>");
                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[1] +
                              "</th>");
                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[0] +
                              "</th>");

                          list1.add("<th>" +
                              foundedDates[i].split(" - ")[2] +
                              "</th>");

                          list1.add("</tr>");
                        }

                        await Printing.layoutPdf(
                            onLayout: (PdfPageFormat format) async =>
                                await Printing.convertHtml(
                                  format: format,
                                  html: '''<!DOCTYPE html>
    <html>
    <head>
      <style>
      table, th, td {
      border: 1px solid black;
      border-collapse: collapse;
      }
      table {
      width: 100%
      }
    
      th, td, p, h3 {
      padding: 5px;
      text-align: center;
      }
      </style>
    </head>
      <body>
      <h1 style="text-align:center">فترة المساعدات</h1>
      <h3 style="text-align:center">\u202C${intl.DateFormat('yyyy-MM-dd').format(_chelpDateController.selectedRange.endDate)} فترة من ${intl.DateFormat('dd-MM-yyyy').format(_chelpDateController.selectedRange.startDate)} الى \u202B</h3>
      <h5></h5>
      <h3 style="text-align:center">\u202C${selectedHijriDateRange.split(' - ')[0]} فترة من ${selectedHijriDateRange.split(' - ')[1]} الى \u202B</h3>
      <table>
        <tr>
        <th><em>رقم الهاتف</em></th>

        <th><em>المدة</em></th>
          <th><em>المقدار</em></th>
          <th><em>النوع</em></th>
          <th><em>رقم الهوية</em></th>
          <th><em>تاريخ النهاية</em></th>
          <th><em>تاريخ البداية</em></th>
          <th><em>الأسم</em></th>
        </tr>
        ${list1.join()}
       
      </table>
      </body>
    </html>''',
                                ));

                        return pdf.save();
                      }

                      _getStoragePermission();
                      _generatePdf("المساعدات");
                    },
                    icon: Icon(Icons.print))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(selectedDateRange == null || selectedDateRange == ''
                    ? ''
                    : selectedDateRange),
              ),
            ),
            Center(
              child: _assisstents.length <= 0
                  ? Text(_chelpDateController.selectedRange == null
                      ? ''
                      : "لا توجد مساعدات في هذه المدة")
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: myColumns,
                        sortAscending: _sortAsc,
                        sortColumnIndex: _sortColumnIndex,
                        rows: myRows.toList(),
                        headingTextStyle: TextStyle(
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
