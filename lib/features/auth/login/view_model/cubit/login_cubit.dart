import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa/cores/utils/api_key_const.dart';
import 'package:namaa/main.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loginWithPhoneNumber(String phoneNumber, String password) async {
    emit(LoginLoading());
    try {
      // تحقق من وجود المستخدم
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: "+966$phoneNumber")
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        emit(LoginFailure('رقم الجوال غير مسجل'));
        return;
      }

      final userDoc = querySnapshot.docs.first;
      // final userData = userDoc.data();

      // تحقق من كلمة المرور
      // if (userData['password'] != password) {
      //   emit(LoginFailure('كلمة المرور غير صحيحة'));
      //   return;
      // }
      userIdOfApp = userDoc.id;
      final userId = userDoc.id;
      emit(LoginSuccess(userId: userId));
    } catch (e) {
      emit(LoginFailure('حدث خطأ: $e'));
    }
  }
}
