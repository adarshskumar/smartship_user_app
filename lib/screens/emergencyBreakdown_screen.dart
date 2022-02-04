import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../components/custom_textField.dart';
import '../components/loading_warpper.dart';
import '../screens/welcome_screen.dart';
import '../services/database_service.dart';

class EmergencyBreakdown extends StatefulWidget {
  static String route = '/emergencyBreakdown';
  final String projectId;
  EmergencyBreakdown({this.projectId});
  @override
  _EmergencyBreakdownState createState() => _EmergencyBreakdownState();
}

class _EmergencyBreakdownState extends State<EmergencyBreakdown> {
  bool isLoading = false;
  Future<bool> showMyDialog() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure'),
            content: Text('Are you sure for end this trip?'),
            actions: [
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: Text(
                  'Yes',
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

  String breakDownKM, reason;
  GlobalKey<FormState> _key = new GlobalKey<FormState>();

  void endService() async {
    var res = await showMyDialog();
    if (res) {
      print("Project ID ${widget.projectId}");
      DatabaseService databaseService = new DatabaseService();
      setState(() {
        isLoading = true;
      });
      bool res = await databaseService.emergencyBreakdown(
          widget.projectId, breakDownKM, reason);
      setState(() {
        isLoading = false;
      });
      if (res) {
//        Navigator.of(context)
//            .popUntil(ModalRoute.withName('/mainScreen'));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency"),
      ),
      body: LoadingWrapper(
        loading: isLoading,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Please enter breadown data'),
                CustomTextField(
                  label: 'Breakdown KM',
                  keyboardType: TextInputType.number,
                  onChange: (val) {
                    breakDownKM = val;
                  },
                  validate: (String v) {
                    if (v.length == 0) {
                      return "Empty Field";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  maxLength: 30,
                  onChanged: (val) {
                    reason = val;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Reason"),
                ),
                // CustomTextField(
                //   label: 'Reason',
                //   onChange: (val) {
                //     reason = val;
                //   },
                // ),
                SizedBox(
                  height: 50.0,
                ),
                CustomButton(
                  onTap: () {
                    if (_key.currentState.validate()) {
                      endService();
                    }
                  },
                  label: 'Finish',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
