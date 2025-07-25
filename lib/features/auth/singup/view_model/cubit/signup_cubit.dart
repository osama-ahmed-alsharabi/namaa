import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_cubit.freezed.dart';
part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SignupCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const SignupState.initial());

  Future<void> signUpWithPhone({
    required String phoneNumber,
    required String name,
    required String age,
    required String gender,
    required String password,
    required String confirmPassword,
  }) async {
    emit(const SignupState.loading());

    // Validate inputs
    if (name.isEmpty || age.isEmpty || gender.isEmpty || phoneNumber.isEmpty) {
      emit(const SignupState.error('Please fill all fields'));
      return;
    }

    if (password != confirmPassword) {
      emit(const SignupState.error('Passwords do not match'));
      return;
    }

    if (password.length < 6) {
      emit(const SignupState.error('Password must be at least 6 characters'));
      return;
    }

    try {
      // Format phone number (assuming Saudi numbers)
      final formattedPhone = phoneNumber.startsWith('+966') 
          ? phoneNumber 
          : '+966${phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')}';

      // Send verification code
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto sign-in on Android devices
          await _auth.signInWithCredential(credential);
          await _completeSignUp(name, age, gender, password);
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(SignupState.error(e.message ?? 'Verification failed'));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(SignupState.codeSent(
            verificationId: verificationId,
            phoneNumber: formattedPhone,
            name: name,
            age: age,
            gender: gender,
            password: password,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
        },
      );
    } catch (e) {
      emit(SignupState.error(e.toString()));
    }
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String name,
    required String age,
    required String gender,
    required String password,
  }) async {
    emit(const SignupState.loading());

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      await _completeSignUp(name, age, gender, password);
    } catch (e) {
      emit(SignupState.error('Invalid OTP code'));
    }
  }

  Future<void> _completeSignUp(
    String name,
    String age,
    String gender,
    String password,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const SignupState.error('User not found'));
        return;
      }

      // Update user display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'age': age,
        'gender': gender,
        'phone': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(const SignupState.success());
    } catch (e) {
      emit(SignupState.error(e.toString()));
    }
  }
}