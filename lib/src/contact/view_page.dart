// import 'dart:io';
// import 'dart:async';
// import 'package:exemplo/application.dart';

import '/src/home/home_bloc.dart';
import '/src/home/home_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:hijri/digits_converter.dart';
// import 'package:hijri/hijri_array.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import 'edit_page.dart';

final _backgroundColor = Color(0xFFededed);
final _foregroundColor = Colors.black;

class MyDate with ChangeNotifier {
  String _myRangeDate = "";

  String get myRangeDate => _myRangeDate;
  set myRangeDate(String newDate) {
    _myRangeDate = newDate;
    notifyListeners();
  }
}

class ViewPage extends StatefulWidget {
  static String tag = 'view-page';

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  static String defaultMessage = "لا توجد بيانات";

  Map contact;
  var viewedDate;

  HomeBloc blocHome;

  @override
  void initState() {
    blocHome = HomeModule.to.getBloc<HomeBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pageContext = context;
    ListView content(context, Map snapshot) {
      return ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildHeader(context, "${snapshot['name']}"),
              buildInformation(
                  [snapshot['name']],
                  snapshot['phoneNumber'],
                  snapshot['nationalId'],
                  snapshot['helpDate'],
                  snapshot['helpType'],
                  snapshot['helpAmount'],
                  snapshot['helpDuration'],
                  snapshot['notes']),
            ],
          )
        ],
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: StreamBuilder(
          stream: blocHome.favoriteOut,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('خطأ : ${snapshot.error}');
            } else {
              var fullNameSeprated = contact['name'].trim().split(" ");

              var lastName = fullNameSeprated.last;
              fullNameSeprated.removeLast();
              var firstName = fullNameSeprated.join(" ");

              return AppBar(
                foregroundColor: _foregroundColor,
                actionsIconTheme: IconThemeData(color: _foregroundColor),
                iconTheme: IconThemeData(color: _foregroundColor),
                elevation: 0.5,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.delete),
                      tooltip: "حذف",
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                    "هل انت متأكد انك تريد حذف هذه المساعدة ؟"),
                                content: Text(
                                  "$firstName $lastName",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                actions: <Widget>[
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        primary: _foregroundColor),
                                    child: Text("إلغاء"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: _foregroundColor),
                                    child: Text(
                                      "نعم",
                                      style: TextStyle(color: _backgroundColor),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      blocHome.deleteContact(contact['id']);
                                      Navigator.pop(pageContext);
                                    },
                                  ),
                                ],
                              );
                            });
                      }),
                  IconButton(
                    icon: Icon(Icons.edit),
                    tooltip: "تعديل",
                    onPressed: () {
                      EditPage.contact = this.contact;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditPage()),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: StreamBuilder(
        stream: blocHome.contactOut,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Error: ${snapshot.error}');
          } else {
            this.contact = snapshot.data;
            blocHome.setFavorite(snapshot.data['favorite'] == 1);
            return content(context, snapshot.data);
          }
        },
      ),
    );
  }

  _textMe(String number) async {
    // Android
    String uri = "sms:$number";
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      String uri = "sms:$number";
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'لم يستطع الفتح $uri';
      }
    }
  }

  _launchCaller(String number) async {
    String url = "tel:$number";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'لم يستطع الفتح $url';
    }
  }

  Container buildHeader(BuildContext context, String name) {
    var titleName = name;
    var fullNameSeprated = titleName.trim().split(" ");

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

    return Container(
      decoration: BoxDecoration(color: _backgroundColor),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.40,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          SizedBox(height: 20),
          Icon(
            Icons.person,
            color: _foregroundColor,
            size: 160,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    "$firstName${fullNameSeprated.length != 1 ? ' $lastName' : ''}",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        color: _foregroundColor,
                        fontSize: 40,
                        fontFamily: 'Amiri'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding buildInformation(name, phoneNumber, nationalId, helpDate, helpType,
      helpAmount, helpDuration, notes) {
    var titleName = name.join(" ");
    var fullNameSeprated = titleName.trim().split(" ");
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
    var helpDateArray;

    var storedStartDate;
    var storedStartDay;
    var storedStartMonth;
    var storedStartYear;

    var storedEndDate;
    var storedEndDay;
    var storedEndMonth;
    var storedEndYear;

    var hijriStartDate;
    var hijriEndDate;

    if (helpDate.isNotEmpty) {
      helpDateArray = helpDate.split("-");

      storedStartDate = helpDateArray[0].split("/");
      storedStartDay = int.parse(storedStartDate[0].trim());
      storedStartMonth = int.parse(storedStartDate[1].trim());
      storedStartYear = int.parse(storedStartDate[2].trim());

      storedEndDate = helpDateArray[1].split("/");
      storedEndDay = int.parse(storedEndDate[0].trim());
      storedEndMonth = int.parse(storedEndDate[1].trim());
      storedEndYear = int.parse(storedEndDate[2].trim());

      hijriStartDate = HijriCalendar.fromDate(
          DateTime(storedStartYear, storedStartMonth, storedStartDay));
      hijriEndDate = HijriCalendar.fromDate(
          DateTime(storedEndYear, storedEndMonth, storedEndDay));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChangeNotifierProvider(
        create: (context) => MyDate(),
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                title: Text(name.join(" ").isNotEmpty
                    ? name.join(" ")
                    : defaultMessage),
                subtitle: Text(
                  "الأسم الكامل",
                  style: TextStyle(color: Colors.black54),
                ),
                onLongPress: name == "" || name == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: name.join(" ")));

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("تم نسخ الأسم الكامل",
                                textDirection: TextDirection.rtl)));
                      },
                leading: IconButton(
                    icon: Icon(Icons.person, color: _foregroundColor),
                    tooltip: "الأسم الكامل",
                    onPressed: null),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(phoneNumber.toString().isNotEmpty
                    ? phoneNumber
                    : defaultMessage),
                subtitle: Text(
                  "رقم الهاتف",
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: phoneNumber == "" || phoneNumber == null
                    ? null
                    : () => _launchCaller(phoneNumber),
                onLongPress: phoneNumber == "" || phoneNumber == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: phoneNumber));

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("تم نسخ رقم الهاتف",
                                textDirection: TextDirection.rtl)));
                      },
                leading: phoneNumber == "" || phoneNumber == null
                    ? null
                    : IconButton(
                        icon: Icon(Icons.phone, color: _foregroundColor),
                        tooltip: "اتصال",
                        onPressed: () {
                          _launchCaller(phoneNumber);
                        },
                      ),
                trailing: phoneNumber == "" || phoneNumber == null
                    ? null
                    : IconButton(
                        icon: Icon(Icons.message, color: _foregroundColor),
                        tooltip: "رسائل",
                        onPressed: () {
                          _textMe(phoneNumber);
                        },
                      ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(nationalId.toString().isNotEmpty
                    ? nationalId
                    : defaultMessage),
                subtitle: Text(
                  "رقم الهوية",
                  style: TextStyle(color: Colors.black54),
                ),
                onLongPress: nationalId == "" || nationalId == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: nationalId));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("تم نسخ رقم الهوية",
                                textDirection: TextDirection.rtl)));
                      },
                leading: IconButton(
                    icon: Icon(Icons.badge_outlined, color: _foregroundColor),
                    onPressed: null),
              ),
            ),
            Consumer<MyDate>(
              builder: (context, date, _) => Card(
                child: ListTile(
                  title: Text(helpDate.toString().isNotEmpty
                      ? date._myRangeDate == ""
                          ? helpDate
                          : date._myRangeDate
                      : defaultMessage),
                  subtitle: Text(
                    "تاريخ المساعدة",
                    style: TextStyle(color: Colors.black54),
                  ),
                  onTap: helpDate == "" || helpDate == null
                      ? null
                      : () {
                          date.myRangeDate = date.myRangeDate ==
                                  "$hijriStartDate - $hijriEndDate"
                              ? helpDate
                              : "$hijriStartDate - $hijriEndDate";
                        },
                  onLongPress: helpDate == "" || helpDate == null
                      ? null
                      : () {
                          Clipboard.setData(
                              ClipboardData(text: date._myRangeDate));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text(
                                  "تم نسخ تاريخ المساعدة (${date._myRangeDate == '$hijriStartDate - $hijriEndDate' ? 'هجري' : 'ميلادي'})",
                                  textDirection: TextDirection.rtl)));
                        },
                  leading: helpDate == "" || helpDate == null
                      ? null
                      : IconButton(
                          icon: Icon(Icons.date_range, color: _foregroundColor),
                          onPressed: null),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(helpType != null
                    ? helpType.toString().trim().isNotEmpty
                        ? helpType
                        : defaultMessage
                    : defaultMessage),
                subtitle: Text(
                  "نوع المساعدة",
                  style: TextStyle(color: Colors.black54),
                ),
                onLongPress: helpType.toString().trim() == "" ||
                        helpType.toString().trim() == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: helpType));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("تم نسخ نوع المساعدة",
                                textDirection: TextDirection.rtl)));
                      },
                leading: helpType.toString().trim() == "" ||
                        helpType.toString().trim() == null
                    ? null
                    : IconButton(
                        icon: Icon(Icons.help, color: _foregroundColor),
                        onPressed: null),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(helpAmount.toString().isNotEmpty
                    ? helpAmount.toString()
                    : defaultMessage),
                subtitle: Text(
                  "مقدار المساعدة",
                  style: TextStyle(color: Colors.black54),
                ),
                onLongPress: helpAmount == "" || helpAmount == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: helpAmount));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("تم نسخ مقدار المساعدة",
                                textDirection: TextDirection.rtl)));
                      },
                leading: helpAmount == "" || helpAmount == null
                    ? null
                    : IconButton(
                        icon: Icon(Icons.attach_money, color: _foregroundColor),
                        onPressed: null),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(helpDuration.toString().isNotEmpty
                    ? helpDuration.toString()
                    : defaultMessage),
                subtitle: Text(
                  "مدة المساعدة",
                  style: TextStyle(color: Colors.black54),
                ),
                onLongPress: helpDuration == "" || helpDuration == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: helpDuration));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("تم نسخ مدة المساعدة",
                                textDirection: TextDirection.rtl)));
                      },
                leading: IconButton(
                    icon: Icon(Icons.timer, color: _foregroundColor),
                    onPressed: null),
              ),
            ),
            Card(
              child: ListTile(
                title: notes == "" || notes == null
                    ? Text(defaultMessage)
                    : SelectableText(
                        notes,
                        style: TextStyle(color: Colors.black),
                      ),
                subtitle: Text("الملاحظات"),
                onLongPress: notes == "" || notes == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: notes));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text("تم نسخ الملاحظات",
                                textDirection: TextDirection.rtl)));
                      },
                leading: notes == "" || notes == null
                    ? null
                    : IconButton(
                        icon: Icon(Icons.notes, color: _foregroundColor),
                        tooltip: "ملاحظات",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: notes));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text("تم نسخ الملاحظات",
                                  textDirection: TextDirection.rtl)));
                        }),
              ),
            ),
            Consumer<MyDate>(
              builder: (context, date, _) => Card(
                child: ListTile(
                  title: Text(
                    "مشاركة هذه المساعدة",
                  ),
                  subtitle: Text(
                    "مشاركة",
                    style: TextStyle(color: Colors.black54),
                  ),
                  onTap: () {
                    Share.share("""
                               ${name != "" ? 'الأسم : ${name[0]}' : ''}\n
                               ${nationalId != "" ? 'رقم الهوية : $nationalId' : ''}\n
                               ${phoneNumber != "" ? 'رقم الجوال : $phoneNumber' : ''}\n
                               ${date._myRangeDate != "" ? 'تاريخ المساعدة : ${date._myRangeDate}' : ''}\n
                               ${helpType != "" ? 'نوع المساعدة : $helpType' : ''}\n
                               ${helpAmount != "" ? 'مقدار المساعدة : $helpAmount' : ''}\n
                               ${helpDuration != "" ? 'مدة المساعدة : $helpDuration' : ''}\n
                               ${notes != "" ? 'ملاحظات : $notes' : ''}\n

                            """);
                  },
                  leading: IconButton(
                    icon: Icon(Icons.share, color: _foregroundColor),
                    tooltip: "مشاركة",
                    onPressed: () {
                      if (phoneNumber != "" && nationalId != "") {
                        Share.share("""
                              الأسم: "$firstName ${fullNameSeprated.length != 1 ? lastName : ''}"
                              رقم الجوال: $phoneNumber
                              رقم الهوية : $nationalId
                            """);
                      } else if (phoneNumber == "" || phoneNumber == null) {
                        Share.share("""
                              الأسم: "$firstName ${fullNameSeprated.length != 1 ? lastName : ''}"
                              رقم الهوية : $nationalId
                            """);
                      } else if (nationalId == "" || nationalId == null) {
                        Share.share("""
                              الأسم: "$firstName ${fullNameSeprated.length != 1 ? lastName : ''}"
                              رقم الجوال: $phoneNumber
                            """);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
