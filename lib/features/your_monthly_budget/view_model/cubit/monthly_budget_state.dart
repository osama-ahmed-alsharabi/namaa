
// budget_state.da
import 'package:namaa/features/your_monthly_budget/model/budget_item_model.dart';

abstract class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetSuccess extends BudgetState {
  final String message;

  BudgetSuccess(this.message);
}

class BudgetError extends BudgetState {
  final String message;

  BudgetError(this.message);
}

class BudgetLoaded extends BudgetState {
  final List<BudgetItemModel> budgetItems;

  BudgetLoaded(this.budgetItems);
}