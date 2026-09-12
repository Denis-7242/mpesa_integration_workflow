class Payment {
  final String phone;
  final double amount;
  final String status;
  final String? merchantRequestId;
  final String? checkoutRequestId;
  final String? receiptNumber;
  final String? resultCode;
  final String? resultDescription;

  Payment({
    required this.phone,
    required this.amount,
    required this.status,
    this.merchantRequestId,
    this.checkoutRequestId,
    this.receiptNumber,
    this.resultCode,
    this.resultDescription,
  });

  // Helper to create a payment from map (useful for later JSON integration)
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      phone: map['phone'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'Unknown',
      merchantRequestId: map['merchantRequestId'],
      checkoutRequestId: map['checkoutRequestId'],
      receiptNumber: map['receiptNumber'],
      resultCode: map['resultCode'],
      resultDescription: map['resultDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'amount': amount,
      'status': status,
      'merchantRequestId': merchantRequestId,
      'checkoutRequestId': checkoutRequestId,
      'receiptNumber': receiptNumber,
      'resultCode': resultCode,
      'resultDescription': resultDescription,
    };
  }
}
