// import 'dart:async';

// import 'package:string_validator/string_validator.dart';
// import 'package:reactive_forms/reactive_forms.dart';
// import 'package:async_textformfield/async_textformfield.dart';
import 'package:flutter/scheduler.dart';
import 'package:help_app/src/contact/settings_page.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

import '/src/home/home_bloc.dart';
import '/src/home/home_module.dart';
import '/src/shared/repository/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
// import 'package:syncfusion_flutter_core/core_internal.dart';
// import 'package:syncfusion_flutter_core/legend_internal.dart';
// import 'package:syncfusion_flutter_core/localizations.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
// import 'package:syncfusion_flutter_core/tooltip_internal.dart';
import '../app_module.dart';

final _backgroundColor = Color(0xFFededed);
final _foregroundColor = Colors.black;

enum DurationList { continuous, discontinuous }

class MyDatePicker with ChangeNotifier {
  bool _isHijri = false;

  bool get isHijri => _isHijri;
  set isHijri(bool newCalender) {
    _isHijri = newCalender;
    notifyListeners();
  }
}

class AddPage extends StatefulWidget {
  static String tag = 'add-page';
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _cFirstName = TextEditingController();
  final _cLastName = TextEditingController();
  final _cPhoneNumber = TextEditingController();
  final _cNationalId = TextEditingController();
  final _chelpDate = TextEditingController();
  final _chijriHelpDate = TextEditingController();
  DateRangePickerController _chelpDateController = DateRangePickerController();
  HijriDatePickerController _chijriHelpDateController =
      HijriDatePickerController();

  String _chelpType;
  final _chelpTypeOther = TextEditingController();
  bool helpTypeOtherEnabled = false;

  final _chelpAmount = TextEditingController();
  final _cnotes = TextEditingController();
  HomeBloc bloc;
  ContactRepository contactRepository;
  var _chelpDuration = "????????????";
  var dblist;
  var isNationalIdValid = false;
  DurationList _character = DurationList.continuous;

  HijriCalendar hijriStartDate;
  HijriCalendar hijriEndDate;

  HijriDateRange hirjiDates;
  PickerDateRange gregDates;

  var storedStartDate;
  var storedStartDay;
  var storedStartMonth;
  var storedStartYear;

  var storedEndDate;
  var storedEndDay;
  var storedEndMonth;
  var storedEndYear;

  openDBList(i) async {
    Database db = await contactRepository.getDb();
    List<Map> items = await db.rawQuery('SELECT nationalId FROM contacts');
    // bool isItemInItems;
    // isItemInItems = items.contains(i);
    var list = items.toList();
    for (var map in list) {
      if (map.containsKey("nationalId")) {
        if (map["nationalId"] == i.toString()) {
          // print("its here");
          return true;
        }
      }
    }
  }

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _nationalIdFocus = FocusNode();
  final FocusNode _helpDateFocus = FocusNode();
  final FocusNode _helpAmountFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  final FocusNode _helpTypeOther = FocusNode();

  @override
  void initState() {
    bloc = HomeModule.to.getBloc<HomeBloc>();
    contactRepository = AppModule.to.getDependency<ContactRepository>();
    _chelpDateController.displayDate = DateTime.now();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextFormField inputFirstName = TextFormField(
      controller: _cFirstName,
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      focusNode: _firstNameFocus,
      onFieldSubmitted: (term) {
        _firstNameFocus.unfocus();
        FocusScope.of(context).requestFocus(_lastNameFocus);
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: '?????????? ??????????',
        // labelStyle: TextStyle(color: _foregroundColor),
        icon: Icon(
          Icons.person,
          color: _foregroundColor,
        ),
        suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: _foregroundColor,
            onPressed: () => _cFirstName.text = ""),
      ),
      onChanged: (value) {
        if (value.isEmpty || value.trim().length == 0) {
          return '?????? ?????????? ?????????? ??????????';
        } else if (value.length < 3) {
          return '?????????? ?????????? ?????? ???? ???????? ???????? ???? ??????????';
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty || value.trim().length == 0) {
          return '?????? ?????????? ?????????? ??????????';
        } else if (value.length < 3) {
          return '?????????? ?????????? ?????? ???? ???????? ???????? ???? ??????????';
        }
        return null;
      },
    );

    TextFormField inputLastName = TextFormField(
      controller: _cLastName,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        LengthLimitingTextInputFormatter(25),
      ],
      focusNode: _lastNameFocus,
      onFieldSubmitted: (term) {
        _lastNameFocus.unfocus();
        FocusScope.of(context).requestFocus(_nationalIdFocus);
      },
      decoration: InputDecoration(
        labelText: '?????????? ????????????',
        // labelStyle: TextStyle(color: _foregroundColor),
        icon: Icon(
          Icons.person,
          color: _foregroundColor,
        ),
        suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: _foregroundColor,
            onPressed: () => _cLastName.text = ""),
      ),
      onChanged: (value) {
        if (value.isNotEmpty && value.trim().length < 3) {
          return '?????????? ???????????? ?????? ???? ???????? ???????? ???? ??????????';
        }

        return null;
      },
      validator: (value) {
        if (value.isNotEmpty && value.trim().length < 3) {
          return '?????????? ???????????? ?????? ???? ???????? ???????? ???? ??????????';
        }

        return null;
      },
    );

    TextFormField inputPhoneNumber = TextFormField(
        controller: _cPhoneNumber,
        inputFormatters: [
          LengthLimitingTextInputFormatter(10),
        ],
        maxLength: 10,
        focusNode: _phoneNumberFocus,
        onFieldSubmitted: (term) {
          _phoneNumberFocus.unfocus();
          FocusScope.of(context).requestFocus(_helpDateFocus);
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: "?????? ????????????",
          // labelStyle: TextStyle(color: _foregroundColor),
          icon: Icon(
            Icons.phone,
            color: _foregroundColor,
          ),

          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              color: _foregroundColor,
              onPressed: () => _cPhoneNumber.text = ""),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return "?????? ?????????? ?????? ????????????";
          } else if (value.length >= 1 && value.length < 10) {
            return "?????? ???????????? ?????? ???? ???????? ???????? ??????????";
          } else {
            return null;
          }
        });

    TextFormField inputNationalId = TextFormField(
      controller: _cNationalId,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
      ],
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 10,
      focusNode: _nationalIdFocus,
      onFieldSubmitted: (term) {
        _nationalIdFocus.unfocus();
        FocusScope.of(context).requestFocus(_phoneNumberFocus);
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: "?????? ????????????",
        icon: Icon(Icons.badge_outlined, color: _foregroundColor),
        suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: _foregroundColor,
            onPressed: () => _cNationalId.text = ""),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return "?????? ?????????? ?????? ????????????";
        } else if (value.length >= 1 && value.length < 10) {
          return "?????? ???????????? ?????? ???? ???????? ???????? ??????????";
        } else if (isNationalIdValid == false) {
          return "?????? ???????????? ?????????? ??????????";
        }

        return null;
      },

      // make a copy of the nationalId list in a variable rather than checking every time in the database
      onChanged: (value) async {
        var msg = await openDBList(_cNationalId.text);
        if (msg != null) {
          if (msg) {
            setState(() {
              isNationalIdValid = false;
            });
          }
        } else {
          setState(() {
            isNationalIdValid = true;
          });
        }
      },
    );

    var inputHelpDate = TextFormField(
      controller: _chelpDate,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.next,
      focusNode: _helpDateFocus,
      onFieldSubmitted: (term) {
        _helpDateFocus.unfocus();
        FocusScope.of(context).requestFocus(_helpAmountFocus);
      },
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                child: SizedBox(
                  width: 700,
                  height: 400,
                  child: SfDateRangePicker(
                    onViewChanged: (DateRangePickerViewChangedArgs args) {
                      List helpDateArray =
                          _chijriHelpDate.text.trim().split("-");

                      if (helpDateArray.length == 1 || helpDateArray.isEmpty) {
                        hijriStartDate = HijriCalendar.fromDate(DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day));

                        hijriEndDate = HijriCalendar.fromDate(DateTime(
                            DateTime.now().add(Duration(days: 10)).year,
                            DateTime.now().add(Duration(days: 10)).month,
                            DateTime.now().add(Duration(days: 10)).day));

                        helpDateArray =
                            "$hijriStartDate-$hijriEndDate".split("-");
                      }
                      storedStartDate = helpDateArray[0].split("/");
                      print("StartDate: $storedStartDate");
                      print("dateArry: $helpDateArray");

                      storedStartDay = int.parse(storedStartDate[0].trim());
                      storedStartMonth = int.parse(storedStartDate[1].trim());
                      storedStartYear = int.parse(storedStartDate[2].trim());

                      storedEndDate = helpDateArray[1].split("/");
                      storedEndDay = int.parse(storedEndDate[0].trim());
                      storedEndMonth = int.parse(storedEndDate[1].trim());
                      storedEndYear = int.parse(storedEndDate[2].trim());

                      var dateToGergStart = new HijriCalendar();

                      // var da3 = HijriDateTime(
                      //         storedStartYear, storedStartMonth, storedStartDay)
                      //     .toDateTime();

                      // print("storedStartYear : $storedStartYear");
                      // print("storedStartYearTOGERG: $da3");

                      var dateToGergEnd = HijriCalendar();
                      dateToGergEnd.hijriToGregorian(
                          storedEndYear, storedEndMonth, storedEndDay);

                      // print("dateToGergStart - Year: ${dateToGergStart.hYear}");
                      // print("dateToGergEnd - Year: ${dateToGergEnd.hYear}");

                      gregDates = PickerDateRange(
                          DateTime(
                              dateToGergStart
                                  .hijriToGregorian(storedStartYear,
                                      storedStartMonth, storedStartDay)
                                  .year,
                              dateToGergStart
                                  .hijriToGregorian(storedStartYear,
                                      storedStartMonth, storedStartDay)
                                  .month,
                              dateToGergStart
                                  .hijriToGregorian(storedStartYear,
                                      storedStartMonth, storedStartDay)
                                  .day),
                          DateTime(
                              dateToGergEnd
                                  .hijriToGregorian(storedEndYear,
                                      storedEndMonth, storedEndDay)
                                  .year,
                              dateToGergEnd
                                  .hijriToGregorian(storedEndYear,
                                      storedEndMonth, storedEndDay)
                                  .month,
                              dateToGergEnd
                                  .hijriToGregorian(storedEndYear,
                                      storedEndMonth, storedEndDay)
                                  .day));
                      // print(
                      //     "gregDates : ${gregDates.startDate}, ${gregDates.endDate}");
                      SchedulerBinding.instance
                          .addPostFrameCallback((Duration duration) {
                        // _chelpDateController.selectedRange = gregDates;
                        _chelpDateController.selectedRange = gregDates;
                      });
                    },
                    backgroundColor: _backgroundColor,
                    controller: _chelpDateController,
                    view: DateRangePickerView.month,
                    monthViewSettings: DateRangePickerMonthViewSettings(
                        firstDayOfWeek: 6,
                        viewHeaderStyle: DateRangePickerViewHeaderStyle(
                            backgroundColor: Colors.grey[350])),
                    headerStyle: DateRangePickerHeaderStyle(
                        backgroundColor: Colors.grey[300],
                        textStyle:
                            TextStyle(color: _foregroundColor, fontSize: 30)),
                    navigationDirection:
                        DateRangePickerNavigationDirection.vertical,
                    navigationMode: DateRangePickerNavigationMode.scroll,
                    selectionMode: DateRangePickerSelectionMode.extendableRange,
                    showActionButtons: true,
                    confirmText: "??????",
                    cancelText: "??????????",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onSubmit: (value) {
                      _chelpDate.text =
                          "${intl.DateFormat('dd/MM/yyyy').format(_chelpDateController.selectedRange.startDate)} - ${intl.DateFormat('dd/MM/yyyy').format(_chelpDateController.selectedRange.endDate)}";

                      setState(() {
                        List helpDateArray = _chelpDate.text.split("-");

                        storedStartDate = helpDateArray[0].split("/");
                        storedStartDay = int.parse(storedStartDate[0].trim());
                        storedStartMonth = int.parse(storedStartDate[1].trim());
                        storedStartYear = int.parse(storedStartDate[2].trim());

                        storedEndDate = helpDateArray[1].split("/");
                        storedEndDay = int.parse(storedEndDate[0].trim());
                        storedEndMonth = int.parse(storedEndDate[1].trim());
                        storedEndYear = int.parse(storedEndDate[2].trim());

                        hijriStartDate = HijriCalendar.fromDate(DateTime(
                            storedStartYear, storedStartMonth, storedStartDay));

                        hijriEndDate = HijriCalendar.fromDate(DateTime(
                            storedEndYear, storedEndMonth, storedEndDay));

                        hirjiDates = HijriDateRange(
                            HijriDateTime(hijriStartDate.hYear,
                                hijriStartDate.hMonth, hijriStartDate.hDay),
                            HijriDateTime(hijriEndDate.hYear,
                                hijriEndDate.hMonth, hijriEndDate.hDay));

                        gregDates = PickerDateRange(
                            DateTime(storedStartYear, storedStartMonth,
                                storedStartDay),
                            DateTime(
                                storedEndYear, storedEndMonth, storedEndDay));
                      });

                      _chijriHelpDate.text = "";

                      _chijriHelpDate.text = "$hijriStartDate - $hijriEndDate";

                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            });
      },
      decoration: InputDecoration(
        labelText: '????????????',
        icon: Icon(Icons.date_range, color: _foregroundColor),
      ),
    );

    var inputHelpHirjiDate = TextFormField(
      controller: _chijriHelpDate,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.next,
      focusNode: _helpDateFocus,
      onFieldSubmitted: (term) {
        _helpDateFocus.unfocus();
        FocusScope.of(context).requestFocus(_helpAmountFocus);
      },
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                child: SizedBox(
                  width: 700,
                  height: 400,
                  child: SfHijriDateRangePicker(
                    onViewChanged: (HijriDatePickerViewChangedArgs args) {
                      List helpDateArray;
                      if (_chelpDate.text.isEmpty || _chelpDate.text == null) {
                        helpDateArray =
                            "${intl.DateFormat('dd/MM/yyyy').format(DateTime.now())} - ${intl.DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 10)))}"
                                .split("-");
                      } else {
                        helpDateArray = _chelpDate.text.split("-");
                      }
                      storedStartDate = helpDateArray[0].split("/");
                      storedStartDay = int.parse(storedStartDate[0].trim());
                      storedStartMonth = int.parse(storedStartDate[1].trim());
                      storedStartYear = int.parse(storedStartDate[2].trim());

                      storedEndDate = helpDateArray[1].split("/");
                      storedEndDay = int.parse(storedEndDate[0].trim());
                      storedEndMonth = int.parse(storedEndDate[1].trim());
                      storedEndYear = int.parse(storedEndDate[2].trim());

                      hijriStartDate = HijriCalendar.fromDate(DateTime(
                          storedStartYear, storedStartMonth, storedStartDay));

                      hijriEndDate = HijriCalendar.fromDate(DateTime(
                          storedEndYear, storedEndMonth, storedEndDay));

                      hirjiDates = HijriDateRange(
                          HijriDateTime(hijriStartDate.hYear,
                              hijriStartDate.hMonth, hijriStartDate.hDay),
                          HijriDateTime(hijriEndDate.hYear, hijriEndDate.hMonth,
                              hijriEndDate.hDay));

                      SchedulerBinding.instance
                          .addPostFrameCallback((Duration duration) {
                        // _chelpDateController.selectedRange = gregDates;
                        _chijriHelpDateController.selectedRange = hirjiDates;
                      });
                    },
                    backgroundColor: _backgroundColor,
                    controller: _chijriHelpDateController,
                    view: HijriDatePickerView.month,
                    monthViewSettings: HijriDatePickerMonthViewSettings(
                        firstDayOfWeek: 6,
                        viewHeaderStyle: DateRangePickerViewHeaderStyle(
                            backgroundColor: Colors.grey[350])),
                    headerStyle: DateRangePickerHeaderStyle(
                        backgroundColor: Colors.grey[300],
                        textStyle:
                            TextStyle(color: _foregroundColor, fontSize: 30)),
                    navigationDirection:
                        DateRangePickerNavigationDirection.vertical,
                    navigationMode: DateRangePickerNavigationMode.scroll,
                    selectionMode: DateRangePickerSelectionMode.extendableRange,
                    showActionButtons: true,
                    confirmText: "??????",
                    cancelText: "??????????",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onSubmit: (value) {
                      _chijriHelpDate.text =
                          "${intl.DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.startDate.toDateTime())} - ${intl.DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.endDate.toDateTime())}";

                      setState(() {
                        var helpDateArray = _chijriHelpDate.text.split("-");
                        storedStartDate = helpDateArray[0].split("/");
                        storedStartDay = int.parse(storedStartDate[0].trim());
                        storedStartMonth = int.parse(storedStartDate[1].trim());
                        storedStartYear = int.parse(storedStartDate[2].trim());

                        storedEndDate = helpDateArray[1].split("/");
                        storedEndDay = int.parse(storedEndDate[0].trim());
                        storedEndMonth = int.parse(storedEndDate[1].trim());
                        storedEndYear = int.parse(storedEndDate[2].trim());

                        hijriStartDate = HijriCalendar.fromDate(DateTime(
                            storedStartYear, storedStartMonth, storedStartDay));
                        hijriEndDate = HijriCalendar.fromDate(DateTime(
                            storedEndYear, storedEndMonth, storedEndDay));

                        gregDates = PickerDateRange(
                            DateTime(storedStartYear, storedStartMonth,
                                storedStartDay),
                            DateTime(
                                storedEndYear, storedEndMonth, storedEndDay));
                      });

                      _chijriHelpDate.text = "$hijriStartDate - $hijriEndDate";
                      _chelpDate.text =
                          "${intl.DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.startDate.toDateTime())} - ${intl.DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.endDate.toDateTime())}";

                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            });
      },
      decoration: InputDecoration(
        labelText: '????????',
        icon: Icon(Icons.date_range, color: _foregroundColor),
      ),
    );

    DropdownButtonFormField inputHelpType = DropdownButtonFormField(
      style: TextStyle(fontWeight: FontWeight.bold, color: _foregroundColor),
      decoration: InputDecoration(
        labelText: "?????? ????????????????",
        // labelStyle: TextStyle(color: _foregroundColor),
        icon: Icon(Icons.help, color: _foregroundColor),
      ),
      value: _chelpType,
      onChanged: (value) {
        print("value $value");
        if (value == "????????") {
          setState(() {
            helpTypeOtherEnabled = true;
          });
          FocusScope.of(context).requestFocus(_helpTypeOther);
        } else {
          setState(() {
            _chelpTypeOther.text = "";
            _chelpType = value;
            helpTypeOtherEnabled = false;
          });
        }
      },
      items: [
        DropdownMenuItem(
          child: Text("????????"),
          value: "????????",
        ),
        DropdownMenuItem(
          child: Text("????????"),
          value: "????????",
        ),
        DropdownMenuItem(
          child: Text("??????????"),
          value: "??????????",
        ),
        DropdownMenuItem(
          child: Text("????????"),
          value: "????????",
        ),
        DropdownMenuItem(
          child: Text("????????"),
          value: "????????",
        ),
        DropdownMenuItem(
          child: Text("????????"),
          value: "????????",
        )
      ],
    );

    Visibility inputHelpTypeOther = Visibility(
      visible: helpTypeOtherEnabled,
      child: TextFormField(
        controller: _chelpTypeOther,
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
        enabled: helpTypeOtherEnabled,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        focusNode: _helpTypeOther,
        onFieldSubmitted: (term) {
          _helpDateFocus.unfocus();
          FocusScope.of(context).requestFocus(_helpAmountFocus);
        },
        decoration: InputDecoration(
          labelText: '?????? ???????????? ????????',
          // labelStyle: TextStyle(color: _foregroundColor),
          icon: Icon(Icons.help, color: _foregroundColor),
        ),
      ),
    );

    TextFormField inputHelpAmount = TextFormField(
        controller: _chelpAmount,
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        focusNode: _helpAmountFocus,
        onFieldSubmitted: (term) {
          _helpAmountFocus.unfocus();
          FocusScope.of(context).requestFocus(_notesFocus);
        },
        decoration: InputDecoration(
          labelText: '?????????? ????????????????',
          // labelStyle: TextStyle(color: _foregroundColor),
          icon: Icon(Icons.attach_money, color: _foregroundColor),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value.trim().isNotEmpty) {
            if (double.parse(value) <= 0) {
              return "?????? ???? ???????? ?????????????? ???????? ???? $value";
            }
          }
          return null;
        });

    TextFormField inputNotes = TextFormField(
      maxLines: 5,
      controller: _cnotes,
      keyboardType: TextInputType.text,
      focusNode: _notesFocus,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: '??????????????',
        // labelStyle: TextStyle(color: _foregroundColor),
        icon: Icon(Icons.notes, color: _foregroundColor),
      ),
    );

    ListView content = ListView(
      padding: EdgeInsets.all(30),
      children: <Widget>[
        Form(
          key: _formKey,
          child: Theme(
            data: ThemeData(
              backgroundColor: _backgroundColor,
              brightness: Brightness.light,
              primaryColor: _foregroundColor,
              buttonTheme: ButtonThemeData(buttonColor: _foregroundColor),
              cardColor: _foregroundColor,
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: _foregroundColor,
                  selectionHandleColor: _foregroundColor),
              toggleableActiveColor: _foregroundColor,
              scaffoldBackgroundColor: _backgroundColor,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _foregroundColor)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[600])),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[700])),
                labelStyle: TextStyle(color: _foregroundColor),
                focusColor: _foregroundColor,
                hoverColor: _foregroundColor,
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 15),
                inputFirstName,
                SizedBox(height: 15),
                inputLastName,
                SizedBox(height: 15),
                inputNationalId,
                SizedBox(height: 15),
                inputPhoneNumber,
                SizedBox(height: 15),
                Text("?????????? ????????????????", textAlign: TextAlign.left),
                SizedBox(height: 10),
                inputHelpDate,
                SizedBox(height: 8),
                inputHelpHirjiDate,
                SizedBox(height: 20),
                inputHelpType,
                SizedBox(height: 8),
                inputHelpTypeOther,
                SizedBox(height: 15),
                inputHelpAmount,
                SizedBox(height: 15),
                Text("?????? ????????????????", textAlign: TextAlign.left),
                RadioListTile<DurationList>(
                  activeColor: _foregroundColor,
                  selectedTileColor: _foregroundColor,
                  title: const Text('????????????'),
                  value: DurationList.continuous,
                  groupValue: _character,
                  onChanged: (DurationList value) {
                    setState(() {
                      _character = value;
                      _chelpDuration = "????????????";
                    });
                  },
                ),
                RadioListTile<DurationList>(
                  activeColor: _foregroundColor,
                  selectedTileColor: _foregroundColor,
                  title: const Text('????????????'),
                  value: DurationList.discontinuous,
                  groupValue: _character,
                  onChanged: (DurationList value) {
                    setState(() {
                      _character = value;
                      _chelpDuration = "????????????";
                    });
                  },
                ),
                SizedBox(height: 15),
                inputNotes
              ],
            ),
          ),
        ),
      ],
    );
    final mySettings = Provider.of<MySettings>(context);

    return Directionality(
      textDirection:
          mySettings.leftToRight ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: _foregroundColor,
          backgroundColor: _backgroundColor,
          elevation: 0,
          actionsIconTheme: IconThemeData(color: _foregroundColor),
          leading: IconButton(
            icon: Icon(Icons.close),
            tooltip: "??????????",
            color: _foregroundColor,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("?????????? ???????????? ??????????",
              style: TextStyle(color: _foregroundColor)),
          actions: <Widget>[
            Container(
              width: 80,
              child: IconButton(
                icon: Icon(Icons.check),
                tooltip: "??????",
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    try {
                      contactRepository.insert({
                        'name':
                            "${_cFirstName.text.trim()} ${_cLastName.text.trim()}",
                        'nationalId': _cNationalId.text,
                        'phoneNumber': _cPhoneNumber.text,
                        'helpDate': _chelpDate.text,
                        'helpType': _chelpTypeOther.text.isEmpty
                            ? _chelpType
                            : _chelpTypeOther.text,
                        'helpAmount': _chelpAmount.text.trim().isNotEmpty
                            ? double.parse(_chelpAmount.text).floor() <= 0
                                ? '0'
                                : _chelpAmount.text
                            : '0',
                        'helpDuration': _chelpDuration,
                        'notes': _cnotes.text
                      }).then((saved) {
                        bloc.getListContact();
                        Navigator.of(context).pop();
                      });
                    } on DatabaseException catch (err) {
                      print("???????? ??????: $err");
                    }
                  }
                },
              ),
            )
          ],
        ),
        body: content,
      ),
    );
  }
}
