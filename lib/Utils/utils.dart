import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_textField.dart';
import '../constant/constant.dart';
import '../services/database_service.dart';

class Utils {
  List<Widget> yearList = [], monthList = [], dayList = [];
  Map<int, String> monthName = {
    1: 'January',
    2: 'Fabruary',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December'
  };
  Map driverData;
  var selectedReading = '';

  // Date selection bottom sheet

  Future<String> showBottomDateSheet(BuildContext context) async {
    var data = await showModalBottomSheet(
        context: context,
        builder: _buidBottomSheet,
        isScrollControlled: true,
        backgroundColor: Colors.black.withOpacity(0.09));
    return data;
  }

  // Bottom sheet builder function

  Widget _buidBottomSheet(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Container(
          height: 300,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              )),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter reading',
                  style: TextStyle(color: kThemeGreenColor, fontSize: 30.0),
                ),
                SizedBox(
                  height: 30.0,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      selectedReading = val;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "Reading"),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 30.0),
                //   child: CustomTextField(
                //     keyboardType: TextInputType.number,
                //     label: 'Reading',
                //     onChange: (val) {
                //       selectedReading = val;
                //     },
                //   ),
                // ),
                SizedBox(
                  height: 20.0,
                ),
                CustomButton(
                  label: 'Submit',
                  onTap: () {
                    Navigator.pop(context, selectedReading);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int> showMessageAlertBox(
      BuildContext context, String title, String desc) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              actions: [
                FlatButton(
                    child: Text('Ok', style: TextStyle(color: kThemeBlueColor)),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
              title: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              content: Container(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  desc,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.5)),
                  textAlign: TextAlign.left,
                ),
              ),
            ));
  }

  void showSnackBar(GlobalKey<ScaffoldState> key, String message) {
    key.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  void showTaxDialogBox(BuildContext context) async {
    String taxName = "Toll tax";
    String amount = "0";
    GlobalKey<FormState> key = new GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  height: 150.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomDropdown(
                          dropList: [
                            DropdownMenuItem(
                              value: 'Toll tax',
                              child: Text('Toll tax'),
                            ),
                            DropdownMenuItem(
                              value: 'Parking tax',
                              child: Text('Parking tax'),
                            ),
                            DropdownMenuItem(
                              value: 'Other tax',
                              child: Text('Other tax'),
                            ),
                            DropdownMenuItem(
                              value: 'Lorry receipt no',
                              child: Text('Lorry receipt no'),
                            ),
                            DropdownMenuItem(
                              value: 'Gate pass no',
                              child: Text('Gate pass no'),
                            ),
                          ],
                          onSelect: (val) {
                            setState(() {
                              taxName = val;
                            });
                          },
                          value: taxName),
                      Form(
                        key: key,
                        child: CustomTextField(
                          label: 'Enter amount',
                          keyboardType: TextInputType.number,
                          onChange: (v) => amount = v,
                          validate: (v) {
                            if (v.length == 0) {
                              return "Empty field";
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            actions: [
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'Submit',
                  style: TextStyle(color: kThemeBlueColor),
                ),
                onPressed: () {
                  if (key.currentState.validate()) {
                    DatabaseService databaseService = new DatabaseService();
                    databaseService.submitTax(taxName, amount);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  void showMessageError(BuildContext context, String message) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Oh no!'),
              content: Text(message),
              actions: [
                FlatButton(
                  child: Text(
                    'Ok',
                    style: TextStyle(color: kThemeBlueColor),
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }
}
