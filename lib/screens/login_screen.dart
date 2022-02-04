import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../components/custom_textField.dart';
import '../constant/constant.dart';
import '../screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  static String route = '/loginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Map<String, String> formData = {
    'email': '',
    'password': '',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(10.0),
          margin: EdgeInsets.all(10.0),
          height: 300.0,
          width: MediaQuery.of(context).size.width,
          decoration:
              BoxDecoration(boxShadow: KStandardBoxShadow, color: Colors.white),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'LOGIN',
                    style: KCardHeadingTextStyle,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                CustomTextField(
                  label: 'Email',
                  validate: (String value) {
                    if (value.length == 0) {
                      return 'Empty field';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                CustomTextField(
                  label: 'Password',
                  validate: (String value) {
                    if (value.length == 0) {
                      return 'Empty field';
                    } else if (value.length < 6) {
                      return 'Password should be of min 6 character';
                    } else {
                      return null;
                    }
                  },
                  obscure: true,
                ),
                SizedBox(
                  height: 10.0,
                ),
                CustomButton(
                  label: 'LOGIN',
                  onTap: () async {
//                    await databaseService.initializeDB();
                    Navigator.pushNamed(context, MainScreen.route);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
