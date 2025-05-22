class AttendanceModel {
  final int? id;
  final String date;
  final String subject;
  final String status;
  final String time;

  AttendanceModel({
    this.id,
    required this.date,
    required this.subject,
    required this.status,
    required this.time,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      date: json['date'],
      subject: json['subject'],
      status: json['status'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'subject': subject,
      'status': status,
      'time': time,
    };
  }
} 