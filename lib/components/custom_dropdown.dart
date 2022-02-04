import 'package:flutter/material.dart';
import '../constant/constant.dart';

class CustomDropdown extends StatelessWidget {
  final List<DropdownMenuItem> dropList;
  final Function onSelect;
  final String value;
  final String initial;
  CustomDropdown(
      {@required this.dropList,
      @required this.onSelect,
      @required this.value,
      this.initial = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
      child: DropdownButton(
//        value: Container(child: Text('Value 1')),
        items: dropList,
        value: value,
        hint: Text(initial),
        onChanged: (val) {
          if (val != initial) {
            onSelect(val);
          }
        },
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: kThemeBlueColor,
        ),
      ),
    );
  }
}
