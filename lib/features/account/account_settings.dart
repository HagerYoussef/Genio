import 'package:flutter/material.dart';
import 'package:genio_ai/features/account/switch.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:genio_ai/features/profile/profile_screen.dart';

class AccountSettings extends StatelessWidget {
  static String routeName = 'Account Settings';
  const AccountSettings({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF0F8FF),
        elevation: 0,
        title: TextAuth(text: 'Account', size: 20, fontWeight: FontWeight.w600, color: Color(0xff0047AB)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: ImageIcon(
            AssetImage('assets/images/arrowback.png'),
            color: Color(0xff0047AB),
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/user.png'),
            radius: 20,
          ),
          SizedBox(width: 20),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle('My account'),
          _buildTile('Profile','assets/images/user2.png',context),
          _buildSwitchTile('Notifications', Icons.notifications, true),
          _buildTile('Delete Account','assets/images/user-minus.png',context),

          SizedBox(height: 20),
          _buildSectionTitle('Settings'),
          _buildSwitchTile('Light mode', Icons.light_mode, false),
          _buildTileWithValue('Languages', Icons.language, 'English'),

          SizedBox(height: 20),
          _buildSectionTitle('Support'),
          _buildTile('FAQs','assets/images/question.png',context),
          _buildTile('Customer Support','assets/images/music-play.png',context),

          SizedBox(height: 20),
          _buildSectionTitle('Upgrade'),
          _buildTile('Enter Limited code','assets/images/flash.png',context),

          Padding(
            padding: const EdgeInsets.only(
              right: 225
            ),
            child: TextButton(
              onPressed: () {},
              child: TextAuth(text: 'Logout', size: 20, fontWeight: FontWeight.w500, color: Color(0XFFDD5B5B)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextAuth(text: title, size: 18, fontWeight: FontWeight.w500, color: Colors.black),
    );
  }

  Widget _buildTile(String title,String image,BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ImageIcon(AssetImage(image),color : image.contains('assets/images/flash.png')
          ? Color(0XFF0047AB): Color(0XFF344054)),
      title: TextAuth(text: title, size: 17, fontWeight: FontWeight.w500, color: Colors.black),
      trailing: IconButton(onPressed: (){}, icon: ImageIcon(AssetImage('assets/images/arrow.png'),color: Color(0XFF344054),)),
      onTap: () {
        //Navigate to profile
        Navigator.pushNamed(context, ProfileScreen.routeName);
      },
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ImageIcon(AssetImage('assets/images/notification.png')),
      title: TextAuth(text: 'Notifications', size: 16, fontWeight: FontWeight.w500, color: Colors.black),
      trailing: SwitchExample(),
    );
  }

  Widget _buildTileWithValue(String title, IconData icon, String valueText) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ImageIcon(AssetImage('assets/images/global.png')),
      title: TextAuth(text: title, size: 16, fontWeight: FontWeight.w500, color: Colors.black),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextAuth(text: valueText, size: 13, fontWeight: FontWeight.w400, color: Color(0XFF344054)),
          IconButton(onPressed: (){}, icon: ImageIcon(AssetImage('assets/images/arrow.png'),color: Color(0XFF344054),)),
        ],
      ),
      onTap: () {
        //Navigate
      },
    );
  }
}
