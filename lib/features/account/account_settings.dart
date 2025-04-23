import 'package:flutter/material.dart';
import 'package:genio_ai/features/account/switch.dart';
import 'package:genio_ai/features/home_screen/homescreen.dart';
import 'package:genio_ai/features/login/presentation/login.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:genio_ai/features/profile/profile_screen.dart';
import 'package:genio_ai/features/upgrade_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettings extends StatefulWidget {
  static String routeName = 'Account Settings';
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
  }

  void loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('profile_image_url');
    });
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userId");
    await prefs.remove("accessToken");
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF0F8FF),
        elevation: 0,
        title: TextAuth(
          text: 'Account',
          size: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xff0047AB),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, HomeScreen.routeName);
          },
          icon: ImageIcon(
            AssetImage('assets/images/arrowback.png'),
            color: Color(0xff0047AB),
          ),
        ),
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage:
                profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage('assets/images/img.png')
                        as ImageProvider,
          ),
          SizedBox(width: 20),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle('My account'),
          _buildTile(
            'Profile',
            'assets/images/user2.png',
            context,
            ProfileScreen.routeName,
          ),
          // _buildSwitchTile('Notifications', Icons.notifications, true),
          _buildTile(
            'Delete Account',
            'assets/images/user-minus.png',
            context,
            '',
          ),

          //SizedBox(height: 20),
          //_buildSectionTitle('Settings'),
          //_buildSwitchTile('Light mode', Icons.light_mode, false),
          //_buildTileWithValue('Languages', Icons.language, 'English'),
          SizedBox(height: 20),
          _buildSectionTitle('Support'),
          _buildTile(
            'FAQs',
            'assets/images/question.png',
            context,
            ProfileScreen.routeName,
          ),
          _buildTile(
            'Customer Support',
            'assets/images/music-play.png',
            context,
            ProfileScreen.routeName,
          ),
          SizedBox(height: 20),
          _buildSectionTitle('Upgrade'),
          _buildTile(
            'View Plans',
            'assets/images/flash.png',
            context,
            UpgradeScreen.routeName,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 225),
            child: TextButton(
              onPressed: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: 'Do you want to logout ?',
                  confirmBtnText: 'Yes',
                  cancelBtnText: 'No',
                  confirmBtnColor: Colors.green,
                  onConfirmBtnTap: () {
                    logout(context);
                  },
                  onCancelBtnTap: () {
                    Navigator.pop(context);
                  },
                );
              },
              child: TextAuth(
                text: 'Logout',
                size: 20,
                fontWeight: FontWeight.w500,
                color: Color(0XFFDD5B5B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextAuth(
        text: title,
        size: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTile(
    String title,
    String image,
    BuildContext context,
    String route,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ImageIcon(
        AssetImage(image),
        color:
            image.contains('assets/images/flash.png')
                ? Color(0XFF0047AB)
                : Color(0XFF344054),
      ),
      title: TextAuth(
        text: title,
        size: 17,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: ImageIcon(
          AssetImage('assets/images/arrow.png'),
          color: Color(0XFF344054),
        ),
      ),
      onTap: () {
        if (route == '') {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.confirm,
            title: 'Do you want to delete your account ?',
            confirmBtnText: 'Yes',
            cancelBtnText: 'No',
            confirmBtnColor: Colors.green,
            onConfirmBtnTap: () {
              logout(context);
            },
            onCancelBtnTap: () {
              Navigator.pop(context);
            },
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ImageIcon(AssetImage('assets/images/notification.png')),
      title: TextAuth(
        text: 'Notifications',
        size: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      trailing: SwitchExample(),
    );
  }

  Widget _buildTileWithValue(String title, IconData icon, String valueText) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ImageIcon(AssetImage('assets/images/global.png')),
      title: TextAuth(
        text: title,
        size: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextAuth(
            text: valueText,
            size: 13,
            fontWeight: FontWeight.w400,
            color: Color(0XFF344054),
          ),
          IconButton(
            onPressed: () {},
            icon: ImageIcon(
              AssetImage('assets/images/arrow.png'),
              color: Color(0XFF344054),
            ),
          ),
        ],
      ),
      onTap: () {
        //Navigate
      },
    );
  }
}
