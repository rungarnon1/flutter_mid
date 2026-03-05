import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddplacesPage extends StatefulWidget {
  const AddplacesPage({super.key});

  @override
  State<AddplacesPage> createState() => _AddplacesPageState();
}

class _AddplacesPageState extends State<AddplacesPage> {

  ////////////////////////////////////////////////////////////
  // ✅ Controllers
  ////////////////////////////////////////////////////////////

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();



  ////////////////////////////////////////////////////////////
  // ✅ Image (ใช้ XFile รองรับ Web)
  ////////////////////////////////////////////////////////////

  XFile? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ Save places + Upload Image
  ////////////////////////////////////////////////////////////

  Future<void> saveplaces() async {

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกรูปภาพ")),
      );
      return;
    }

    final url = Uri.parse(
      "http://127.0.0.1/flutter_66709687_mid/php_api/insert.php",
    );

    var request = http.MultipartRequest('POST', url);

    ////////////////////////////////////////////////////////////
    // ✅ Fields
    ////////////////////////////////////////////////////////////

    request.fields['name'] = nameController.text;
    request.fields['address'] = addressController.text;
    request.fields['province'] = provinceController.text;
    request.fields['description'] = descriptionController.text;

    ////////////////////////////////////////////////////////////
    // ✅ Upload Image (แยก Web / Mobile)
    ////////////////////////////////////////////////////////////

    if (kIsWeb) {

      final bytes = await selectedImage!.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: selectedImage!.name,
        ),
      );

    } else {

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          selectedImage!.path,
        ),
      );
    }

    ////////////////////////////////////////////////////////////
    // ✅ Execute
    ////////////////////////////////////////////////////////////

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    final data = json.decode(responseData);

    if (data["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เพิ่มสถานที่เรียบร้อย")),
      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data["error"]}")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เพิ่มสถานที่")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [

              ////////////////////////////////////////////////////////////
              // 🖼 Image Preview (สำคัญมาก)
              ////////////////////////////////////////////////////////////

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: selectedImage == null
                      ? const Center(
                          child: Text("แตะเพื่อเลือกรูป"),
                        )
                      : kIsWeb
                          ? Image.network(
                              selectedImage!.path, // ✅ Web
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImage!.path), // ✅ Mobile
                              fit: BoxFit.cover,
                            ),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 🏷 Name
              ////////////////////////////////////////////////////////////

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อสถานที่",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 💰 email
              ////////////////////////////////////////////////////////////

              TextField(
                controller: addressController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "ที่อยู่",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📝 phone
              ////////////////////////////////////////////////////////////

              TextField(
                controller: provinceController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "จังหวัด",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📝 phone
              ////////////////////////////////////////////////////////////

              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "รายละเอียด",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // ✅ Button
              ////////////////////////////////////////////////////////////

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveplaces,
                  child: const Text("บันทึกข้อมูล"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}