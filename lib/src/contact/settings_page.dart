import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MySettings with ChangeNotifier {
  bool _leftToRight = false;

  bool get leftToRight => _leftToRight;
  set leftToRight(bool newDate) {
    _leftToRight = newDate;
    notifyListeners();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage(BuildContext context, {Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer<MySettings>(
          builder: (context, mySettings, _) => Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("الإعدادات"),
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ListView(
              children: [
                SwitchListTile(
                    title: Text("تغير اتجاه الواجهة"),
                    value: mySettings._leftToRight,
                    onChanged: (value) => mySettings.leftToRight = value)
              ],
            ),
          ),
        ));
  }
}
