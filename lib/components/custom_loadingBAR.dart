import 'package:flutter/material.dart';
import 'package:loading/indicator/line_scale_pulse_out_indicator.dart';
import 'package:loading/loading.dart';
import '../constant/constant.dart';

class CustomLoadingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    offset: Offset(10, 10),
                    blurRadius: 13.0,
                    color: Colors.blueGrey.shade50),
                BoxShadow(
                    offset: Offset(-10, -10),
                    blurRadius: 13.0,
                    color: Colors.blueGrey.shade50),
              ]),
          child: Loading(
            indicator: LineScalePulseOutIndicator(),
            color: kThemeBlueColor,
            size: 50.0,
          ),
        ),
      ],
    );
  }
}
