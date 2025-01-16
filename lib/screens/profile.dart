import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';

import 'package:http/http.dart' as http;

import '../constant/sidebar.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username;
  String? role;
  String? email;
  bool _obscureText = true;

  List<dynamic> users = [];

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  Future<void> fetchUsers() async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/get_users.php";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print("API response: $data"); // พิมพ์ข้อมูลที่ได้รับจาก API
      if (data['status'] == 'success') {
        setState(() {
          // ใช้ data['data'] แทนที่จะเป็น data['users']
          users = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        print("Failed to load users: ${data['message']}");
      }
    } else {
      print("Failed to load users");
    }
  }

  Future<void> editUser(String id) async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/edit_user.php";

    // สร้าง body สำหรับส่งข้อมูล
    final Map<String, String> body = {
      'id': id,
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'role': role ?? '', // ใช้ role ที่ได้จาก _loadUserName
    };

    // ตรวจสอบและเพิ่ม password หากมี
    if (passwordController.text.isNotEmpty) {
      body['password'] = passwordController.text.trim();
    }

    // Debug: พิมพ์ข้อมูลที่กำลังจะส่ง
    print("Request body: $body");

    try {
      final response = await http.post(Uri.parse(url), body: body);
      final data = json.decode(response.body);

      if (data['status'] == "success") {
        print("User edited successfully.");
        fetchUsers(); // อัปเดตข้อมูลผู้ใช้
        // แสดงข้อความเตือนเมื่อการลบสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('แก้ไขข้อมูลสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print("Failed to edit user: ${data['message']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name'); // ดึงค่าชื่อผู้ใช้
      role = prefs.getString('role'); // ดึงตำแหน่งผู้ใช้
      email = prefs.getString('email'); // ดึงอีเมลผู้ใช้
      roleController.text = role ?? ''; // กำหนดตำแหน่งให้ในฟอร์ม
    });
  }

  void initState() {
    super.initState();
    _loadUserName(); // โหลดข้อมูลก่อนแสดงผล
    fetchUsers(); // เรียกใช้งาน fetchUsers เพื่อโหลดข้อมูลผู้ใช้
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              Expanded(
                flex: 2,
                child: Card(
                  child: Sidebar(
                    username: username,
                    role: role,
                    bottonColor: bottoncolor,
                    onLogout: logout,
                  ),
                ),
              ),

              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
                  children: [
                    const SizedBox(height: 8.0),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'โปรไฟล์',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 16.0),
                    Center(
                      child: Container(
                        width: 150, // ขนาดของรูปโปรไฟล์
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // รูปแบบวงกลม
                          image: const DecorationImage(
                            image: AssetImage('assets/img/runnerx.png'),
                            fit: BoxFit.cover, // ปรับรูปให้เต็มพื้นที่
                          ),
                          border: Border.all(
                            color: bottoncolor, // ขอบสีขาว
                            width: 3, // ความหนาของขอบ
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
                        children: [
                          const Text(
                            'ชื่อ - นามสกุล',
                            style: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            username ?? '-',
                            style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ตำแหน่ง:',
                            style: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            role ?? '-',
                            style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ชื่อผู้ใช้งาน:',
                            style: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email ?? '-',
                            style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              bool dialogObscureText =
                                  _obscureText; // ใช้ตัวแปรแยกใน dialog
                              return StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return AlertDialog(
                                    title: const Text('แก้ไขผู้ใช้งาน'),
                                    content: Form(
                                      key: formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ชื่อผู้ใช้งาน
                                          TextFormField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                              labelText: 'ชื่อ - นามสกุล',
                                              hintText: 'ใส่ชื่อ - นามสกุล',
                                              border: UnderlineInputBorder(),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'กรุณาใส่ชื่อ - นามสกุล';
                                              }
                                              return null;
                                            },
                                          ),

                                          const SizedBox(height: 8.0),

                                          // อีเมลผู้ใช้งาน
                                          TextFormField(
                                            controller: emailController,
                                            decoration: const InputDecoration(
                                              labelText: 'ชื่อผู้ใช้งาน',
                                              hintText: 'ใส่ชื่อผู้ใช้งาน',
                                              border: UnderlineInputBorder(),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'กรุณาใส่ชื่อผู้ใช้งาน';
                                              }
                                              return null;
                                            },
                                          ),

                                          const SizedBox(height: 8.0),

                                          // ตำแหน่งงานผู้ใช้งาน (ไม่สามารถเลือกได้)
                                          TextFormField(
                                            controller: roleController,
                                            readOnly: true, // ปิดไม่ให้เลือก
                                            decoration: const InputDecoration(
                                              labelText: 'ตำแหน่งงาน',
                                              border: UnderlineInputBorder(),
                                            ),
                                          ),

                                          const SizedBox(height: 8.0),

                                          // รหัสผ่านใหม่
                                          TextFormField(
                                            controller: passwordController,
                                            obscureText: dialogObscureText,
                                            decoration: InputDecoration(
                                              labelText: 'รหัสผ่านใหม่',
                                              hintText: 'ใส่รหัสผ่านใหม่',
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  dialogObscureText
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setDialogState(() {
                                                    dialogObscureText =
                                                        !dialogObscureText;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('ยกเลิก'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      TextButton(
                                        child: const Text('บันทึก'),
                                        onPressed: () async {
                                          // ตรวจสอบว่าฟอร์มถูกต้องหรือไม่
                                          if (formKey.currentState!
                                              .validate()) {
                                            // ส่งข้อมูลไปแก้ไข

                                            editUser(users[0]['id']);
                                            // Navigator.of(context).pop();
                                            Navigator.of(context)
                                                .pop(); // ปิด dialog ก่อน
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs
                                                .clear(); // ลบข้อมูลทั้งหมด หรือใช้ prefs.remove('name') เพื่อลบเฉพาะค่า
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Login(),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        backgroundColor: bottoncolor, // สีพื้นหลัง
                        child: const Icon(
                          Icons.settings, // ไอคอนเครื่องหมาย "+"
                          color: Colors.white,
                        ),
                        tooltip:
                            'แก้ไขผู้ใช้', // ข้อความแสดงเมื่อวางเมาส์ (Desktop)
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // ไม่ต้องส่งชื่อผ่าน constructor
      ),
    );
  }
}
