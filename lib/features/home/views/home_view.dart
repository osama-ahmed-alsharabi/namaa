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
  HomeCubit() : super(HomeInitial()) {
    _initMonthlyIncomeStream();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<double>? _monthlyIncomeStream;
  String _motivationalMessage = "أهلاً بك! لا تنسَ أن كل خطوة صغيرة تقربك من أهدافك.";

  Stream<double>? get monthlyIncomeStream => _monthlyIncomeStream;
  String get motivationalMessage => _motivationalMessage;

  void _initMonthlyIncomeStream() {
    final userId = userIdOfApp;
    if (userId == null) {
      emit(HomeError("المستخدم غير مسجل الدخول"));
      return;
    }

    _monthlyIncomeStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        emit(HomeError("لا توجد أهداف مالية محفوظة."));
        return 0.0;
      }

      final goalData = snapshot.docs.first.data();
      final monthlyIncome = (goalData['monthlyIncome'] ?? 0).toDouble();

      await _updateMotivationalMessage(monthlyIncome);
      return monthlyIncome;
    });
  }

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      // Trigger stream update

   
      emit(HomeLoaded());
    } catch (e) {
      emit(HomeError("خطأ أثناء تحميل البيانات: $e"));
    }
  }

  Future<void> _updateMotivationalMessage(double monthlyIncome) async {
    try {
      final prompt = '''
      أعطني رسالة تحفيزية قصيرة لمستخدم يحاول الادخار من دخله الشهري ($monthlyIncome ريال).
      الرسالة يجب أن تكون باللغة العربية الفصحى السهلة،
      لا تزيد عن جملتين، وركّز على التشجيع على الاستمرار في الادخار.
      ''';

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
              'content': 'أنت مساعد مالي ذكي تقدم نصائح مالية قصيرة باللغة العربية.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _motivationalMessage = data['choices'][0]['message']['content'];
        emit(HomeLoaded());
      }
    } catch (e) {
      _motivationalMessage = "استمر في توفيرك اليومي، فكل ريال يدخر يقربك من أهدافك!";
    }
  }
}

// home_state.dart
@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {}

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
      backgroundColor: const Color(0xffFFFEF9),
      body: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.brownColor),
              );
            }

            return Column(
              children: [
                // Header with user controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileView(
                              userIdOfApp: userIdOfApp!,
                            ),
                          ),
                        ),
                        child: SvgPicture.asset(Assets.imagesUser),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: SvgPicture.asset(
                          Assets.imagesEye,
                          color: _showBalance ? Colors.blue : null,
                        ),
                        onPressed: () => setState(() => _showBalance = !_showBalance),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: SvgPicture.asset(Assets.imagesLogout),
                        onPressed: () => SystemNavigator.pop(),
                      ),
                    ],
                  ),
                ),

                // Motivational message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
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
                            context.read<HomeCubit>().motivationalMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Character image
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, left: 100),
                    child: imagesApp.isEmpty ? SizedBox(): Image.asset(imagesApp[0]  ),
                  ),
                ),

                // Monthly income card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StreamBuilder<double?>(
                      stream: context.read<HomeCubit>().monthlyIncomeStream,
                      builder: (context, snapshot) {
                        final monthlyIncome = snapshot.data ?? 0.0;
                        final formattedIncome = monthlyIncome.toStringAsFixed(2);

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              Assets.imagesCard,
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              fit: BoxFit.fitWidth,
                            ),
                            Positioned(
                              top: 55,
                              left: 15,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _showBalance ? formattedIncome : "•••••",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: SvgPicture.asset(
                                      Assets.imagesRyal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const CustomBottomNavigationBar(pageName: "home"),
              ],
            );
          },
        ),
      ),
    );
  }
}