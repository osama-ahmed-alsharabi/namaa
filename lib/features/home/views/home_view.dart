// home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/utils/api_key_const.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_bottom_navigation_bar.dart';
import 'package:namaa/features/profile/views/profile_view.dart';
import 'package:namaa/main.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      final userId = userIdOfApp;
      if (userId == null) {
        emit(HomeError("المستخدم غير مسجل الدخول"));
        return;
      }

      // اجلب أحدث وثيقة من goals
      final goalsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (goalsSnapshot.docs.isEmpty) {
        emit(HomeError("لا توجد أهداف مالية محفوظة."));
        return;
      }

      final goalData = goalsSnapshot.docs.first.data();
      final monthlyIncome = (goalData['monthlyIncome'] ?? 0).toDouble();

      final prompt =
          '''
    أعطني رسالة تحفيزية قصيرة لمستخدم يحاول الادخار من دخله الشهري ($monthlyIncome). 
    استخدم لغة عربية سهلة وودّية.
    ''';

      final motivation = await _fetchMotivationalMessage(prompt);

      emit(
        HomeLoaded(
          monthlyIncome: monthlyIncome,
          motivationalMessage: motivation,
        ),
      );
    } catch (e) {
      emit(HomeError("خطأ أثناء تحميل البيانات: $e"));
    }
  }

  Future<String> _fetchMotivationalMessage(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiKeyConst.apiKey}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo-0125',
        'messages': [
          {
            'role': 'system',
            'content':
                'أنت مساعد مالي ذكي تقدم رسائل تحفيزية قصيرة باللغة العربية لمستخدمي التطبيق الذين يحاولون تحسين ميزانيتهم.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      }),
    );

    print('OpenAI response status: ${response.statusCode}');
    print('OpenAI response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return "أهلاً بك! لا تنسَ أن كل خطوة صغيرة تقربك من أهدافك."; // fallback
    }
  }
}
// home_state.dart

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final double monthlyIncome;
  final String motivationalMessage;

  HomeLoaded({required this.monthlyIncome, required this.motivationalMessage});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// home_view.dart

class HomeView extends StatefulWidget {
  final String? userId;
  const HomeView({super.key, this.userId});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _showBalance = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFEF9),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.brownColor),
              );
            } else if (state is HomeError) {
              return Center(child: Text(state.message));
            } else if (state is HomeLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileView(
                                  userIdOfApp: userIdOfApp!,
                                ),
                              ),
                            );
                          },
                          child: SvgPicture.asset(Assets.imagesUser),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showBalance = !_showBalance;
                            });
                          },
                          child: SvgPicture.asset(Assets.imagesEye),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            SystemNavigator.pop();
                          },
                          child: SvgPicture.asset(Assets.imagesLogout),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            Assets.imagesMessage,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.65,
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                state.motivationalMessage,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, left: 100),
                      child: Image.asset(Assets.imagesSliverHelloCharacter),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        children: [
                          Image.asset(Assets.imagesCard),
                          Positioned(
                            left: 15,
                            top: 55,
                            child: Row(
                              children: [
                                Text(
                                  _showBalance
                                      ? state.monthlyIncome.toStringAsFixed(2)
                                      : "*****",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 15),
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: SvgPicture.asset(
                                    Assets.imagesRyal,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CustomBottomNavigationBar(pageName: "home"),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
