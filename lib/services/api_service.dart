import 'dart:async';
import '../models/payment.dart';

class ApiService {
  /// Simulates an M-PESA STK Push request.
  /// In a real app, this would call a backend API.
  Future<Payment> initiateStkPush({
    required String phone,
    required double amount,
  }) async {
    // Simulate network latency
    await Future.delayed(const Duration(seconds: 3));

    // Simulate a successful STK push request initiation
    // Note: In reality, the STK Push is asynchronous. This call only initiates it.
    return Payment(
      phone: phone,
      amount: amount,
      status: 'Pending',
      merchantRequestId: 'MQRT${DateTime.now().millisecondsSinceEpoch}',
      checkoutRequestId: 'CK${DateTime.now().millisecondsSinceEpoch}',
      resultCode: '0',
      resultDescription: 'Success',
    );
  }
}
