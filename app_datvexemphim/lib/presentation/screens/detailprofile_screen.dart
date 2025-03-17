import 'dart:io';
import 'dart:typed_data';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';

class DetailprofileScreen extends StatefulWidget {
  const DetailprofileScreen({super.key});

  @override
  State<DetailprofileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<DetailprofileScreen> {
  String? token;
  String? userId;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _image;
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    token = await StorageService.getToken();
    userId = await StorageService.getUserId();
    if (token == null || userId == null) {
      setState(() => isLoading = false);
      return;
    }
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get("/user/$userId");

      if (response?.statusCode == 200 &&
          response?.data is Map<String, dynamic>) {
        var data = response?.data as Map<String, dynamic>;
        if (data['success'] == true) {
          setState(() {
            userData = data['data'];
            _nameController.text = userData?["hoTen"] ?? "";
            _emailController.text = userData?["email"] ?? "";
            _phoneController.text = userData?["sodienthoai"] ?? "";
            _dobController.text = userData?["ngaySinh"] ?? "";
            _cccdController.text = userData?["cccd"] ?? "";
            _genderController.text = userData?["gioiTinh"] ?? "";
            _addressController.text = userData?["diaChi"] ?? "";
          });
        }
      }
    } catch (e) {
      print("❌ Lỗi lấy dữ liệu người dùng: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateUserData(String? imageUrl) async {
    try {
      final response = await ApiService.put(
        "/user/$userId",
        {
          "hoTen": _nameController.text,
          "sodienthoai": _phoneController.text,
          "ngaySinh": _dobController.text,
          "cccd": _cccdController.text,
          "gioiTinh": _genderController.text,
          "diaChi": _addressController.text,
          if (imageUrl != null) "hinhAnh": imageUrl,
        },
      );
      if (response?.statusCode == 200 && response?.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Cập nhật thành công!")),
        );
      }
    } catch (e) {
      print("❌ Lỗi cập nhật dữ liệu: $e");
    }
  }
//dùng cho máy  máy thật chọn file từ đt
  // Future<void> _pickImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //     print("Ảnh đã chọn: ${_image!.path}");
  //   } else {
  //     print("Người dùng chưa chọn ảnh.");
  //   }
  // }

//dùng cho web chọn ảnh từ thư mục

  File? _imageFile; // Dùng cho mobile
  Uint8List? _imageBytes; // Dùng cho web

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Trên Web: Dùng file_picker
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _imageBytes = result.files.first.bytes;
        });
        print("Ảnh đã chọn (Web): ${result.files.first.name}");
      } else {
        print("Người dùng chưa chọn ảnh.");
      }
    } else {
      // Trên Mobile: Dùng image_picker
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        print("Ảnh đã chọn (Mobile): ${pickedFile.path}");
      } else {
        print("Người dùng chưa chọn ảnh.");
      }
    }
  }

//dùng cho máy  máy thật chọn file từ đt
  // Future<String?> _uploadImageToFirebase(File imageFile) async {
  //   try {
  //     String fileName = "user_$userId.jpg";
  //     Reference storageRef =
  //         FirebaseStorage.instance.ref().child('users/$fileName');

  //     UploadTask uploadTask = storageRef.putFile(imageFile);
  //     TaskSnapshot snapshot = await uploadTask;

  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //     print("Upload thành công! URL: $downloadUrl");
  //     return downloadUrl;
  //   } catch (e) {
  //     print("Lỗi upload ảnh lên Firebase: $e");
  //     return null;
  //   }
  // }

//dùng cho web chọn ảnh từ thư mục

  Future<String?> _uploadImageToFirebase() async {
    try {
      String fileName = "user_$userId.jpg";
      Reference storageRef =
          FirebaseStorage.instance.ref().child('users/$fileName');
      UploadTask uploadTask;

      if (kIsWeb && _imageBytes != null) {
        // Web: Upload bằng bytes
        uploadTask = storageRef.putData(_imageBytes!);
      } else if (!kIsWeb && _imageFile != null) {
        // Mobile: Upload bằng file
        uploadTask = storageRef.putFile(_imageFile!);
      } else {
        print("Không có ảnh nào để upload.");
        return null;
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Upload thành công! URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Lỗi upload ảnh lên Firebase: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa thông tin")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildUserView(),
    );
  }

  Widget _buildUserView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (userData?["hinhAnh"] != null
                              ? NetworkImage(userData!["hinhAnh"])
                              : const AssetImage("assets/default_avatar.png"))
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField("Họ và Tên", _nameController),
          _buildTextField("Email", _emailController, enabled: false),
          _buildTextField("Số điện thoại", _phoneController),
          _buildTextField("Ngày sinh", _dobController),
          _buildTextField("CCCD", _cccdController),
          _buildTextField("Giới tính", _genderController),
          _buildTextField("Địa chỉ", _addressController),
          const SizedBox(height: 30),

          //dùng cho máy  máy thật chọn file từ đt
          // Center(
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       String? imageUrl;
          //       if (_image != null) {
          //         imageUrl = await _uploadImageToFirebase(_image!);
          //       }

          //       if (imageUrl != null || userData?["hinhAnh"] != null) {
          //         await _updateUserData(imageUrl ?? userData!["hinhAnh"]);
          //       } else {
          //         print("Không có ảnh nào để cập nhật.");
          //       }
          //     },
          //     child: const Text("Lưu thông tin"),
          //   ),
          // ),

//dùng cho web chọn ảnh từ thư mục
          Center(
            child: ElevatedButton(
              onPressed: () async {
                String? imageUrl = await _uploadImageToFirebase();
                if (imageUrl != null || userData?["hinhAnh"] != null) {
                  await _updateUserData(imageUrl ?? userData!["hinhAnh"]);
                } else {
                  print("Không có ảnh nào để cập nhật.");
                }
              },
              child: const Text("Lưu thông tin"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        enabled: enabled,
      ),
    );
  }
}
//
//
//
//
//
//

// class DetailProfileScreen extends StatefulWidget {
//   @override
//   _DetailProfileScreenState createState() => _DetailProfileScreenState();
// }

// class _DetailProfileScreenState extends State<DetailProfileScreen> {
//   String? token, userId;
//   Map<String, dynamic>? userData;
//   bool isLoading = true;
//   File? _imageFile;
//   Uint8List? _imageBytes;

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _cccdController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     token = await StorageService.getToken();
//     userId = await StorageService.getUserId();
//     if (token == null || userId == null) {
//       setState(() => isLoading = false);
//       return;
//     }
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     setState(() => isLoading = true);
//     try {
//       final response = await ApiService.get("/user/$userId");
//       if (response?.statusCode == 200 &&
//           response?.data is Map<String, dynamic>) {
//         var data = response?.data as Map<String, dynamic>;
//         if (data['success'] == true) {
//           setState(() {
//             userData = data['data'];
//             _nameController.text = userData?["hoTen"] ?? "";
//             _emailController.text = userData?["email"] ?? "";
//             _phoneController.text = userData?["sodienthoai"] ?? "";
//             _dobController.text = userData?["ngaySinh"] ?? "";
//             _cccdController.text = userData?["cccd"] ?? "";
//             _genderController.text = userData?["gioiTinh"] ?? "";
//             _addressController.text = userData?["diaChi"] ?? "";
//           });
//         }
//       }
//     } catch (e) {
//       print("❌ Lỗi lấy dữ liệu người dùng: $e");
//     }
//     setState(() => isLoading = false);
//   }

//   Future<void> _pickImage() async {
//     if (kIsWeb) {
//       FilePickerResult? result =
//           await FilePicker.platform.pickFiles(type: FileType.image);
//       if (result != null) {
//         setState(() => _imageBytes = result.files.first.bytes);
//       }
//     } else {
//       final pickedFile =
//           await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() => _imageFile = File(pickedFile.path));
//       }
//     }
//   }

//   Future<String?> _uploadImageToFirebase() async {
//     try {
//       String fileName = "user_$userId.jpg";
//       Reference storageRef =
//           FirebaseStorage.instance.ref().child('users/$fileName');
//       UploadTask uploadTask;
//       if (kIsWeb && _imageBytes != null) {
//         uploadTask = storageRef.putData(_imageBytes!);
//       } else if (!kIsWeb && _imageFile != null) {
//         uploadTask = storageRef.putFile(_imageFile!);
//       } else {
//         return null;
//       }
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       print("Lỗi upload ảnh lên Firebase: $e");
//       return null;
//     }
//   }

//   Future<void> _updateUserData(String? imageUrl) async {
//     try {
//       final response = await ApiService.put(
//         "/user/$userId",
//         {
//           "hoTen": _nameController.text,
//           "sodienthoai": _phoneController.text,
//           "ngaySinh": _dobController.text,
//           "cccd": _cccdController.text,
//           "gioiTinh": _genderController.text,
//           "diaChi": _addressController.text,
//           if (imageUrl != null) "hinhAnh": imageUrl,
//         },
//       );
//       if (response?.statusCode == 200 && response?.data['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("✅ Cập nhật thành công!")),
//         );
//       }
//     } catch (e) {
//       print("❌ Lỗi cập nhật dữ liệu: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Chỉnh sửa thông tin")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildUserView(),
//     );
//   }

//   Widget _buildUserView() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: _imageFile != null
//                       ? FileImage(_imageFile!)
//                       : userData?["hinhAnh"] != null
//                           ? NetworkImage(userData!["hinhAnh"])
//                           : const AssetImage("assets/default_avatar.png")
//                               as ImageProvider,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: IconButton(
//                     icon: const Icon(Icons.camera_alt, color: Colors.blue),
//                     onPressed: _pickImage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildTextField("Họ và Tên", _nameController),
//           _buildTextField("Email", _emailController, enabled: false),
//           _buildTextField("Số điện thoại", _phoneController),
//           _buildTextField("Ngày sinh", _dobController),
//           _buildTextField("CCCD", _cccdController),
//           _buildTextField("Giới tính", _genderController),
//           _buildTextField("Địa chỉ", _addressController),
//           const SizedBox(height: 30),
//           Center(
//             child: ElevatedButton(
//               onPressed: () async {
//                 String? imageUrl = await _uploadImageToFirebase();
//                 await _updateUserData(imageUrl ?? userData?["hinhAnh"]);
//               },
//               child: const Text("Lưu thông tin"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller,
//       {bool enabled = true}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         decoration:
//             InputDecoration(labelText: label, border: OutlineInputBorder()),
//         enabled: enabled,
//       ),
//     );
//   }
// }
