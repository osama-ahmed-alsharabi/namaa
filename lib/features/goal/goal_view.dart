import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';
import 'package:namaa/features/goal/view_model/cubit/goal_cubit.dart';
import 'package:namaa/features/your_monthly_budget/your_monthly_budget_view.dart';

class GoalView extends StatefulWidget {
  const GoalView({super.key});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    _incomeController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoalCubit(),
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: BlocListener<GoalCubit, GoalState>(
              listener: (context, state) {
                if (state is GoalSubmitted) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => YourMonthlyBudgetView(goal: state.goal),
                  //   ),
                  // );
                } else if (state is GoalError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "هدفك مع نَماء ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextFieldFormWidget(
                        controller: _goalController,
                        hint: 'وش الهدف الي تبي توصلة؟',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الهدف';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 15),
                    Text(
                      "دخلك الشهري ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextFieldFormWidget(
                        controller: _incomeController,
                        hint: "كم دخلك شهريا",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الدخل الشهري';
                          }
                          if (double.tryParse(value) == null) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 15),
                    Text(
                      "مصروفك اليومي",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextFieldFormWidget(
                        controller: _expenseController,
                        hint: "كم تصرف كل يوم",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال المصروف اليومي';
                          }
                          if (double.tryParse(value) == null) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80.0),
                      child: BlocBuilder<GoalCubit, GoalState>(
                        builder: (context, state) {
                          return CustomButtonWidget(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await context.read<GoalCubit>().submitGoal(
                                    goalDescription: _goalController.text,
                                    monthlyIncome: double.parse(
                                      _incomeController.text,
                                    ),
                                    dailyExpense: double.parse(
                                      _expenseController.text,
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          YourMonthlyBudgetView(),
                                    ),
                                  );
                                } catch (e) {
                                  // TODO
                                }
                              }
                            },
                            text: "التالي",
                            // isLoading: state is GoalLoading,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
