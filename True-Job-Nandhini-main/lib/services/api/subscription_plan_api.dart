import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class SubscriptionPlanApi {
  static Future<Map<String, dynamic>> fetchPlans() async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1152';

    debugPrint('--> POST $url (fetchSubscriptionPlans)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('SubscriptionPlanApi Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchRazorpayKey() async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1156';

    debugPrint('--> POST $url (fetchRazorpayKey)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('SubscriptionPlanApi Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createRazorpayOrder({
    required int coinsAdd,
    required double amount,
    required int packageId,
    required int userId,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1157';
    body['coins_add'] = coinsAdd.toString();
    body['amount'] = amount.toString();
    body['package_id'] = packageId.toString();
    body['user_id'] = userId.toString();

    debugPrint('--> POST $url (createRazorpayOrder)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('SubscriptionPlanApi Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required int userId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1158';
    body['user_id'] = userId.toString();
    body['razorpay_order_id'] = razorpayOrderId;
    body['razorpay_payment_id'] = razorpayPaymentId;
    body['razorpay_signature'] = razorpaySignature;

    debugPrint('--> POST $url (verifyPayment)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('SubscriptionPlanApi Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }
}

