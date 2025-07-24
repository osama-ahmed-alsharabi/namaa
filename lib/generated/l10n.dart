// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `تسجيل الدخول `
  String get login {
    return Intl.message('تسجيل الدخول ', name: 'login', desc: '', args: []);
  }

  /// `اسم المستخدم`
  String get username {
    return Intl.message('اسم المستخدم', name: 'username', desc: '', args: []);
  }

  /// `كلمة المرور`
  String get password {
    return Intl.message('كلمة المرور', name: 'password', desc: '', args: []);
  }

  /// `اللغة`
  String get language {
    return Intl.message('اللغة', name: 'language', desc: '', args: []);
  }

  /// `الانجليزية`
  String get english {
    return Intl.message('الانجليزية', name: 'english', desc: '', args: []);
  }

  /// `العربية`
  String get arabic {
    return Intl.message('العربية', name: 'arabic', desc: '', args: []);
  }

  /// `رقم الهاتف`
  String get phone_number {
    return Intl.message('رقم الهاتف', name: 'phone_number', desc: '', args: []);
  }

  /// `البريد الالكتروني`
  String get email {
    return Intl.message('البريد الالكتروني', name: 'email', desc: '', args: []);
  }

  /// `تأكيد كلمة المرور`
  String get confirm_password {
    return Intl.message(
      'تأكيد كلمة المرور',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل`
  String get register {
    return Intl.message('تسجيل', name: 'register', desc: '', args: []);
  }

  /// `نسيت كلمة المرور؟`
  String get forget_password {
    return Intl.message(
      'نسيت كلمة المرور؟',
      name: 'forget_password',
      desc: '',
      args: [],
    );
  }

  /// `كلمة المرور الجديدة`
  String get new_password {
    return Intl.message(
      'كلمة المرور الجديدة',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد كلمة المرور الجديدة`
  String get new_password_confirmation {
    return Intl.message(
      'تأكيد كلمة المرور الجديدة',
      name: 'new_password_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `ليس لديك حساب مسجل ؟`
  String get you_dont_have_an_account {
    return Intl.message(
      'ليس لديك حساب مسجل ؟',
      name: 'you_dont_have_an_account',
      desc: '',
      args: [],
    );
  }

  /// `إنشاء حساب `
  String get create_an_account {
    return Intl.message(
      'إنشاء حساب ',
      name: 'create_an_account',
      desc: '',
      args: [],
    );
  }

  /// ` الاسم`
  String get name {
    return Intl.message(' الاسم', name: 'name', desc: '', args: []);
  }

  /// `العمر`
  String get age {
    return Intl.message('العمر', name: 'age', desc: '', args: []);
  }

  /// `الجنس`
  String get gender {
    return Intl.message('الجنس', name: 'gender', desc: '', args: []);
  }

  /// `تأكيد رقم الهاتف`
  String get verify_phone {
    return Intl.message(
      'تأكيد رقم الهاتف',
      name: 'verify_phone',
      desc: '',
      args: [],
    );
  }

  /// `ادخل رمز التحقق`
  String get enter_verification_code {
    return Intl.message(
      'ادخل رمز التحقق',
      name: 'enter_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد`
  String get verify {
    return Intl.message('تأكيد', name: 'verify', desc: '', args: []);
  }

  /// `تم ارسال الرمز الى `
  String get sent_to {
    return Intl.message(
      'تم ارسال الرمز الى ',
      name: 'sent_to',
      desc: '',
      args: [],
    );
  }

  /// `اعادة ارسال الرمز`
  String get resend_code {
    return Intl.message(
      'اعادة ارسال الرمز',
      name: 'resend_code',
      desc: '',
      args: [],
    );
  }

  /// `التالي`
  String get next {
    return Intl.message('التالي', name: 'next', desc: '', args: []);
  }

  /// `رمز التحقق`
  String get verification_code {
    return Intl.message(
      'رمز التحقق',
      name: 'verification_code',
      desc: '',
      args: [],
    );
  }

  /// `ادخل رمز التحقق`
  String get enter_your_code {
    return Intl.message(
      'ادخل رمز التحقق',
      name: 'enter_your_code',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
