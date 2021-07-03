import 'package:flutter_slidable/flutter_slidable.dart';

import '/src/about/about_page.dart';
import '/src/contact/add_page.dart';
import '/src/contact/edit_page.dart';
import '/src/contact/view_page.dart';
import '/src/home/home_bloc.dart';
import '/src/home/home_module.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';

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
        return AlertDialog(
          title: const Text("هل انت متأكد انك تريد حذف هذه المساعدة ؟"),
          content: Text(
            "${item['name']}",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(primary: _foregroundColor),
              child: Text("إلغاء"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: _foregroundColor),
              child: Text(
                "نعم",
                style: TextStyle(color: _backgroundColor),
              ),
              onPressed: () {
                Navigator.pop(context);
                bloc.deleteContact(item['id']);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    if (widget.items.length == 0) {
      return column(context);
    }

    return ListView.separated(
      separatorBuilder: (_, __) => Divider(),
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        Map item = widget.items[index];
        return GestureDetector(
          onTapDown: _onTapDown,
          onLongPress: () {
            showMenu(
              elevation: 3,
              context: context,
              items: [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('تعديل'),
                    onTap: () {
                      Navigator.pop(context);
                      print(item);

                      // bloc.setContact(item);
                      EditPage.contact = item;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditPage()),
                      );
                    },
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('حذف'),
                    onTap: () {
                      Navigator.pop(context);
                      _showDialog(item);
                    },
                  ),
                ),
              ],
              position: RelativeRect.fromRect(
                _tapPosition & Size(40, 40), // smaller rect, the touch area
                Offset.zero & overlay.size, // Bigger rect, the entire screen
              ),
            );
          },
          child: Slidable(
            actionExtentRatio: 1 / 2,
            actionPane: SlidableScrollActionPane(),
            actions: [
              IconSlideAction(
                caption: "حذف",
                color: Colors.red[200],
                icon: Icons.delete,
                onTap: () => print("delete ${item['name']}"),
              ),
              IconSlideAction(
                caption: "تعديل",
                color: Colors.blue[200],
                icon: Icons.edit,
                onTap: () {
                  Navigator.pop(context);
                  print(item);

                  // bloc.setContact(item);
                  EditPage.contact = item;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditPage()),
                  );
                },
              )
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
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.left,
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
                        text:
                            '${item['helpAmount'].toString().length > 0 ? item['helpAmount'].toString() + " ريال" : "[مقدار المساعدة]"}',
                        style: TextStyle(
                            fontWeight: item['helpAmount'].toString().length > 0
                                ? FontWeight.bold
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
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.left,
                ),
                onTap: () {
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
