import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';
import '../constant/form_add_users.dart';
import '../constant/sidebar.dart';
import 'login.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<ManageUsers> {
  // Variables for storing user data
  String? username;
  String? role;
  String? selectedRole = 'ทั้งหมด';
  List<String> roles = [
    'ทั้งหมด',
    'admin',
    'staff',
    'technician',
  ];

  List<dynamic> users = [];

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  // Function to fetch users
  Future<void> fetchUsers() async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/get_users.php";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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

  // Function to add users
  Future<void> AddUsers() async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/add_users.php";

    final response = await http.post(Uri.parse(url), body: {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'role': roleController.text,
    });

    var data = json.decode(response.body);
    if (data['status'] == "success") {
      fetchUsers(); // อัปเดตข้อมูลผู้ใช้
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      roleController.clear();
    } else {
      print("Failed to add user: ${data['message']}");
    }
  }

  // Function to delete a user
  Future<void> deleteUser(String id) async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/delete_user.php";

    final response = await http.post(Uri.parse(url), body: {
      'id': id,
    });

    var data = json.decode(response.body);
    if (data['status'] == "success") {
      fetchUsers(); // อัปเดตข้อมูลผู้ใช้
      // แสดงข้อความเตือนเมื่อการลบสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบข้อมูลสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("Failed to delete user: ${data['message']}");
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
      'role': roleController.text.trim(),
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
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchUsers();
  }

  // Function เปิดฟอร์มใน Dialog
  void openAddUserForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'เพิ่มผู้ใช้ใหม่',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 24,
            fontFamily: Font_.Fonts_T,
          ),
        ),
        content: SingleChildScrollView(
          child: AddUserForm(
            formKey: formKey,
            roleController: roleController,
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            onSubmit: AddUsers,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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

            // Form Section
            Expanded(
              flex: 8,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'จัดการผู้ใช้งาน',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 16.0),

                      // ค้นหาตำแหน่งงาน
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'ค้นหาตำแหน่งงาน',
                              ),
                              items: roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // DataTable ที่กรองตามตำแหน่งงาน
                      Expanded(
                        child: ListView(
                          children: [
                            DataTable(
                              columns: const [
                                DataColumn(
                                    label: Text('ชื่อ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('อีเมล',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('ตำแหน่ง',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('     จัดการ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ],
                              rows: users.where((user) {
                                // กรองผู้ใช้ตามตำแหน่งงาน
                                return selectedRole == 'ทั้งหมด' ||
                                    user['role'] == selectedRole;
                              }).map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(user['name'] ?? 'No Name')),
                                    DataCell(Text(user['email'] ?? 'No Email')),
                                    DataCell(Text(user['role'] ?? 'No Role')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: bottoncolor,
                                            ),
                                            onPressed: () {
                                              nameController.text =
                                                  user['name'];
                                              emailController.text =
                                                  user['email'];
                                              roleController.text =
                                                  user['role'];
                                              passwordController.text =
                                                  ""; // ตั้งค่าเริ่มต้นให้เป็นค่าว่าง
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'แก้ไขผู้ใช้งาน'),
                                                  content: Form(
                                                    key: formKey,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // ชื่อผู้ใช้งาน
                                                        TextFormField(
                                                          controller:
                                                              nameController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: 'ชื่อ',
                                                            hintText: 'ใส่ชื่อ',
                                                            border:
                                                                UnderlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value
                                                                    .trim()
                                                                    .isEmpty) {
                                                              return 'กรุณาใส่ชื่อ';
                                                            }
                                                            return null;
                                                          },
                                                        ),

                                                        const SizedBox(
                                                            height: 8.0),

                                                        // อีเมลผู้ใช้งาน
                                                        TextFormField(
                                                          controller:
                                                              emailController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: 'อีเมล',
                                                            hintText:
                                                                'ใส่อีเมล',
                                                            border:
                                                                UnderlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value
                                                                    .trim()
                                                                    .isEmpty) {
                                                              return 'กรุณาใส่อีเมล';
                                                            }

                                                            return null;
                                                          },
                                                        ),

                                                        const SizedBox(
                                                            height: 8.0),

                                                        // ตำแหน่งงานผู้ใช้งาน
                                                        DropdownButtonFormField<
                                                            String>(
                                                          value: roleController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? roleController
                                                                  .text
                                                              : null,
                                                          items: [
                                                            'admin',
                                                            'technician',
                                                            'staff'
                                                          ].map((role) {
                                                            return DropdownMenuItem(
                                                              value: role,
                                                              child: Text(role),
                                                            );
                                                          }).toList(),
                                                          onChanged: (value) {
                                                            roleController
                                                                .text = value!;
                                                          },
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: 'Role',
                                                            border:
                                                                UnderlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value
                                                                    .trim()
                                                                    .isEmpty) {
                                                              return 'กรุณาเลือก Role';
                                                            }
                                                            return null;
                                                          },
                                                        ),

                                                        const SizedBox(
                                                            height: 8.0),

                                                        // รหัสผ่านใหม่ (ไม่บังคับ)
                                                        TextFormField(
                                                          controller:
                                                              passwordController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText:
                                                                'รหัสผ่านใหม่ (ไม่บังคับ)',
                                                            hintText:
                                                                'ใส่รหัสผ่านใหม่',
                                                            border:
                                                                UnderlineInputBorder(),
                                                          ),
                                                          obscureText: true,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child:
                                                          const Text('Cancel'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                    ),
                                                    TextButton(
                                                      child: const Text('Save'),
                                                      onPressed: () {
                                                        // ตรวจสอบว่าฟอร์มถูกต้องหรือไม่
                                                        if (formKey
                                                            .currentState!
                                                            .validate()) {
                                                          editUser(user['id']);
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            color: Colors.red,
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              // แสดงกล่องยืนยันการลบ
                                              bool isConfirmed =
                                                  await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('ยืนยันการลบ'),
                                                    content: Text(
                                                        'คุณแน่ใจว่าต้องการลบผู้ใช้นี้?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(
                                                              false); // ผู้ใช้กด "ยกเลิก"
                                                        },
                                                        child: Text('ยกเลิก'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(
                                                              true); // ผู้ใช้กด "ยืนยัน"
                                                        },
                                                        child: Text('ยืนยัน'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              // ถ้าผู้ใช้ยืนยันการลบ
                                              if (isConfirmed == true) {
                                                deleteUser(user['id']);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Add User Form
                      Container(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: openAddUserForm, // เปิด Dialog เมื่อกดปุ่ม
                          backgroundColor: bottoncolor, // สีพื้นหลัง
                          child: const Icon(
                            Icons.add, // ไอคอนเครื่องหมาย "+"
                            color: Colors.white,
                          ),
                          tooltip:
                              'เพิ่มผู้ใช้', // ข้อความแสดงเมื่อวางเมาส์ (Desktop)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
