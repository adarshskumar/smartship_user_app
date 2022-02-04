import 'package:flutter/material.dart';
import '../Utils/policy.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String policyDetail = "";

  void _onClick() {
    Policy policy = new Policy(name: 'Bima', policyNum: 202, isActive: true);
    setState(() {
      policyDetail = policy.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          child: FlatButton(
            child: Text('Policy'),
            onPressed: _onClick,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(policyDetail)
      ],
    ));
  }
}
