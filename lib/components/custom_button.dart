import 'package:flutter/material.dart';
import '../constant/constant.dart';

class CustomButton extends StatelessWidget {
  final Function onTap;
  final String label;
  CustomButton({this.label = '', this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 40.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kThemeBlueColor, Colors.white],
            ),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                  offset: Offset(1, 3),
                  blurRadius: 4.0,
                  color: Colors.blueGrey.shade100)
            ]),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
