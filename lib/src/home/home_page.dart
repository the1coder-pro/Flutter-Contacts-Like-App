import '/src/contact/add_page.dart';
import '/src/shared/widgets/ContactList.dart';
import 'package:flutter/material.dart';

import 'home_bloc.dart';
import 'home_module.dart';

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
    return Scaffold(
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
                  backgroundColor: color,
                  actions: <Widget>[
                    IconButton(
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
            bloc.setVisibleButtonSearch(snapshot.data.length > 0 || searching);

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
    );
  }
}
