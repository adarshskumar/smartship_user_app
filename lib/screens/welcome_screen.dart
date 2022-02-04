import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:smartshipemployee/services/authentication_service.dart';
import '../Utils/utils.dart';
import '../components/custom_button.dart';
import '../components/loading_warpper.dart';
import '../constant/constant.dart';
import '../screens/main_screen.dart';
import '../services/database_service.dart';

class WelcomeScreen extends StatefulWidget {
  bool loggedin;
  static String route = '/welcomeScreen';
//  WelcomeScreen(this.loggedin);
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String number;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double offset = 3;

  //Loading data
  String verificationId;
  bool codesend = false;
  bool isValid = false;
  bool isLoading = false;
  Color loadingColor = null;

  String otp;

  // Utility
  DatabaseService databaseService = new DatabaseService();
  Utils utils = new Utils();

  @override
  void initState() {
    // versionCheck(context);
    super.initState();
  }

  versionCheck(context) async {
    //Get Current installed version of app
    await Firebase.initializeApp();
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      print("New version " + newVersion.toString());
      print("Current version " + currentVersion.toString());
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  _showVersionDialog(context) async {
    print("JAI MAHISHMATI");
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update";
        String btnLabelCancel = "Later";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                      child: Text(btnLabel),
                      //  onPressed: () => _launchURL(APP_STORE_URL),
                      onPressed: () {}),
                  FlatButton(
                    child: Text(btnLabelCancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : WillPopScope(
                onWillPop: () {},
                child: new AlertDialog(
                  title: Text(
                    title,
                    style: TextStyle(color: kThemeBlueColor),
                  ),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      color: Colors.white,
                      child: Text(
                        btnLabelCancel,
                        style: TextStyle(color: kThemeBlueColor),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      color: kThemeBlueColor,
                      child: Text(
                        btnLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {},
                    ),
                    SizedBox(
                      width: 20.0,
                    )
                  ],
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: LoadingWrapper(
          loading: isLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  height: 200.0,
                  width: 300.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('images/logo.png'))),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(
                    FirebaseAuth.instance.currentUser.phoneNumber
                        .toString()
                        .substring(3),
                  ),
                  trailing: FlatButton(
                    child: Text("Logout"),
                    onPressed: () async {
                      await AuthService().signout();
                      setState(() {
                        codesend = false;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              CustomButton(
                label: "Continue",
                onTap: () async {
                  number = FirebaseAuth.instance.currentUser.phoneNumber
                      .toString()
                      .substring(3);
                  await check();
                },
              )
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: LoadingWrapper(
        loading: isLoading,
        child: Container(
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    height: 200.0,
                    width: 300.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/logo.png'))),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                codesend
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Icon(Icons.phone),
                          title: Text(
                            number.toString(),
                          ),
                          // trailing: FlatButton(
                          //   child: Text("Edit"),
                          //   onPressed: () {
                          //     setState(() {
                          //       codesend = false;
                          //       otp = "";
                          //     });
                          //   },
                          // ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          validator: (value) {
                            if (value.isEmpty || value.length != 10) {
                              return 'invaild phone number';
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            number = val;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: 'Phone'),
                        ),
                      ),
                codesend
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          maxLength: 6,
                          onChanged: (val) {
                            otp = val;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "OTP"),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: codesend ? 40.0 : 20.0,
                ),
                CustomButton(
                  label: codesend ? "Verify OTP" : 'Login',
                  onTap: () async {
                    print("codesend");
                    print(codesend);
                    if (codesend) {
                      setState(() {
                        isLoading = true;
                      });
                      print("verification id");
                      print(verificationId);
                      print("smscode");
                      print(otp);
                      print("number");
                      print(number);
                      AuthCredential authcreds = PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: otp);
                      await FirebaseAuth.instance
                          .signInWithCredential(authcreds)
                          .then((userCred) async {
                        if (userCred != null) await check();
                      }).catchError((e) {
                        print("error");
                        print(e);
                        setState(() {
                          isLoading = false;
                        });
                        _scaffoldKey.currentState.showSnackBar(
                          new SnackBar(
                            content: Row(
                              children: [
                                new Text(
                                  "Wrong OTP",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            elevation: 6,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      });
                    } else {
                      if (_formKey.currentState.validate()) {
                        print("number");
                        print(number);
                        showAlertDialog(context);
                      } else {
                        print("Validation failed");
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          title: Text("We will be verifying the phone number",
              style: TextStyle(fontSize: 17)),
          content: Text(
            "+91 " + number,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          actions: [
            FlatButton(
              child: Text(
                "Edit",
                //    style: TextStyle(color: Colors.red.shade700, fontSize: 16.5),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
                child: Text(
                  "OK",
                  //    style: TextStyle(color: Colors.red.shade700, fontSize: 16.5),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  verifyPhone(number);
                })
          ],
        );
      },
    );
  }

  check() async {
    var result = await databaseService.userLogin(number);
    if (result == 0) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
      setState(() {
        isLoading = false;
      });
    } else if (result == 1) {
      var p = await utils.showMessageAlertBox(context, 'No vehicle associated',
          'There is no vehicle associated to this number, Please contact admin');

      await AuthService().signout();
      if (p == null || p != null) {
        setState(() {
          isLoading = false;
          codesend = false;
        });
      }
    } else if (result == 2) {
      var p = await utils.showMessageAlertBox(context, 'Breakdown',
          'This vehicle is in breakdown, Please contact admin');
      if (p == null || p != null) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> verifyPhone(phone) async {
    // showLoaderDialog(context);
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signin(authResult);
    };
    final PhoneVerificationFailed failed =
        (FirebaseAuthException authException) {
      setState(() {
        isLoading = false;
      });
      // Navigator.of(context, rootNavigator: true).pop();
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: Row(
          children: [
            new Text(
              "Error occured",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ));
      print("${authException.message}");
    };
    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        codesend = true;
        isLoading = false;
      });
      // Navigator.of(context, rootNavigator: true).pop();
      // Navigator.of(context).push(CupertinoPageRoute(
      //     builder: (context) => OTPScreen(
      //           verificationId: verificationId,
      //           phoneNumber: phone,
      //         )));
    };
    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verid) {
      this.verificationId = verid;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91" + phone,
      verificationCompleted: verified,
      verificationFailed: failed,
      codeSent: smsSent,
      timeout: const Duration(seconds: 0),
      codeAutoRetrievalTimeout: autoTimeout,
    );
  }
}
