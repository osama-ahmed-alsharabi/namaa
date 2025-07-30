import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';
import 'package:namaa/features/plan_page/plan_view.dart';
import 'package:namaa/features/your_monthly_budget/model/budget_item_model.dart';
import 'package:namaa/features/your_monthly_budget/view_model/cubit/monthly_budget_cubit.dart';
import 'package:namaa/features/your_monthly_budget/view_model/cubit/monthly_budget_state.dart';

class YourMonthlyBudgetView extends StatefulWidget {
  final bool? isEditing;
  const YourMonthlyBudgetView({super.key, this.isEditing});

  @override
  State<YourMonthlyBudgetView> createState() => _YourMonthlyBudgetViewState();
}

class _YourMonthlyBudgetViewState extends State<YourMonthlyBudgetView> {
  final Map<String, TextEditingController> _controllers = {};
  final _newCategoryController = TextEditingController();
  final _savingCategoryName = "الادخار";

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // أضف "الادخار" تلقائيًا إذا لم يكن موجودًا
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cubit = context.read<BudgetCubit>();
      final items = await cubit.getBudgetItems().first;
      final exists = items.any((item) => item.category == _savingCategoryName);
      if (!exists) {
        cubit.addBudgetItem(_savingCategoryName, 0);
      }
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    _newCategoryController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة فئة جديدة'),
          content: TextFieldFormWidget(
            controller: _newCategoryController,
            hint: 'أدخل اسم الفئة',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (_newCategoryController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _showAmountDialog(context, _newCategoryController.text);
                }
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showAmountDialog(BuildContext context, String category) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('أدخل المبلغ لـ $category'),
          content: TextFieldFormWidget(
            controller: amountController,
            hint: 'المبلغ',
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  context.read<BudgetCubit>().addBudgetItem(category, amount);
                  Navigator.pop(context);
                }
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetItem(BudgetItemModel item) {
    if (!_controllers.containsKey(item.id)) {
      _controllers[item.id] = TextEditingController(
        text: item.amount.toString(),
      );
    }

    final isSaving = item.category == _savingCategoryName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.category)),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFieldFormWidget(
              controller: _controllers[item.id]!,
              keyboardType: TextInputType.number,
              hint: 'المبلغ',
            ),
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              final newAmount =
                  double.tryParse(_controllers[item.id]!.text) ?? 0;
              context.read<BudgetCubit>().updateBudgetItem(item.id, newAmount);
            },
          ),
          if (!isSaving)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<BudgetCubit>().deleteBudgetItem(item.id);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<BudgetCubit, BudgetState>(
          listener: (context, state) {
            if (state is BudgetError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is BudgetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    " ميزانيتك الشهرية ",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "خطّط لميزانيتك، وابدأ بصناعة الفارق في نمائك المالي!",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomButtonWidget(
                            height: 60,
                            text: 'وزّع ميزانيتك حسب أولوياتك ',
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.brownColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                onPressed: () =>
                                    _showAddCategoryDialog(context),
                                icon: Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  StreamBuilder<List<BudgetItemModel>>(
                    stream: context.read<BudgetCubit>().getBudgetItems(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final budgetItems = snapshot.data ?? [];

                      // اجعل "الادخار" أول فئة دائمًا
                      budgetItems.sort((a, b) {
                        if (a.category == _savingCategoryName) return -1;
                        if (b.category == _savingCategoryName) return 1;
                        return 0;
                      });

                      return Column(
                        children: [
                          ...budgetItems.map(_buildBudgetItem).toList(),
                          SizedBox(height: 20),
                          if (budgetItems.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: CustomButtonWidget(
                                height: 60,
                                text: widget.isEditing ?? false
                                    ? "تأكيد"
                                    : "التالي",
                                onPressed: () {
                                  var confirm = widget.isEditing ?? false;
                                  if (confirm) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("تم تعديل بياناتك "),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlanView(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
