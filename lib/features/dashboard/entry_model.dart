// lib/features/dashboard/entry_model.dart
class Entry {
  String id;
  String name;
  String phone;
  String address;
  String variant;
  String color;
  double amount;
  String date; // e.g., 25 Mar 2026
  String time; // e.g., 3:30 PM

  Entry({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.variant,
    required this.color,
    required this.amount,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'variant': variant,
      'color': color,
      'amount': amount,
      'date': date,
      'time': time,
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      variant: map['variant'],
      color: map['color'],
      amount: (map['amount'] as num).toDouble(),
      date: map['date'],
      time: map['time'],
    );
  }
}