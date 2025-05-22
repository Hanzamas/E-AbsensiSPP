class SppModel {
  final int? id;
  final String month;
  final int amount;
  final String status;
  final String? date;

  SppModel({
    this.id,
    required this.month,
    required this.amount,
    required this.status,
    this.date,
  });

  factory SppModel.fromJson(Map<String, dynamic> json) {
    return SppModel(
      id: json['id'],
      month: json['month'],
      amount: json['amount'],
      status: json['status'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'amount': amount,
      'status': status,
      'date': date,
    };
  }
} 