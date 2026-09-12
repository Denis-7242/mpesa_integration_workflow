import 'package:flutter/material.dart';
import '../models/payment.dart';

enum PaymentStatus { initial, processing, pending, success, failed }

class PaymentStatusCard extends StatefulWidget {
  final PaymentStatus status;
  final Payment? payment;

  const PaymentStatusCard({
    super.key,
    required this.status,
    this.payment,
  });

  @override
  State<PaymentStatusCard> createState() => _PaymentStatusCardState();
}

class _PaymentStatusCardState extends State<PaymentStatusCard> {
  bool _isExpanded = false;

  Map<PaymentStatus, ({Color color, IconData icon, String label, String message})> get _statusMap {
    return {
      PaymentStatus.initial: (
        color: Colors.yellow,
        icon: Icons.hourglass_empty,
        label: 'Waiting',
        message: 'Waiting for payment...',
      ),
      PaymentStatus.processing: (
        color: Colors.blue,
        icon: Icons.sync,
        label: 'Processing',
        message: 'Sending STK Push...',
      ),
      PaymentStatus.pending: (
        color: Colors.orange,
        icon: Icons.hourglass_bottom,
        label: 'Pending',
        message: 'STK Push sent. Check your phone.',
      ),
      PaymentStatus.success: (
        color: Colors.green,
        icon: Icons.check_circle,
        label: 'Successful',
        message: 'Payment completed successfully.',
      ),
      PaymentStatus.failed: (
        color: Colors.red,
        icon: Icons.error,
        label: 'Failed',
        message: 'Payment was not completed.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusMap[widget.status]!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statusInfo.icon, color: statusInfo.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusInfo.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusInfo.color,
                        ),
                      ),
                      Text(
                        statusInfo.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.payment != null) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Status', widget.payment!.status),
                _buildDetailRow('Amount', 'KES ${widget.payment!.amount}'),
                _buildDetailRow('Phone', widget.payment!.phone),
                if (widget.payment!.merchantRequestId != null)
                  _buildDetailRow('Merchant ID', widget.payment!.merchantRequestId!),
                if (widget.payment!.checkoutRequestId != null)
                  _buildDetailRow('Checkout ID', widget.payment!.checkoutRequestId!),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
