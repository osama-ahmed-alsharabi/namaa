import 'package:flutter/material.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';

class GoalView extends StatelessWidget {
  const GoalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: Column(
        children: [
          Text("هدفك مع نَماء "),
          SizedBox(height: 10,)
        ,TextFieldFormWidget(hint: 'وش الهدف الي تبي توصلة؟')
        ],
      )),
    );
  }
}