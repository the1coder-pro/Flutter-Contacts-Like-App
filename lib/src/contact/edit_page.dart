import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '/src/app_module.dart';
import '/src/home/home_bloc.dart';
import '/src/home/home_module.dart';
import '/src/shared/repository/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _chelpType = EditPage.contact['helpType'];
    _chelpTypeOther.text =
        !helpTypeList.contains(_chelpType) ? _chelpType : null;

    _chelpTypeOther.text = _chelpTypeOther.text.trim();

    if (!helpTypeList.contains(_chelpType)) {
      setState(() {
        helpTypeOtherEnabled = true;
      });
    }

    _chelpAmount.text = EditPage.contact['helpAmount'].toString();
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

    storedNationalId = _cNationalId.text;

    isNationalIdValid = _cNationalId.text == storedNationalId ? true : false;

    print("value");

    print("value $storedNationalId");
    print("value $isNationalIdValid");

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

  void selectDate() async {
    final DateTimeRange newDate = await showDateRangePicker(
        context: context,
        initialDateRange: _date,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2080, 12),
        helpText: 'حدد نطاقًا زمنيًا',
        saveText: 'حفظ',
        confirmText: 'حسنا',
        cancelText: 'إلغاء');
    if (newDate != null) {
      setState(() {
        _date = newDate;
      });
    } else if (newDate == null) return;
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
        labelText: 'الأسم الأول',
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
          FocusScope.of(context).requestFocus(_helpDateFocus);
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: "رقم الهاتف",
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
        // labelStyle: TextStyle(color: _foregroundColor),
        icon: Icon(Icons.person_pin_rounded, color: _foregroundColor),
        suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: _foregroundColor,
            onPressed: () => _cNationalId.text = ""),
      ),
      // لا يتم التعديل للصفحة كلها لان البرنامج يحس ان رقم الهوية يريد ان يعيد التسجيل مجددا وهو ليس مسجل الا هذه المره ولكن يحسب ان في واحد اخر

      validator: (value) {
        if (value.isEmpty) {
          return "يجب إضافة رقم الهوية";
        } else if (value.length >= 1 && value.length < 10) {
          return "رقم الهوية يجب ان يكون عشرت ارقام";
        } else if (isNationalIdValid == false) {
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

    TextFormField inputHelpDate = TextFormField(
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
      // التاريخ لا يتعدل حتى بعد الإختيار لا يتغير
      onTap: () {
        selectDate();
        setState(() {
          _chelpDate.text =
              "${DateFormat('dd/MM/yyyy').format(_date.start)} - ${DateFormat('dd/MM/yyyy').format(_date.end)}";
        });

        // "${_date.start.day}/${_date.start.month}/${_date.start.year} - ${_date.end.day}/${_date.end.month}/${_date.end.year}";
      },
      onChanged: (value) {
        _chelpDate.text = value;
      },
      decoration: InputDecoration(
          labelText: 'تاريخ المساعدة',
          // labelStyle: TextStyle(color: _foregroundColor),
          icon: Icon(Icons.calendar_today, color: _foregroundColor)),
    );

    DropdownButtonFormField inputHelpType = DropdownButtonFormField(
      style: TextStyle(fontWeight: FontWeight.bold, color: _foregroundColor),
      decoration: InputDecoration(
        labelText: "نوع المساعدة",
        // labelStyle: TextStyle(color: _foregroundColor),
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
        labelText: 'مقدار المساعدة',
        // labelStyle: TextStyle(color: _foregroundColor),
        icon: Icon(Icons.attach_money, color: _foregroundColor),
      ),
    );

    TextFormField inputNotes = TextFormField(
      maxLines: 5,
      controller: _cnotes,
      keyboardType: TextInputType.text,
      focusNode: _notesFocus,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'ملاحظات',
        // labelStyle: TextStyle(color: _foregroundColor),
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
                  inputHelpDate,
                  SizedBox(height: 15),
                  inputHelpType,
                  SizedBox(height: 10),
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
                        'helpAmount': _chelpAmount.text,
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
                          'helpAmount': _chelpAmount.text,
                          'helpDuration': _chelpDuration,
                          'notes': _cnotes.text
                        };
                        bloc.setContact(contact);
                        Navigator.pop(context);
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
