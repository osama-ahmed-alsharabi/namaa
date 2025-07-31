import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/main.dart';

// ------------------ Cubit & State ------------------

class GameCubit extends Cubit<GameState> {
  final String userId;
  GameCubit(this.userId) : super(GameInitial());

  Future<void> fetchQuestion(int day) async {
    emit(GameLoading());
    try {
      final budgetSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('monthly_budget')
          .get();

      if (budgetSnap.docs.isEmpty) {
        emit(GameError('لا توجد بيانات ميزانية متاحة'));
        return;
      }

      final budgetItems = budgetSnap.docs.map((d) => d.data()).toList();
      final dailyTargets = _calculateDailyTargets(budgetItems, day);

      final pointsPerQuestion = _calculatePointsPerQuestion(
        dailyTargets.length,
      );

      emit(GameShowQuestions(dailyTargets, day, pointsPerQuestion));
    } catch (e) {
      log('Error fetching question: $e');
      emit(GameError('حدث خطأ في جلب الأسئلة.'));
    }
  }

  Map<String, num> _calculateDailyTargets(
    List<Map<String, dynamic>> budgetItems,
    int day,
  ) {
    final targets = <String, num>{};
    for (final item in budgetItems) {
      final category = item['category'] as String;
      final amount = item['amount'] as num;
      targets[category] = (amount / 30).round();
    }
    return targets;
  }

  double _calculatePointsPerQuestion(int questionsCount) {
    return questionsCount > 0 ? 10 / questionsCount : 0;
  }

  Future<void> submitAnswers(int day, Map<String, num> answers) async {
    try {
      final pointsResult = await _calculatePoints(day, answers);
      final totalSpent = answers.values.fold(0, (sum, amount) => sum + amount.toInt());

      await _saveResults(day, answers, pointsResult);
      await _updateMonthlyIncome(totalSpent);

      emit(GameAnswered(pointsResult['totalPoints'] as int));
    } catch (e) {
      log('Error submitting answers: $e');
      emit(GameError('حدث خطأ في حفظ الإجابات.'));
    }
  }

Future<void> _updateMonthlyIncome(num amountToDeduct) async {
  try {
    final goalsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('goals');

    // First get the most recent goal document
    final querySnapshot = await goalsRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      log('No goals found for user');
      return;
    }

    final lastGoalDoc = querySnapshot.docs.first;
    
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final goalDoc = await transaction.get(lastGoalDoc.reference);
      if (goalDoc.exists) {
        final currentIncome = goalDoc.data()?['monthlyIncome'] as num? ?? 0;
        final newIncome = currentIncome - amountToDeduct;
        
        // Ensure the income doesn't go negative
        transaction.update(lastGoalDoc.reference, {
          'monthlyIncome': newIncome > 0 ? newIncome : 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  } catch (e) {
    log('Error updating monthly income: $e');
    throw Exception('Failed to update monthly income');
  }
}
  Future<Map<String, dynamic>> _calculatePoints(
    int day,
    Map<String, num> answers,
  ) async {
    final budgetSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('monthly_budget')
        .get();

    final budgetItems = budgetSnap.docs.map((d) => d.data()).toList();
    final dailyTargets = _calculateDailyTargets(budgetItems, day);

    double totalPoints = 0;
    final Map<String, dynamic> pointsDetails = {};
    final double pointsPerQuestion = _calculatePointsPerQuestion(
      dailyTargets.length,
    );

    dailyTargets.forEach((category, target) {
      final userAnswer = answers[category] ?? 0;
      double percentage = (userAnswer / target) * 100;

      double points = 0;
      if (percentage >= 100) {
        points = pointsPerQuestion;
      } else if (percentage >= 50) {
        points = pointsPerQuestion * 0.5;
      }

      pointsDetails[category] = {
        'target': target,
        'actual': userAnswer,
        'percentage': percentage.round(),
        'points': points,
      };
      totalPoints += points;
    });

    totalPoints = totalPoints > 10 ? 10 : totalPoints;

    return {'totalPoints': totalPoints.round(), 'details': pointsDetails};
  }

  Future<void> _saveResults(
    int day,
    Map<String, num> answers,
    Map<String, dynamic> pointsResult,
  ) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final dailyResultsRef = userRef.collection('daily_results').doc('day_$day');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userRef, {
        'points': FieldValue.increment(pointsResult['totalPoints'] as int),
        'answeredDays': FieldValue.increment(1),
        'lastAnswered': FieldValue.serverTimestamp(),
      });

      transaction.set(dailyResultsRef, {
        'day': day,
        'date': FieldValue.serverTimestamp(),
        'answers': answers,
        'pointsDetails': pointsResult['details'],
        'totalPoints': pointsResult['totalPoints'],
        'maxPossiblePoints': 10,
        'totalSpent': answers.values.fold(0, (sum, amount) => sum + amount.toInt()),
      });
    });
  }
}

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameShowQuestions extends GameState {
  final Map<String, num> dailyTargets;
  final int day;
  final double pointsPerQuestion;
  GameShowQuestions(this.dailyTargets, this.day, this.pointsPerQuestion);
}

class GameAnswered extends GameState {
  final int pointsEarned;
  GameAnswered(this.pointsEarned);
}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}

// ------------------ Question Dialog ------------------
class QuestionDialog extends StatefulWidget {
  final GameCubit cubit;
  final int day;
  final Map<String, num> dailyTargets;
  final double pointsPerQuestion;

  const QuestionDialog({
    Key? key,
    required this.cubit,
    required this.day,
    required this.dailyTargets,
    required this.pointsPerQuestion,
  }) : super(key: key);

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final Map<String, TextEditingController> _answerControllers = {};
  int _currentQuestionIndex = 0;
  late List<String> _categories;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _categories = widget.dailyTargets.keys.toList();
    for (final category in _categories) {
      _answerControllers[category] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitAnswers() async {
    if (_isSubmitting) return;

    final answers = <String, num>{};
    bool allValid = true;

    for (final category in _categories) {
      final value = _answerControllers[category]!.text.trim();
      if (value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء إدخال قيمة لـ $category')),
        );
        allValid = false;
        break;
      }
      answers[category] = num.tryParse(value) ?? 0;
    }

    if (allValid) {
      setState(() => _isSubmitting = true);
      try {
        await widget.cubit.submitAnswers(widget.day, answers);
        if (mounted) Navigator.of(context).pop(true);
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = _categories[_currentQuestionIndex];
    final dailyTarget = widget.dailyTargets[currentCategory]!;
    final maxPointsForQuestion = widget.pointsPerQuestion;

    return AlertDialog(
      title: Text(
        'اليوم ${widget.day + 1} - (${_currentQuestionIndex + 1}/${_categories.length})',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSubmitting) Center(child: CircularProgressIndicator()),
            if (!_isSubmitting) ...[
              Text(
                'المستهدف اليوم لـ $currentCategory: $dailyTarget ريال',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'النقاط المحتملة: ${maxPointsForQuestion.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.green),
              ),
              SizedBox(height: 12),
              Text('كم أنفقت/ادخرت اليوم على $currentCategory؟'),
              SizedBox(height: 20),
              TextField(
                controller: _answerControllers[currentCategory],
                decoration: InputDecoration(
                  hintText: "أدخل المبلغ بالريال",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
      actions: _isSubmitting
          ? [Center(child: CircularProgressIndicator())]
          : [
              if (_currentQuestionIndex > 0)
                TextButton(
                  onPressed: () => setState(() => _currentQuestionIndex--),
                  child: Text("السابق"),
                ),
              if (_currentQuestionIndex < _categories.length - 1)
                ElevatedButton(
                  onPressed: () => setState(() => _currentQuestionIndex++),
                  child: Text("التالي"),
                )
              else
                ElevatedButton(
                  onPressed: _submitAnswers,
                  child: Text("إرسال الإجابات"),
                ),
            ],
    );
  }
}

// ------------------ Main GameView ------------------
class GameView extends StatefulWidget {
  final int totalDays = 30;
  final double betweenDots = 200.0;
  final List<String> imagesList = [
    Assets.images1,
    Assets.images2,
    Assets.images3,
    Assets.images4,
    Assets.images5,
    Assets.images6,
    Assets.images7,
    Assets.images8,
    Assets.images9,
    Assets.images10,
    Assets.images11,
    Assets.images12,
    Assets.images13,
    Assets.images14,
    Assets.images15,
    Assets.images16,
    Assets.images17,
    Assets.images18,
    Assets.images19,
    Assets.images20,
    Assets.images9,
    Assets.images9,
    Assets.images9,
    Assets.images9,
    Assets.images9,
    Assets.images9,
    Assets.images9,
    Assets.images9,
    Assets.images9,
    Assets.images9,
  ];

  GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  int points = 0;
  int answeredDays = 4;
  bool loadingData = true;
  int currentDay = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _characterTopPosition = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _calculateCurrentDay();
    _fetchUserProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateCurrentDay() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    currentDay = now.difference(startDate).inDays;
  }

  Future<void> _fetchUserProgress() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userIdOfApp)
        .get();
    final data = userDoc.data();
    setState(() {
      points = (data?['points'] ?? 0) as int;
      answeredDays = (data?['answeredDays'] ?? 0) as int;
      loadingData = false;
      _characterTopPosition = 30 + (answeredDays * widget.betweenDots);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

  void _refreshData() async {
    setState(() => loadingData = true);
    await _fetchUserProgress();
  }

  @override
  Widget build(BuildContext context) {
    final double maxTop = (widget.totalDays - 1) * widget.betweenDots + 30;
    final activeDayIndex = answeredDays < widget.totalDays
        ? answeredDays
        : widget.totalDays - 1;
    final imageTopPosition =
        maxTop - (activeDayIndex * widget.betweenDots) + 160;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double centerLinePosition = screenWidth / 2;
    final double imageOffset = 100;

    return BlocProvider(
      create: (_) => GameCubit(userIdOfApp!),
      child: Scaffold(
        backgroundColor: Color(0xffFFFEF9),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xffFFFEF9),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'النقاط: $points',
            style: const TextStyle(color: Color(0xFF25386A)),
          ),
        ),
        body: loadingData
            ? const Center(child: CircularProgressIndicator())
            : BlocConsumer<GameCubit, GameState>(
                listener: (context, state) {
                  if (state is GameAnswered) {
                    _animationController.forward(from: 0);
                    _refreshData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "تمت إضافة ${state.pointsEarned} نقاط من أصل 10",
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    controller: _controller,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: widget.totalDays * widget.betweenDots + 100,
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: AlignmentDirectional.center,
                              children: [
                                Positioned(
                                  left: centerLinePosition - 3,
                                  top: 30,
                                  bottom: 30,
                                  child: Container(
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[300],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),

                                if (answeredDays < widget.totalDays)
                                  Positioned(
                                    left: centerLinePosition - 30,
                                    top: imageTopPosition,
                                    child: Image.asset(
                                     imagesApp[0],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                ...List.generate(widget.totalDays, (i) {
                                  final double top =
                                      maxTop - i * widget.betweenDots;
                                  bool isAnswered = i < answeredDays;
                                  bool isToday = i == currentDay;
                                  bool isPastDay = i < currentDay;
                                  bool isFutureDay = i > currentDay;

                                  Color dotColor = Colors.brown[400]!;
                                  if (isAnswered) {
                                    dotColor = Colors.green;
                                  } else if (isToday) {
                                    dotColor = Colors.amber;
                                  }

                                  return Positioned(
                                    left: centerLinePosition - 25,
                                    top: maxTop - (i * widget.betweenDots) + 200,
                                    child: GestureDetector(
                                      onTap: isToday && !isAnswered
                                          ? () async {
                                              final cubit =
                                                  BlocProvider.of<GameCubit>(
                                                    context,
                                                  );
                                              await cubit.fetchQuestion(i);
                                              if (cubit.state
                                                  is GameShowQuestions) {
                                                final state =
                                                    cubit.state
                                                        as GameShowQuestions;
                                                final result = await showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      QuestionDialog(
                                                        cubit: cubit,
                                                        day: i,
                                                        dailyTargets:
                                                            state.dailyTargets,
                                                        pointsPerQuestion: state
                                                            .pointsPerQuestion,
                                                      ),
                                                );
                                                if (result == true) {
                                                  _refreshData();
                                                }
                                              }
                                            }
                                          : isFutureDay
                                          ? () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "لا يمكنك الإجابة على أيام مستقبلية",
                                                  ),
                                                ),
                                              );
                                            }
                                          : isPastDay && !isAnswered
                                          ? () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "لقد فاتك موعد الإجابة على هذا اليوم",
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: dotColor,
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                ...List.generate(widget.totalDays, (i) {
                                  final double top =
                                      maxTop - i * widget.betweenDots;
                                  final String imgPath = widget
                                      .imagesList[i % widget.imagesList.length];
                                  final bool isEven = i % 2 == 0;
                                  return Positioned(
                                    left: isEven
                                        ? centerLinePosition +
                                              imageOffset -
                                              50
                                        : centerLinePosition -
                                              imageOffset -
                                              80,
                                    top: maxTop - (i * widget.betweenDots) + 160,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 5,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        imgPath,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 60),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}