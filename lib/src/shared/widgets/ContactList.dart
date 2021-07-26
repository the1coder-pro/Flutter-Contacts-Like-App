import 'package:help_app/src/contact/settings_page.dart';
import 'package:numeral/numeral.dart';
import 'package:provider/provider.dart';

import '/src/about/about_page.dart';
import '/src/contact/add_page.dart';
import '/src/contact/edit_page.dart';
import '/src/contact/view_page.dart';
import '/src/home/home_bloc.dart';
import '/src/home/home_module.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

final _backgroundColor = Color(0xFFededed);
final _foregroundColor = Colors.black;

class ContactList extends StatefulWidget {
  final List<Map> items;

  ContactList({this.items}) : super();
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  Offset _tapPosition;
  HomeBloc bloc;

  @override
  void initState() {
    bloc = HomeModule.to.getBloc<HomeBloc>();
    super.initState();
  }

  void _onTapDown(TapDownDetails details) {
    _tapPosition = details.globalPosition;
    print(_tapPosition);
  }

  Column column(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Image(
            image: AssetImage('assets/openBook.png'),
            width: 250,
            height: 250,
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Text('لا توجد مساعدات مسجلة',
              style: TextStyle(fontSize: 30, fontFamily: 'Scheherazade')),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPage()),
            );
          },
          child: Text(
            "إضافة مساعدة",
            style: TextStyle(
              color: _foregroundColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutPage()),
            );
          },
          child: Text(
            "حول",
            style: TextStyle(
              color: _foregroundColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog(item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final mySettings = Provider.of<MySettings>(context);

        return Directionality(
          textDirection:
              mySettings.leftToRight ? TextDirection.ltr : TextDirection.rtl,
          child: AlertDialog(
            title: Text("هل انت متأكد انك تريد حذف هذه المساعدة ؟"),
            titlePadding: EdgeInsets.all(50),
            content: Text("${item['name']}",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(primary: _foregroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("إلغاء", style: TextStyle(fontSize: 20)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: _foregroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "نعم",
                    style: TextStyle(color: _backgroundColor, fontSize: 20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  bloc.deleteContact(item['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.length == 0) {
      return column(context);
    }
    final mySettings = Provider.of<MySettings>(context);

    return ListView.separated(
      separatorBuilder: (_, __) => Divider(),
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        Map item = widget.items[index];
        return GestureDetector(
          onTapDown: _onTapDown,
          child: Slidable(
            actionExtentRatio: 1 / 5,
            actionPane: SlidableScrollActionPane(),
            actions: mySettings.leftToRight
                ? [
                    IconSlideAction(
                      icon: Icons.edit,
                      caption: "تعديل",
                      color: Colors.lightBlue[200],
                      onTap: () {
                        EditPage.contact = item;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditPage()),
                        );
                      },
                    ),
                    IconSlideAction(
                        icon: Icons.delete,
                        caption: "حذف",
                        color: Colors.red[200],
                        onTap: () {
                          _showDialog(item);
                        })
                  ]
                : [],
            secondaryActions: mySettings.leftToRight
                ? []
                : [
                    IconSlideAction(
                      icon: Icons.edit,
                      caption: "تعديل",
                      color: Colors.lightBlue[200],
                      onTap: () {
                        EditPage.contact = item;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditPage()),
                        );
                      },
                    ),
                    IconSlideAction(
                        icon: Icons.delete,
                        caption: "حذف",
                        color: Colors.red[200],
                        onTap: () {
                          _showDialog(item);
                        })
                  ],
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: ListTile(
                isThreeLine: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Center(
                      child: Text(
                    item['name'].substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 23, color: _foregroundColor),
                  )),
                ),
                title: RichText(
                    // textDirection: TextDirection.rtl,
                    // textAlign: TextAlign.left,
                    text: TextSpan(
                  children: [
                    TextSpan(
                        text: "${item['name']}\n",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Changa',
                        )),
                    TextSpan(text: "${item['nationalId']}")
                  ],
                  style: TextStyle(fontSize: 17, color: _foregroundColor),
                )),
                subtitle: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: item['helpAmount'].toString().length > 0
                            ? item['helpAmount'] > 0
                                ? '\u202B${Numeral(item['helpAmount']).value().replaceAll('K', ' ألف').replaceAll('M', ' مليون').replaceAll('B', ' مليار').replaceAll('T', ' ترليون ')}\u202C' +
                                    ' ريال'
                                : 'لا مقدار'
                            : 'لا مقدار',
                        style: TextStyle(
                            fontWeight: item['helpAmount'].toString().length > 0
                                ? item['helpAmount'] > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal
                                : FontWeight.normal)),
                    TextSpan(text: ' لأجل '),
                    TextSpan(
                        text:
                            '${item['helpType'] == null || item['helpType'].trim().length < 2 || item['helpType'].isEmpty ? "[أخرى]" : item['helpType'].trim()}',
                        style: TextStyle(
                            fontWeight: item['helpType'] == null ||
                                    item['helpType'].trim().length < 2 ||
                                    item['helpType'].isEmpty
                                ? FontWeight.normal
                                : FontWeight.bold)),
                    TextSpan(text: ' لفترة '),
                    TextSpan(
                        text: '${item['helpDuration']}',
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ], style: TextStyle(color: _foregroundColor)),
                  // textDirection: TextDirection.rtl,
                  // textAlign: TextAlign.left,
                ),
                onTap: () {
                  print(item);
                  bloc.setContact(item);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewPage()),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
