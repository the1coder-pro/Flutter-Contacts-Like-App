import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:help_app/src/contact/view_page.dart';
import 'package:help_app/src/home/home_bloc.dart';
import 'package:help_app/src/home/home_module.dart';
import 'package:help_app/src/shared/repository/contact_repository.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:dart_date/dart_date.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

import '../app_module.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({Key key}) : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  HomeBloc bloc;

  ContactRepository contactRepository;
  bool permissionGranted;
  // PermissionStatus permissionStatus = PermissionStatus.denied;
  // void _listenForPermission() async {
  //   final status = await Permission.storage.status;
  //   switch (status) {
  //     case PermissionStatus.denied:
  //       requestForPermission();
  //       break;
  //     case PermissionStatus.granted:
  //       break;
  //     case PermissionStatus.limited:
  //       Navigator.pop(context);
  //       break;
  //     case PermissionStatus.restricted:
  //       Navigator.pop(context);
  //       break;
  //     case PermissionStatus.permanentlyDenied:
  //       Navigator.pop(context);
  //       break;
  //   }
  // }

  // Future<void> requestForPermission() async {
  //   final status = await Permission.storage.request();
  //   setState(() {
  //     permissionStatus = status;
  //   });
  // }

  var rangeOfDates;
  List foundedDates = [];
  List foundedContactsDates = [];
  List<DataRow> dataRows = [];

  openDBList() async {
    Database db = await contactRepository.getDb();
    List<Map> items = await db
        .rawQuery('SELECT id, name, helpAmount, helpDate FROM contacts');

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

      var fullNameSeprated = name.trim().split(" ");
      fullNameSeprated.removeWhere((element) =>
          element == " " || element.isEmpty || element == "" || element == ".");
      var lastName = fullNameSeprated.last == "" ||
              fullNameSeprated.last.trim() == null ||
              fullNameSeprated.last.trim().isEmpty
          ? null
          : fullNameSeprated.last.trim();

      var firstName = fullNameSeprated.first.trim() == "" ||
              fullNameSeprated.first.trim() == null ||
              fullNameSeprated.first.trim().isEmpty
          ? null
          : fullNameSeprated.first;

      myListOfDates.add(
          "$startDate - $endDate - $firstName $lastName - $helpAmount - $id");
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
    dataRows.clear();
    for (var i = 0; i < foundedDates.length; i++) {
      dataRows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(foundedDates[i].split(" - ")[2])),
          DataCell(Text(foundedDates[i].split(" - ")[0])),
          DataCell(Text(foundedDates[i].split(" - ")[1])),
          DataCell(Text(foundedDates[i].split(" - ")[3])),
          DataCell(IconButton(
              icon: Icon(Icons.visibility),
              onPressed: () {
                Navigator.pop(context);
                bloc.setContact(foundedContactsDates[i]);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewPage()));
              })),
        ],
      ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("طباعة"),
        leading: IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        children: [
          Center(child: Text("مدة المساعدات")),
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
                                    DateRangePickerNavigationDirection.vertical,
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
                                        "${DateFormat('dd/MM/yyyy').format(_chelpDateController.selectedRange.startDate)} - ${DateFormat('dd/MM/yyyy').format(_chelpDateController.selectedRange.endDate)}";
                                    foundedDates = [];
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
                      } else if (await Permission.storage.request().isDenied) {
                        setState(() {
                          permissionGranted = false;
                        });
                      }
                    }

//                     Future<void> _createPDF() async {
//                       final directory = await getExternalStorageDirectory();

// //Get directory path
//                       final path = directory.path;
//                       // Create a new PDF document.
//                       final PdfDocument document = PdfDocument();
// // Add a new page to the document.
//                       PdfPage page = document.pages.add();

// //Create a PDF true type font object.
//                       final PdfGrid grid = PdfGrid();
// // Specify the grid column count.
//                       grid.columns.add(count: 5);
// // Add a grid header row.
//                       final PdfGridRow headerRow = grid.headers.add(1)[0];
//                       headerRow.cells[0].value = 'id';
//                       headerRow.cells[1].value = 'name';
//                       headerRow.cells[2].value = 'startDate';
//                       headerRow.cells[3].value = 'endDate';
//                       headerRow.cells[4].value = 'Amount';

// // Set header font.
//                       headerRow.style.font = PdfStandardFont(
//                           PdfFontFamily.helvetica, 10,
//                           style: PdfFontStyle.bold);
// // Add rows to the grid.
//                       PdfGridRow row = grid.rows.add();

//                       for (int i = 0; i < foundedDates.length; i++) {
//                         row.cells[0].value =
//                             "google"; // foundedDates[i].split(" - ")[4];
//                         row.cells[1].value =
//                             "apple"; //foundedDates[i].split(" - ")[2];
//                         row.cells[2].value =
//                             "samsung"; //foundedDates[i].split(" - ")[0];
//                         row.cells[3].value =
//                             "lg"; //foundedDates[i].split(" - ")[1];
//                         row.cells[4].value =
//                             "huawei"; //foundedDates[i].split(" - ")[3];
//                       }

//                       final PdfFont font = PdfTrueTypeFont(
//                           File('Arial.ttf').readAsBytesSync(), 14);

//                       row.style.font = font;

// // Set grid format.
//                       grid.style.cellPadding = PdfPaddings(left: 5, top: 5);
// // Draw table in the PDF page.
//                       grid.draw(
//                           page: page,
//                           bounds: Rect.fromLTWH(
//                               0,
//                               0,
//                               page.getClientSize().width,
//                               page.getClientSize().height));

// // Save the document.
//                       File('$path/Output.pdf').writeAsBytes(document.save());
// // Dispose the document.
//                       document.dispose();
// //Open the PDF document in mobile
//                       OpenFile.open('$path/Output.pdf');
//                     }

                    Future<Uint8List> _generatePdf(String title) async {
                      final pdf = pw.Document();
                      // final ttf =
                      //     await fontFromAssetBundle('fonts/Changa-Regular.ttf');

                      var list1 = [];
                      for (int i = 0; i < foundedDates.length; i++) {
                        list1.add("<tr>");
                        list1.add(
                            "<th>" + foundedDates[i].split(" - ")[4] + "</th>");
                        list1.add(
                            "<th>" + foundedDates[i].split(" - ")[2] + "</th>");
                        list1.add(
                            "<th>" + foundedDates[i].split(" - ")[0] + "</th>");
                        list1.add(
                            "<th>" + foundedDates[i].split(" - ")[1] + "</th>");
                        list1.add(
                            "<th>" + foundedDates[i].split(" - ")[3] + "</th>");
                        list1.add("</tr>");
                      }
                      // pdf.addPage(pw.Page(
                      //     pageFormat: PdfPageFormat.a4,
                      //     build: (pw.Context context) {
                      //       return pw.Center(
                      //         child: pw.Table(children: [
                      //           pw.TableRow(children: [
                      //             pw.Text("Name",
                      //                 style: pw.TextStyle(font: ttf)),
                      //             pw.Text("Start Date",
                      //                 style: pw.TextStyle(font: ttf)),
                      //             pw.Text("End Date",
                      //                 style: pw.TextStyle(font: ttf))
                      //           ]),
                      //           pw.TableRow(children: list1)
                      //         ]),
                      //       ); // Center
                      //     })); //

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
  th, td, p, h3 {
    padding: 5px;
    text-align: center;
  }
  </style>
</head>
  <body>
    <h3>المساعدات</h3>
    <table style="width:100%">
      <tr>
      <th>ID</th>
        <th>Name</th>
        <th>Start Date</th>
        <th>End Date</th>
        <th>Amount</th>
      </tr>
      
      $list1
      
      
     
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
            child: dataRows.length <= 0
                ? Text(_chelpDateController.selectedRange == null
                    ? ''
                    : "لا توجد مساعدات في هذه المدة")
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'الأسم',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'تاريخ البداية',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'تاريخ النهاية',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'المقدار',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'عرض',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ], rows: dataRows),
                  ),
          ),
        ],
      ),
    );
  }
}
