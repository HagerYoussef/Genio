import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'dart:convert';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../home_screen/homescreen.dart';

Future<bool> sendPaymentConfirmationEmail({
  required String email,
  required String userName,
  required String planName,
  required double amount,
  required BuildContext context,
}) async {
  const serviceId = 'service_mpvgwsj';
  const templateId = 'template_4t8rs24';
  const publicKey = 'bHkfptKct34Qt_sAg';
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(
    url,
    headers: {
      'origin': 'http://localhost',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': publicKey,
      'template_params': {
        'user_name': userName,
        'plan_name': planName,
        'amount': amount,
        'to_email': email,
      },
    }),
  );
  if (response.statusCode == 200) {
    print('✅ Email sent successfully');
    return true;
  } else {
    print('❌ Failed to send email: ${response.body}');
    return false;
  }
}
