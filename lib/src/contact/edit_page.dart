import 'package:help_app/src/app_widget.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/scheduler.dart';

import '/src/app_module.dart';
import '/src/home/home_bloc.dart';
import '/src/home/home_module.dart';
import '/src/shared/repository/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:hijri/hijri_calendar.dart';

final _backgroundColor = Color(0xFFededed);
final _foregroundColor = Colors.black;

enum DurationList { continuous, discontinuous }

class EditPage extends StatefulWidget {
  static String tag = 'edit-page';
  static Map contact;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
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
  static var _chelpDuration = "";

  DateTimeRange _date;

  DurationList _character = _chelpDuration == "مسمترة"
      ? DurationList.continuous
      : DurationList.discontinuous;

  String storedNationalId;
  bool isNationalIdValid;

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

    var list = items.toList();

    for (var map in list) {
      if (map.containsKey("nationalId")) {
        if (map["nationalId"] == i.toString()) {
          return true;
        }
      }
    }
  }

  @override
  void initState() {
    bloc = HomeModule.to.getBloc<HomeBloc>();
    contactRepository = AppModule.to.getDependency<ContactRepository>();
    _cFirstName.text = EditPage.contact['name'];
    _cLastName.text = EditPage.contact['name'];
    _cPhoneNumber.text = EditPage.contact['phoneNumber'];
    _cNationalId.text = EditPage.contact['nationalId'];
    _chelpDate.text = EditPage.contact['helpDate'];

    List helpDateArray;
    if (_chelpDate.text.isEmpty || _chelpDate.text == null) {
      helpDateArray =
          "${DateFormat('dd/MM/yyyy').format(DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 10)))}"
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

    hijriStartDate = HijriCalendar.fromDate(
        DateTime(storedStartYear, storedStartMonth, storedStartDay));

    hijriEndDate = HijriCalendar.fromDate(
        DateTime(storedEndYear, storedEndMonth, storedEndDay));

    _chijriHelpDate.text =
        _chelpDate.text.isEmpty ? "" : "$hijriStartDate - $hijriEndDate";

    _chelpType = EditPage.contact['helpType'];

    _chelpTypeOther.text =
        !helpTypeList.contains(_chelpType) ? _chelpType : null;

    _chelpTypeOther.text = _chelpTypeOther.text.trim();

    storedNationalId = _cNationalId.text;

    if (!helpTypeList.contains(_chelpType)) {
      setState(() {
        helpTypeOtherEnabled = true;
      });
    }

    _chelpAmount.text = EditPage.contact['helpAmount'].toString() != '0'
        ? EditPage.contact['helpAmount'].toString()
        : '';
    _chelpDuration = EditPage.contact['helpDuration'];
    _cnotes.text = EditPage.contact['notes'];

    var fullNameSeprated = EditPage.contact['name'].split(" ");
    fullNameSeprated.removeWhere((element) =>
        element == " " || element.isEmpty || element == "" || element == ".");

    var firstName;
    var lastName;
    if (fullNameSeprated.length > 1) {
      lastName = fullNameSeprated.last;
      fullNameSeprated.removeLast();
      firstName = fullNameSeprated.join(" ");
    } else {
      firstName = fullNameSeprated.join(" ");
      lastName = '';
    }

    _cFirstName.text = firstName;
    _cLastName.text = lastName;

    _character = _chelpDuration == "مستمرة"
        ? DurationList.continuous
        : DurationList.discontinuous;

    if (_chelpDate.text.isNotEmpty) {
      var helpDateArray = _chelpDate.text.split("-");
      var storedStartDate = helpDateArray[0].split("/");
      var storedStartDay = int.parse(storedStartDate[0].trim());
      var storedStartMonth = int.parse(storedStartDate[1].trim());
      var storedStartYear = int.parse(storedStartDate[2].trim());

      var storedEndDate = helpDateArray[1].split("/");
      var storedEndDay = int.parse(storedEndDate[0].trim());
      var storedEndMonth = int.parse(storedEndDate[1].trim());
      var storedEndYear = int.parse(storedEndDate[2].trim());

      _date = DateTimeRange(
          start: DateTime(storedStartYear, storedStartMonth, storedStartDay),
          end: DateTime(storedEndYear, storedEndMonth, storedEndDay));
    } else {
      _date = DateTimeRange(
          start: DateTime.now(), end: DateTime.now().add(Duration(days: 10)));
    }
    isNationalIdValid = _cNationalId.text == storedNationalId ? true : false;
    super.initState();
  }

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _nationalIdFocus = FocusNode();
  final FocusNode _helpDateFocus = FocusNode();
  final FocusNode _helpAmountFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  final FocusNode _helpTypeOther = FocusNode();
  List helpTypeList = ["صدقة", "زواج", "معونة", "اجار", "بناء", "نذر", "حج"];

  @override
  Widget build(BuildContext context) {
    TextFormField inputFirstName = TextFormField(
      controller: _cFirstName,
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
        labelText: 'الأسم الأول',
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
          return 'يجب اضافة الأسم الأول';
        } else if (value.length < 3) {
          return 'الأسم الأول يجب ان يكون اكثر من حرفين';
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty || value.trim().length == 0) {
          return 'يجب اضافة الأسم الأول';
        } else if (value.length < 3) {
          return 'الأسم الأول يجب ان يكون اكثر من حرفين';
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
        labelText: 'الأسم الأخير',
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
          return 'الأسم الأخير يجب ان يكون اكثر من حرفين';
        }

        return null;
      },
      validator: (value) {
        if (value.isNotEmpty && value.trim().length < 3) {
          return 'الأسم الأخير يجب ان يكون اكثر من حرفين';
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
          FocusScope.of(context).requestFocus(_helpAmountFocus);
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: "رقم الهاتف",
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
            return "يجب إضافة رقم الهاتف";
          } else if (value.length >= 1 && value.length < 10) {
            return "رقم الهاتف يجب ان يكون عشرت ارقام";
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
        labelText: "رقم الهوية",
        icon: Icon(Icons.badge_outlined, color: _foregroundColor),
        suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: _foregroundColor,
            onPressed: () => _cNationalId.text = ""),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return "يجب إضافة رقم الهوية";
        } else if (value.length >= 1 && value.length < 10) {
          return "رقم الهوية يجب ان يكون عشرت ارقام";
        } else if (isNationalIdValid == false &&
            _cNationalId.text != storedNationalId) {
          return "رقم الهوية مسجلة مسبقا";
        }

        return null;
      },
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
                    confirmText: "حفظ",
                    cancelText: "إلغاء",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onSubmit: (value) {
                      _chelpDate.text =
                          "${DateFormat('dd/MM/yyyy').format(_chelpDateController.selectedRange.startDate)} - ${DateFormat('dd/MM/yyyy').format(_chelpDateController.selectedRange.endDate)}";

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
        labelText: 'ميلادي',
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
                            "${DateFormat('dd/MM/yyyy').format(DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 10)))}"
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
                    confirmText: "حفظ",
                    cancelText: "إلغاء",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onSubmit: (value) {
                      _chijriHelpDate.text =
                          "${DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.startDate.toDateTime())} - ${DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.endDate.toDateTime())}";

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
                          "${DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.startDate.toDateTime())} - ${DateFormat('dd/MM/yyyy').format(_chijriHelpDateController.selectedRange.endDate.toDateTime())}";

                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            });
      },
      decoration: InputDecoration(
        labelText: 'هجري',
        icon: Icon(Icons.date_range, color: _foregroundColor),
      ),
    );

    DropdownButtonFormField inputHelpType = DropdownButtonFormField(
      style: TextStyle(fontWeight: FontWeight.bold, color: _foregroundColor),
      decoration: InputDecoration(
        labelText: "نوع المساعدة",
        icon: Icon(Icons.help, color: _foregroundColor),
      ),
      value: helpTypeList.contains(_chelpType) ? _chelpType : "أخرى",
      onChanged: (value) {
        print("value $value");
        if (value == "أخرى") {
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
          child: Text("صدقة"),
          value: "صدقة",
        ),
        DropdownMenuItem(
          child: Text("زواج"),
          value: "زواج",
        ),
        DropdownMenuItem(
          child: Text("معونة"),
          value: "معونة",
        ),
        DropdownMenuItem(
          child: Text("اجار"),
          value: "اجار",
        ),
        DropdownMenuItem(
          child: Text("بناء"),
          value: "بناء",
        ),
        DropdownMenuItem(
          child: Text("نذر"),
          value: "نذر",
        ),
        DropdownMenuItem(
          child: Text("حج"),
          value: "حج",
        ),
        DropdownMenuItem(
          child: Text("أخرى"),
          value: "أخرى",
        )
      ],
    );

    Visibility inputHelpTypeOther = Visibility(
      visible: helpTypeOtherEnabled,
      child: TextFormField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
        controller: _chelpTypeOther,
        enabled: helpTypeOtherEnabled,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        focusNode: _helpTypeOther,
        onFieldSubmitted: (term) {
          _helpDateFocus.unfocus();
          FocusScope.of(context).requestFocus(_helpAmountFocus);
        },
        decoration: InputDecoration(
          labelText: 'نوع مساعدة اخرى',
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              color: _foregroundColor,
              onPressed: () => _chelpTypeOther.text = ""),
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
          labelText: 'مقدار المساعدة',
          icon: Icon(Icons.attach_money, color: _foregroundColor),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value.trim().isNotEmpty) {
            if (double.parse(value).floor() <= 0) {
              return "يجب ان يكون المقدار اكثر من $value";
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
        labelText: 'ملاحظات',
        icon: Icon(Icons.notes, color: _foregroundColor),
      ),
    );

    ListView body = ListView(
      padding: EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text("تاريخ المساعدة", textAlign: TextAlign.left),
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
                  // inputHelpDuration,

                  Text("مدة المساعدة", textAlign: TextAlign.left),
                  RadioListTile<DurationList>(
                    title: const Text('مستمرة'),
                    value: DurationList.continuous,
                    groupValue: _character,
                    onChanged: (DurationList value) {
                      setState(() {
                        _character = value;
                        _chelpDuration = "مستمرة";
                      });
                    },
                  ),
                  RadioListTile<DurationList>(
                    title: const Text('منقطعة'),
                    value: DurationList.discontinuous,
                    groupValue: _character,
                    onChanged: (DurationList value) {
                      setState(() {
                        _character = value;
                        _chelpDuration = "منقطعة";
                      });
                    },
                  ),

                  SizedBox(height: 15),
                  inputNotes
                ],
              ),
            ))
      ],
    );

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            tooltip: "إغلاق",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("تعديل المساعدة"),
          actions: <Widget>[
            Container(
              width: 80,
              child: IconButton(
                icon: Icon(Icons.check),
                tooltip: "حفظ",
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    try {
                      contactRepository.update({
                        'name': "${_cFirstName.text} ${_cLastName.text}",
                        'nationalId': _cNationalId.text,
                        'phoneNumber': _cPhoneNumber.text,
                        'helpDate': _chelpDate.text.toString(),
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
                      }, EditPage.contact['id']).then((saved) {
                        Map contact = {
                          'name': "${_cFirstName.text} ${_cLastName.text}",
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
                        };
                        bloc.setContact(contact);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AppWidget()),
                          (Route<dynamic> route) => false,
                        );
                      });
                    } on DatabaseException catch (err) {
                      print("يوجد خطأ: $err");
                    }
                  }
                },
              ),
            )
          ],
        ),
        body: body);
  }
}
