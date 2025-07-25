// features/auth/login/cubit/login_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loginWithPhoneNumber(String phoneNumber, String password) async {
    emit(LoginLoading());
    try {
      // First, verify the phone number exists in users collection
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: "+966$phoneNumber")
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        emit(LoginFailure('رقم الجوال ليس مسجل'));
        return;
      }

      final userDoc = querySnapshot.docs.first;
      // final userData = userDoc.data();

      // Verify password (assuming you have a password field)
      // if (userData['password'] != password) {
      //   emit(LoginFailure('Incorrect password'));
      //   return;
      // }

      // If you want to use Firebase Phone Auth (optional)
      // await _verifyPhoneNumber(phoneNumber);

      emit(LoginSuccess(userId: userDoc.id));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  // Optional: If you want to use Firebase Phone Auth verification
  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+966$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(LoginFailure(e.message ?? 'Verification failed'));
      },
      codeSent: (String verificationId, int? resendToken) {
        // You might want to handle OTP code sending here
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}