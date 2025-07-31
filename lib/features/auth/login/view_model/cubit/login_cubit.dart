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
      userIdOfApp = userDoc.id;
      final userId = userDoc.id;
      imagesApp = await getCharacterImages();

      // final userData = userDoc.data();

      // تحقق من كلمة المرور
      // if (userData['password'] != password) {
      //   emit(LoginFailure('كلمة المرور غير صحيحة'));
      //   return;
      // }

      emit(LoginSuccess(userId: userId));
    } catch (e) {
      emit(LoginFailure('حدث خطأ: $e'));
    }
  }

  Future<int> getUserPoints(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return (doc.data()?['points'] as num? ?? 0).toInt();
    } catch (e) {
      print('Error getting user points: $e');
      return 0; // Return default value if error occurs
    }
  }

  Future<List<String>> getCharacterImages() async {
    final points = await getUserPoints(
      userIdOfApp!,
    ); // Assuming userIdOfApp is available

    if (points < 100) {
      return [
        'assets/images/b_hello_character.PNG',
        'assets/images/b_small_character.PNG',
      ];
    } else if (points < 250) {
      return [
        'assets/images/s_hello_character.PNG',
        'assets/images/s_small_character.PNG',
      ];
    } else {
      return [
        'assets/images/g_hello_character.png',
        'assets/images/g_small_character.png',
      ];
    }
  }
}
