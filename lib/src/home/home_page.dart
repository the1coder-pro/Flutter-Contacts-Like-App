import 'package:help_app/src/contact/print_page.dart';
import 'package:help_app/src/contact/settings_page.dart';

import '/src/contact/add_page.dart';
import '/src/contact/chart_page.dart';
import '/src/shared/widgets/ContactList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_bloc.dart';
import 'home_module.dart';
import '/src/contact/settings_page.dart';

final _backgroundColor = Color(0xFFededed);
final _foregroundColor = Colors.black;

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc bloc;
  Widget appBarTitle = Text("المساعدات",
      style: TextStyle(
          fontSize: 35, color: _foregroundColor, fontFamily: 'Scheherazade'));
  Icon actionIcon = Icon(Icons.search);
  Color color = _backgroundColor;
  bool searching = false;
  final _cSearch = TextEditingController();

  @override
  void initState() {
    bloc = HomeModule.to.getBloc<HomeBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bloc.getListContact();
    final mySettings = Provider.of<MySettings>(context);
    return Directionality(
      textDirection:
          mySettings.leftToRight ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          child: StreamBuilder(
            stream: bloc.buttonSearchOut,
            builder: (conext, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text('خطأ: ${snapshot.error}');
              } else {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data) {
                  return AppBar(
                    title: appBarTitle,
                    centerTitle: true,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: color,
                    leading: PopupMenuButton(
                        onSelected: (item) {
                          switch (item) {
                            case 'رسم بياني':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChartPage()));
                              break;
                            case 'طباعة':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PrintPage()));

                              break;
                            case 'الإعدادات':
                              return showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SettingsPage(context);
                                  });

                              break;
                          }
                        },
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (BuildContext cotntext) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.bar_chart),
                                      SizedBox(width: 30),
                                      Text("رسم بياني"),
                                    ],
                                  ),
                                  value: "رسم بياني"),
                              PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.print),
                                      SizedBox(width: 30),
                                      Text("طباعة"),
                                    ],
                                  ),
                                  value: "طباعة"),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.settings),
                                      SizedBox(width: 30),
                                      Text("الإعدادات"),
                                    ],
                                  ),
                                  value: "الإعدادات")
                            ]),
                    actions: <Widget>[
                      IconButton(
                        tooltip: "بحث",
                        icon: actionIcon,
                        color: _foregroundColor,
                        onPressed: () {
                          setState(() {
                            if (this.actionIcon.icon == Icons.search) {
                              this.actionIcon =
                                  Icon(Icons.close, color: _foregroundColor);
                              this.color = _backgroundColor;
                              this.appBarTitle = Center(
                                child: TextField(
                                  controller: _cSearch,
                                  cursorColor: _foregroundColor,
                                  style: TextStyle(
                                      color: _foregroundColor,
                                      fontFamily: 'Changa'),
                                  autofocus: true,
                                  onChanged: (value) {
                                    this.searching = true;
                                    bloc.getListBySearch(value);
                                  },
                                  decoration: InputDecoration(
                                      focusColor: _foregroundColor,
                                      fillColor: _foregroundColor,
                                      hoverColor: _foregroundColor,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.search,
                                      //     color: _foregroundColor),
                                      hintText: "بحث",
                                      hintStyle:
                                          TextStyle(color: _foregroundColor)),
                                ),
                              );
                            } else {
                              _cSearch.clear();
                              this.searching = false;

                              this.actionIcon = Icon(
                                Icons.search,
                              );

                              this.color = _backgroundColor;
                              this.appBarTitle = Text("المساعدات",
                                  style: TextStyle(
                                      fontSize: 35,
                                      color: _foregroundColor,
                                      fontFamily: 'Scheherazade'));
                              // bloc.getListContact();
                            }
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  return AppBar(
                    title: Text("المساعدات",
                        style: TextStyle(
                            fontSize: 35,
                            color: _foregroundColor,
                            fontFamily: 'Scheherazade')),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                  );
                }
              }
            },
          ),
        ),
        body: StreamBuilder(
          stream: bloc.listContactOut,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: _foregroundColor));
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('خطأ: ${snapshot.error}');
            } else {
              bloc.setVisibleButtonSearch(
                  snapshot.data.length > 0 || searching);

              if (searching && snapshot.data.length == 0) {
                return Column(
                  children: <Widget>[
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                          child: Column(
                        children: [
                          SizedBox(height: 30),
                          Image(
                            image: AssetImage('assets/openMagnifyingGlass.png'),
                            width: 250,
                            height: 250,
                          ),
                          Center(
                            child: Text('لا توجد مساعدات مسجلة',
                                style: TextStyle(
                                    fontSize: 35, fontFamily: 'Scheherazade')),
                          ),
                        ],
                      )),
                    )),
                  ],
                );
              } else {
                return ContactList(items: snapshot.data);
              }
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: "إنشاء مساعدة جديدة",
          backgroundColor: _foregroundColor,
          foregroundColor: _backgroundColor,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPage()),
            );
          },
        ),
      ),
    );
  }
}
