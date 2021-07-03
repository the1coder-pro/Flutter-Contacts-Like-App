// import 'dart:async';

// import 'package:string_validator/string_validator.dart';
// import 'package:reactive_forms/reactive_forms.dart';
// import 'package:async_textformfield/async_textformfield.dart';
import 'package:intl/intl.dart';

import '/src/home/home_bloc.dart';
import '/src/home/home_module.dart';
import '/src/shared/repository/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../app_module.dart';

final _backgroundColor = Color(0xFFededed);
final _foregroundColor = Colors.black;

enum DurationList { continuous, discontinuous }

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

  String _chelpType;
  final _chelpTypeOther = TextEditingController();
  bool helpTypeOtherEnabled = false;

  final _chelpAmount = TextEditingController();
  final _cnotes = TextEditingController();
  HomeBloc bloc;
  ContactRepository contactRepository;
  var _chelpDuration = "مستمرة";
  var dblist;
  var isNationalIdValid = false;
  DurationList _character = DurationList.continuous;

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

  // var _helperMessage;
  DateTimeRange _date = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(Duration(days: 10)));

  void _selectDate() async {
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
  void initState() {
    bloc = HomeModule.to.getBloc<HomeBloc>();
    contactRepository = AppModule.to.getDependency<ContactRepository>();

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
        icon: Icon(Icons.person_pin_rounded, color: _foregroundColor),
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
        } else if (isNationalIdValid == false) {
          return "رقم الهوية مسجلة مسبقا";
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
      onTap: () {
        _selectDate();
        _chelpDate.text =
            "${DateFormat('dd/MM/yyyy').format(_date.start)} - ${DateFormat('dd/MM/yyyy').format(_date.end)}";
        // "${_date.start.day}/${_date.start.month}/${_date.start.year} - ${_date.end.day}/${_date.end.month}/${_date.end.year}";
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
      value: _chelpType,
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
          labelText: 'نوع مساعدة اخرى',
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

    ListView content = ListView(
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
                Text("مدة المساعدة", textAlign: TextAlign.left),
                RadioListTile<DurationList>(
                  activeColor: _foregroundColor,
                  selectedTileColor: _foregroundColor,
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
                  activeColor: _foregroundColor,
                  selectedTileColor: _foregroundColor,
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
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        foregroundColor: _foregroundColor,
        backgroundColor: _backgroundColor,
        elevation: 0,
        actionsIconTheme: IconThemeData(color: _foregroundColor),
        leading: IconButton(
          icon: Icon(Icons.close),
          tooltip: "اغلاق",
          color: _foregroundColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("إنشاء مساعدة جديدة",
            style: TextStyle(color: _foregroundColor)),
        actions: <Widget>[
          Container(
            width: 80,
            child: IconButton(
              icon: Icon(Icons.check),
              tooltip: "حفظ",
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
                      'helpAmount': _chelpAmount.text,
                      'helpDuration': _chelpDuration,
                      'notes': _cnotes.text
                    }).then((saved) {
                      bloc.getListContact();
                      Navigator.of(context).pop();
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
      body: content,
    );
  }
}
