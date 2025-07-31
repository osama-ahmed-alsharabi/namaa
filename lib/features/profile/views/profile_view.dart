import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa/cores/utils/app_colors.dart';

class ProfileView extends StatefulWidget {
  final String userIdOfApp;
  const ProfileView({super.key, required this.userIdOfApp});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  String gender = 'أنثى'; // الافتراضي

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userIdOfApp)
        .get();

    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      gender = data['gender'] ?? 'أنثى';
    }
    setState(() => isLoading = false);
  }

  Future<void> updateProfile() async {
    setState(() => isSaving = true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userIdOfApp)
        .update({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'age': _ageController.text.trim(),
      'gender': gender,
    });
    setState(() => isSaving = false);

    // رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم تحديث الملف الشخصي بنجاح!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFEF9),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ملفك الشخصي "),
        backgroundColor: const Color(0xffFFFEF9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(
              color: AppColors.brownColor,
            ))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Banner اسم وصورة رمزية
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.brownColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                         
                          const SizedBox(width: 6),
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: Icon(Icons.person, size: 32, color: Color(0xFFBDA876)),
                          ),
                          SizedBox(width: 15,),
                           Text(
                            _nameController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // حقول البيانات
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("الاسم", textAlign: TextAlign.right),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),

                          const Text("رقم الجوال", textAlign: TextAlign.right),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              // الجنس
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("الجنس"),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: gender,
                                          items: ['أنثى', 'ذكر'].map((val) {
                                            return DropdownMenuItem(
                                              value: val,
                                              child: Text(val),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              gender = val ?? 'أنثى';
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // العمر
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("العمر"),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // زر الحفظ
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brownColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "تحديث الملف الشخصي",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
