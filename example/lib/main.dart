import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permit/permit.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PermitResult _permissionStatuses;
  Set<PermitType> _selectedPermissions = new Set<PermitType>();

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    PermitResult permitResult;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      permitResult = await Permit.checkPermissions(PermitType.values);
    } on PlatformException {
      print("ERROR!!!!");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _permissionStatuses = permitResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: new ListView(
                children: _permissionStatusCells(),
              ),
            ),
          ),
          new Container(
            constraints: new BoxConstraints.expand(height: 50.0),
            child: new MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                tappedRequestButton();
              },
              child: new Text("Request Selections"),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _permissionStatusCells() {
    List<Widget> cells = new List<Widget>();
    PermitType.values.forEach((permitType) {
      String status = "unavailable";
      if (_permissionStatuses != null && _permissionStatuses.success()) {
        if (_permissionStatuses.results.containsKey(permitType)) {
          status = _resultCodeToReadableString(
              _permissionStatuses.resultCodeForPermitType(permitType));
        }
      }
      Widget cell = new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Container(
          decoration: new BoxDecoration(
            border: new Border.all(
              color: Colors.grey,
              width: 2.0,
            ),
          ),
          child: new Row(
            children: <Widget>[
              new Checkbox(
                value: _selectedPermissions.contains(permitType),
                onChanged: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPermissions.add(permitType);
                    } else {
                      _selectedPermissions.remove(permitType);
                    }
                  });
                },
              ),
              new Text(
                permitType.toString(),
              ),
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: new Text(
                    status,
                    textAlign: TextAlign.right,
                  ),
                ),
              )
            ],
          ),
        ),
      );
      cells.add(cell);
    });
    return cells;
  }

  String _resultCodeToReadableString(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.granted) {
      return "granted";
    } else if (permissionStatus == PermissionStatus.denied) {
      return "denied";
    } else if (permissionStatus == PermissionStatus.needsRationale) {
      return "needs rationale";
    } else if (permissionStatus == PermissionStatus.unknown) {
      return "unknown";
    } else {
      return "unavailable";
    }
  }

  tappedRequestButton() async {
    List<PermitType> selectedPermissionsList = _selectedPermissions.toList();
    await Permit.requestPermissions(selectedPermissionsList);
    PermitResult permitResult = await Permit.checkPermissions(PermitType.values);
    setState(() {
      _permissionStatuses = permitResult;
    });
    print("done");
  }
}
