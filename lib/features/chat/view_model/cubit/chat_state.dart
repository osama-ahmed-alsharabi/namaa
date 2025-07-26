
// cubit/chat_state.dart
part of 'chat_cubit.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final num monthlyIncome;
  final List<Map<String, dynamic>> budgetItems;
  final List<Map<String, dynamic>> goalsData;
  final num totalExpenses;
  final num totalSavings;
  final bool isLoading;

  const ChatLoaded({
    required this.messages,
    required this.monthlyIncome,
    required this.budgetItems,
    required this.goalsData,
    required this.totalExpenses,
    required this.totalSavings,
    this.isLoading = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    num? monthlyIncome,
    List<Map<String, dynamic>>? budgetItems,
    List<Map<String, dynamic>>? goalsData,
    num? totalExpenses,
    num? totalSavings,
    bool? isLoading,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      budgetItems: budgetItems ?? this.budgetItems,
      goalsData: goalsData ?? this.goalsData,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalSavings: totalSavings ?? this.totalSavings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
