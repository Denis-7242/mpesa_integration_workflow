import 'package:flutter/material.dart';
import '../widgets/payment_header.dart';
import '../widgets/phone_input.dart';
import '../widgets/amount_input.dart';
import '../widgets/payment_button.dart';
import '../widgets/payment_status_card.dart';
import '../services/api_service.dart';
import '../models/payment.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final ApiService _apiService = ApiService();

  String? _phoneError;
  String? _amountError;
  bool _isLoading = false;
  PaymentStatus _status = PaymentStatus.initial;
  Payment? _payment;

  void _validateInputs() {
    setState(() {
      _phoneError = null;
      _amountError = null;

      final phone = _phoneController.text.trim();
      final amountText = _amountController.text.trim();

      if (phone.isEmpty) {
        _phoneError = 'Please enter your phone number.';
      } else if (phone.length < 12 || !phone.startsWith('254')) {
        _phoneError = 'Enter a valid Kenyan phone number (e.g. 2547XXXXXXXX).';
      }

      if (amountText.isEmpty) {
        _amountError = 'Please enter an amount.';
      } else {
        final amount = double.tryParse(amountText);
        if (amount == null || amount <= 0) {
          _amountError = 'Enter an amount greater than zero.';
        }
      }
    });
  }

  Future<void> _handlePayment() async {
    _validateInputs();

    if (_phoneError != null || _amountError != null) return;

    setState(() {
      _isLoading = true;
      _status = PaymentStatus.processing;
      _payment = null;
    });

    try {
      final result = await _apiService.initiateStkPush(
        phone: _phoneController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
      );

      setState(() {
        _payment = result;
        _status = PaymentStatus.pending;
      });

      // For demo purposes, we'll simulate the transition to success after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _status = PaymentStatus.success;
          });
        }
      });
    } catch (e) {
      setState(() {
        _status = PaymentStatus.failed;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('M-PESA Workflow'),
            Text(
              'Daraja Learning App',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PaymentHeader(),
              const SizedBox(height: 32),
              PhoneInput(
                controller: _phoneController,
                errorText: _phoneError,
                onChanged: (val) => setState(() {
                  if (_phoneError != null) _validateInputs();
                }),
              ),
              const SizedBox(height: 20),
              AmountInput(
                controller: _amountController,
                errorText: _amountError,
                onChanged: (val) => setState(() {
                  if (_amountError != null) _validateInputs();
                }),
              ),
              const SizedBox(height: 32),
              PaymentButton(
                isLoading: _isLoading,
                onPressed: _handlePayment,
              ),
              const SizedBox(height: 32),
              PaymentStatusCard(
                status: _status,
                payment: _payment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
