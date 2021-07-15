import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sqflite/sqflite.dart';
import '../app_module.dart';
import '/src/shared/repository/contact_repository.dart';
import 'package:numeral/numeral.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key key}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  ContactRepository contactRepository;

  openDBList() async {
    Database db = await contactRepository.getDb();
    List<Map> items =
        await db.rawQuery('SELECT helpType, helpAmount FROM contacts');

    var list = items.toList();
    var listOfValues = {
      "صدقة": "0",
      "زواج": "0",
      "معونة": "0",
      "اجار": "0",
      "بناء": "0",
      "نذر": "0",
      "حج": "0"
    };
    var totalAmount;

    for (int i = 0; i < list.length; i++) {
      if (listOfValues.containsKey(list[i].values.first)) {
        print(listOfValues.containsKey(list[i].values.first));
        if (list[i].values.first != null ||
            list[i].values.first.toString().trim() != '') {
          listOfValues.update(
              list[i].values.first,
              (value) => ((double.parse(value).floor() <= 0
                          ? 0
                          : double.parse(value)) +
                      list[i].values.last)
                  .toString());
          print(listOfValues);
        }
      } else {
        if (list[i].values.first != null ||
            list[i].values.first.toString().trim().isNotEmpty) {
          listOfValues[list[i].values.first] = list[i].values.last.toString();
          print(listOfValues);
        }
      }
      totalAmount = listOfValues.values.reduce((sum, element) {
        return (double.parse(sum) + double.parse(element)).toString();
      });
    }

    return [list, listOfValues, totalAmount];
  }

  Map myList = {};
  var myTotalAmount = "0";
  var database;

  var databaseList;

  void initState() {
    contactRepository = AppModule.to.getDependency<ContactRepository>();
    // asyncMethod();
    Future.delayed(Duration(seconds: 1), () async {
      var list = await openDBList();
      setState(() {
        myList = list[1];
        myTotalAmount = list[2];
      });
    });

    super.initState();
  }

  // asyncMethod() async {
  //   var list = await openDBList();
  //   setState(() {
  //     myList = list[1];
  //     myTotalAmount = list[2];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الرسم البياني"),
        centerTitle: true,
      ),
      body: Container(
        child: SfCartesianChart(
          title: ChartTitle(text: 'تقرير لمجموع أنواع المساعدة'),
          legend: Legend(isVisible: false),
          primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(fontSize: 20),
              title: AxisTitle(
                  text:
                      // 'المجموع الكامل : \u202B${double.parse(myTotalAmount)}\u202C',
                      ' المجموع الكامل : \u202B${Numeral(double.parse(myTotalAmount != null ? myTotalAmount : "0")).value().replaceAll('K', ' ألف').replaceAll('M', ' مليون').replaceAll('B', ' مليار').replaceAll('T', ' ترليون ')}\u202C ريال',
                  textStyle: TextStyle(fontSize: 25))),
          series: <ChartSeries>[
            // Initialize line series
            ColumnSeries<SalesData, String>(
                dataSource: [
                  // Bind data source
                  if (myList.entries.length > 0)
                    for (var i in myList.entries)
                      if (double.parse(i.value) > 0 &&
                          i.key != null &&
                          i.key.toString().trim().isNotEmpty)
                        SalesData('${i.key}', double.parse(i.value)),
                ],
                xValueMapper: (SalesData sales, _) => sales.year,
                yValueMapper: (SalesData sales, _) => sales.sales,
                dataLabelMapper: (SalesData data, _) {
                  if (myList != null)
                    return "\u202B${Numeral(data.sales).value().replaceAll('K', ' ألف').replaceAll('M', ' مليون').replaceAll('B', ' مليار').replaceAll('T', ' ترليون ')}\u202C";
                  return "\u202B${Numeral(data.sales).value().replaceAll('K', ' ألف').replaceAll('M', ' مليون').replaceAll('B', ' مليار').replaceAll('T', ' ترليون ')}\u202C";
                },
                dataLabelSettings: DataLabelSettings(
                    isVisible: true, textStyle: TextStyle(fontSize: 20)))
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}

class HelpTypeData {
  HelpTypeData(this.type, this.totalAmount);
  final String type;
  final String totalAmount;
}
