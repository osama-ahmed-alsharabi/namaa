import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/features/onboarding/onboarding_view.dart';
import 'package:namaa/main.dart';

class DeleteAccountView extends StatelessWidget {
  const DeleteAccountView({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // 1. حذف وثيقة المستخدم من Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userIdOfApp)
          .delete();

      // 2. حذف الحساب من Firebase Auth (إذا كان مسجلاً حاليًا)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }

      // 3. عرض رسالة نجاح
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الحساب بنجاح')));

      // 4. إعادة المستخدم إلى شاشة تسجيل الدخول مثلاً
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء حذف الحساب: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                textAlign: TextAlign.center,
                "حذف الحساب ",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(Assets.imagesAttentionStop),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  textAlign: TextAlign.center,
                  "عليك أن تعلم ان حذف حسابك سيؤدي إلى حذفه بشكل نهائي ولا يمكن التراجع عن هذا الإجراء.",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: CustomButtonWidget(
                  color: const Color(0xff6E0909),
                  text: "حذف الحساب",
                  onPressed: () => _deleteAccount(context),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
