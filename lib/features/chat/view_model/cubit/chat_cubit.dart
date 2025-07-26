
// cubit/chat_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _apiKey = "";
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  ChatCubit() : super(ChatInitial()) {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      emit(ChatLoading());

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(ChatError('المستخدم غير مسجل الدخول'));
        return;
      }

      final budgetSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_budget')
          .orderBy('createdAt', descending: true)
          .get();

      final goalsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .get();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final monthlyIncome = userDoc.data()?['monthlyIncome'] ?? 0;

      double totalExpenses = 0;
      double totalSavings = 0;

      final budgetItems = budgetSnapshot.docs.map((doc) {
        final data = doc.data();
        if (data['category'] == 'Savings') {
          totalSavings += (data['amount'] as num).toDouble();
        } else {
          totalExpenses += (data['amount'] as num).toDouble();
        }
        return data;
      }).toList();

      final goalsData = goalsSnapshot.docs.map((doc) => doc.data()).toList();

      final introPrompt = '''
لدى المستخدم الوضع المالي التالي:
- الدخل الشهري: $monthlyIncome
- مجموع المصاريف: $totalExpenses
- مجموع الادخار: $totalSavings

فئات الميزانية:
${budgetItems.take(5).map((item) => "- ${item['category']}: ${item['amount']}").join('\n')}

الأهداف المالية:
${goalsData.map((goal) => "- ${goal['goalDescription']}: الحد اليومي للإنفاق ${goal['dailyExpense']}").join('\n')}

قدّم نفسك كمساعد مالي وابدأ المحادثة بالعربية بطريقة ودودة ومختصرة.
''';

      final initialMessage = await _generateAIResponse(introPrompt);

      emit(ChatLoaded(
        messages: [
          ChatMessage(
            text: initialMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
        monthlyIncome: monthlyIncome,
        budgetItems: budgetItems,
        goalsData: goalsData,
        totalExpenses: totalExpenses,
        totalSavings: totalSavings,
      ));
    } catch (e) {
      emit(ChatError('فشل تحميل المحادثة: $e'));
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      final currentState = state;
      if (currentState is! ChatLoaded) return;

      final userMessage = ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      emit(currentState.copyWith(
        messages: [...currentState.messages, userMessage],
        isLoading: true,
      ));

      final contextPrompt = '''
بيانات المستخدم:
- الدخل الشهري: ${currentState.monthlyIncome}
- المصاريف: ${currentState.totalExpenses}
- الادخار: ${currentState.totalSavings}

فئات الميزانية:
${currentState.budgetItems.take(5).map((item) => "- ${item['category']}: ${item['amount']}").join('\n')}

أهدافه:
${currentState.goalsData.map((goal) => "- ${goal['goalDescription']}: حد إنفاق يومي ${goal['dailyExpense']}").join('\n')}

تاريخ المحادثة:
${currentState.messages.map((m) => m.isUser ? 'مستخدم: ${m.text}' : 'مساعد: ${m.text}').join('\n')}

رسالة المستخدم الحالية: "$message"

رد كمساعد مالي باللغة العربية باقتراحات عملية ومباشرة.
''';

      final aiResponse = await _generateAIResponse(contextPrompt);

      final aiMessage = ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(currentState.copyWith(
        messages: [...currentState.messages, userMessage, aiMessage],
        isLoading: false,
      ));
    } catch (e) {
      emit(ChatError('فشل إرسال الرسالة: $e'));
    }
  }

  Future<String> _generateAIResponse(String prompt) async {
    final uri = Uri.parse(_apiUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo-0125',
      'messages': [
        {
          'role': 'system',
          'content': 'أنت مساعد مالي ذكي تتحدث فقط باللغة العربية، تساعد المستخدم في إدارة دخله ومصروفاته وتحقيق أهدافه المالية بنصائح دقيقة وعملية.',
        },
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'temperature': 0.7,
    });

    for (int attempt = 0; attempt < 3; attempt++) {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 3));
      } else {
        throw Exception('فشل الرد: ${response.statusCode}');
      }
    }

    throw Exception('تم تجاوز المحاولات المسموحة بعد ظهور الخطأ 429');
  }
}
