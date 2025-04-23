import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/home_screen/homescreen.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:http_parser/http_parser.dart';


class ProfileScreen extends StatefulWidget {
  static String routeName = 'Profile screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;
  String? from;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // استقبال الـ arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey("from")) {
      from = args["from"];
    }

    // تحميل الصورة
    loadProfileImage();
  }

  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('profile_image_url');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF0F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF0F8FF),
        elevation: 0,
        title: TextAuth(
          text: 'Profile',
          size: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xff0047AB),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: GestureDetector(
            onTap: () {
              final routeArgs = ModalRoute.of(context)?.settings.arguments;
              final from = (routeArgs is Map && routeArgs.containsKey("from")) ? routeArgs["from"] : null;

              if (from == "homeDrawer") {
                Navigator.pushReplacementNamed(context, HomeScreen.routeName); // غيّري ده حسب اسم الراوت بتاع الهوم
              } else {
                Navigator.pop(context); // يرجع لللي قبله عادي
              }
            },
            child: const ImageIcon(
              AssetImage('assets/images/arrowback.png'),
              color: Color(0xff0047AB),
            ),
          )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : const AssetImage('assets/images/img.png'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageIcon(AssetImage('assets/images/edit.png')),
                SizedBox(width: 6),
                TextButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile == null) return;

                    File imageFile = File(pickedFile.path);

                    // ⬆️ رفع على Cloudinary
                    const cloudName = 'dudmtqpoj';
                    const uploadPreset = 'flutter_upload';
                    final uploadUrl = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

                    final uploadRequest = http.MultipartRequest('POST', uploadUrl);
                    uploadRequest.fields['upload_preset'] = uploadPreset;
                    uploadRequest.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

                    final uploadResponse = await uploadRequest.send();
                    if (uploadResponse.statusCode != 200) {
                      print('❌ Cloudinary upload failed');
                      return;
                    }

                    final resBody = await uploadResponse.stream.bytesToString();
                    final imageUrl = json.decode(resBody)['secure_url'];

                    // 🟦 الآن نرسل رابط الصورة إلى الـ API كـ multipart لكن كـ "string" فقط
                    final uri = Uri.parse('https://back-end-api.genio.ae/api/user/edit/image');
                    final request = http.MultipartRequest('PATCH', uri);

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('accessToken');

                    request.headers['Authorization'] = 'Bearer $token';

                    final mime = lookupMimeType(imageFile.path);
                    final type = mime?.split('/');
                    request.files.add(await http.MultipartFile.fromPath(
                      'image',
                      imageFile.path,
                      contentType: MediaType(type?[0] ?? 'image', type?[1] ?? 'jpeg'),
                    ));

                    final response = await request.send();
                    final responseBody = await response.stream.bytesToString();

                    print(responseBody);

                    if (response.statusCode == 200) {
                      await prefs.setString('profile_image_url', imageUrl);
                      print('✅ Image link sent to API successfully');

                      setState(() {
                        profileImageUrl = imageUrl;
                      });
                    } else if (response.statusCode == 413){
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'The selected image is too large',
                        text: 'Please choose a smaller image or lower quality',
                        confirmBtnText: 'Try Again',
                        confirmBtnColor: const Color(0xFF0047AB),
                        confirmBtnTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      );
                    }else if (response.statusCode == 400){
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'No Image Selected',
                        text: 'Please upload an image',
                        confirmBtnText: 'Try Again',
                        confirmBtnColor: const Color(0xFF0047AB),
                        confirmBtnTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Change',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF344054),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF344054),
                      decorationThickness: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: ProfileComponent()),
          ],
        ),
      ),
    );
  }
}

class ProfileComponent extends StatefulWidget {
  const ProfileComponent({super.key});

  @override
  State<ProfileComponent> createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isNameEditable = false;
  bool isEmailEditable = false;
  bool isPhoneEditable = false;

  String originalName = '';
  String originalEmail = '';
  String originalPhone = '';

  bool get hasChanged =>
      nameController.text != originalName ||
      emailController.text != originalEmail ||
      phoneController.text != originalPhone;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('https://back-end-api.genio.ae/api/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        originalName = data['name'] ?? '';
        originalEmail = data['email'] ?? '';
        originalPhone = data['phone'] ?? '';
        nameController.text = originalName;
        emailController.text = originalEmail;
        phoneController.text = originalPhone;
      });
    }
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phoneFull = phoneController.text.trim();

    final cleaned = phoneFull.replaceAll(' ', '');
    final match = RegExp(r'^(\+\d{1,4})(\d{6,})$').firstMatch(cleaned);

    String? countryCode;
    String? phone;

    if (match != null) {
      countryCode = match.group(1);
      phone = match.group(2);
    }

    Map<String, String> body = {'email': email};

    if (name != originalName) {
      body['name'] = name;
    }

    if (phoneFull != originalPhone && phone != null && countryCode != null) {
      body['phone'] = phone;
      body['countrycode'] = countryCode;
    }

    if (body.length == 1) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        text: 'No changes to save.',
        confirmBtnText: 'OK',
        confirmBtnColor: const Color(0xFF0047AB),
        confirmBtnTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('https://back-end-api.genio.ae/api/user/edit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      setState(() {
        originalName = name;
        originalEmail = email;
        originalPhone = phoneFull;

        isNameEditable = false;
        isEmailEditable = false;
        isPhoneEditable = false;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Profile updated successfully!',
        confirmBtnText: 'Continue',
        confirmBtnColor: const Color(0xFF0047AB),
        confirmBtnTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushNamed(context, AccountSettings.routeName);
          });
        },
      );
    } else if (response.statusCode == 401) {
      final error = jsonDecode(response.body);
      print('❌ Error response: $error');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'User Not found',
        confirmBtnText: 'Try Again',
        confirmBtnColor: const Color(0xFF0047AB),
        confirmBtnTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      );
    } else if (response.statusCode == 403) {
      final error = jsonDecode(response.body);
      print('❌ Error response: $error');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'User Not found',
        confirmBtnText: 'Try Again',
        confirmBtnColor: const Color(0xFF0047AB),
        confirmBtnTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      );
    } else {
      final error = jsonDecode(response.body);
      print('❌ Error response: $error');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Check your internet connection',
        confirmBtnText: 'Try Again',
        confirmBtnColor: const Color(0xFF0047AB),
        confirmBtnTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildEditableField({
    required String label,
    required String iconpath,
    required bool isEditable,
    required TextEditingController controller,
    required VoidCallback onEdit,
    required String fieldType,
  }) {
    String? errorText;
    if (isEditable) {
      final value = controller.text.trim();
      if (label == "Name" && value.isEmpty) {
        errorText = 'Name cannot be empty';
      } else if (label == "Email" &&
          !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
        errorText = 'Enter a valid email address';
      } else if (label == "Phone" && value.isEmpty) {
        errorText = 'Phone number cannot be empty';
      }
    }
    TextInputType keyboard;
    switch (fieldType) {
      case 'email':
        keyboard = TextInputType.emailAddress;
        break;
      case 'phone':
        keyboard = TextInputType.phone;
        break;
      default:
        keyboard = TextInputType.text;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ImageIcon(AssetImage(iconpath), color: const Color(0xff0047AB)),
            const SizedBox(width: 8),
            TextAuth(
              text: label,
              size: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xffF0F8FF),
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xff0047AB),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isEditable,
                  keyboardType: keyboard,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: isEditable ? Colors.black : const Color(0XFFB8B8C7),
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff0047AB),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 5),
            child: Text(
              errorText,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSaveButton() {
    final bool active = hasChanged;

    return GestureDetector(
      onTap: active ? _saveChanges : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xff0047AB) : const Color(0xff99B5DD),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: TextAuth(
          text: 'Save',
          size: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          _buildEditableField(
            fieldType: 'name',
            label: "Name",
            iconpath: 'assets/images/user2.png',
            controller: nameController,
            isEditable: isNameEditable,
            onEdit: () => setState(() => isNameEditable = true),
          ),
          _buildEditableField(
            fieldType: 'email',
            label: "Email",
            iconpath: 'assets/images/sms.png',
            controller: emailController,
            isEditable: isEmailEditable,
            onEdit: () => setState(() => isEmailEditable = true),
          ),
          _buildEditableField(
            fieldType: 'phone',
            label: "Phone",
            iconpath: 'assets/images/call.png',
            controller: phoneController,
            isEditable: isPhoneEditable,
            onEdit: () => setState(() => isPhoneEditable = true),
          ),
          Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/lock.png',
                    color: Color(0xff0047AB),
                  ),
                  SizedBox(width: 8),
                  TextAuth(
                    text: 'Password',
                    size: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF0F8FF),
                  border: Border.all(color: const Color(0xff0047AB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextAuth(
                        text: '**************',
                        size: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffB8B8C7),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => _buildPasswordChangeDialog(),
                        );
                      },
                      child: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff0047AB),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordChangeDialog() {
    final TextEditingController newPass = TextEditingController();
    final TextEditingController confirmPass = TextEditingController();

    bool isNewVisible = false;
    bool isConfirmVisible = false;

    String? newPassError;
    String? confirmPassError;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: const Color(0xffF0F8FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: TextAuth(
            text: 'Change Password',
            size: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff0047AB),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPass,
                obscureText: !isNewVisible,
                onChanged: (_) => setState(() => newPassError = null),
                decoration: InputDecoration(
                  hintText: "New Password",
                  errorText: newPassError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isNewVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xff0047AB),
                    ),
                    onPressed: () {
                      setState(() {
                        isNewVisible = !isNewVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x800047ab),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xff99B5DF),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPass,
                obscureText: !isConfirmVisible,
                onChanged: (_) => setState(() => confirmPassError = null),
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  errorText: confirmPassError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xff0047AB),
                    ),
                    onPressed: () {
                      setState(() {
                        isConfirmVisible = !isConfirmVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x800047ab),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xff99B5DF),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: TextAuth(
                text: 'Cancel',
                size: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff0047AB),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0047AB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final pass = newPass.text.trim();
                final confirm = confirmPass.text.trim();

                setState(() {
                  newPassError =
                      pass.isEmpty ? 'Please enter new password' : null;
                  confirmPassError =
                      confirm.isEmpty
                          ? 'Please confirm password'
                          : (confirm != pass ? 'Passwords do not match' : null);
                });

                if (newPassError != null || confirmPassError != null) return;

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('accessToken');
                print("Token = $token");

                if (token == null) {
                  _showAlert('No token found');
                  return;
                }

                final response = await http.patch(
                  Uri.parse(
                    'https://back-end-api.genio.ae/api/user/edit/password',
                  ),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'password': pass,
                    'confirmpassword': confirm,
                  }),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();
                  _showAlert(
                    'Password is updated successfully',
                    isError: false,
                  );
                } else if (response.statusCode == 400) {
                  _showAlert('Passwords do not match');
                } else if (response.statusCode == 403) {
                  _showAlert('User not found');
                }
              },
              child: TextAuth(
                text: 'Save',
                size: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAlert(String message, {bool isError = true}) {
    QuickAlert.show(
      context: context,
      type: isError ? QuickAlertType.error : QuickAlertType.success,
      text: message,
      confirmBtnText: 'Ok',
      confirmBtnColor: const Color(0xFF0047AB),
      confirmBtnTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white,
      ),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (!isError) {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(
            context,
            ProfileScreen.routeName,
          ); // go to ProfileScreen
        }
      },
    );
  }
}
