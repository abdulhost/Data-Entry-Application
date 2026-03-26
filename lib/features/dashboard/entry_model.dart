class Entry {
  String id;
  String name;
  String phone;
  String address;
  String variant;
  String color;
  double amount;
  String date;
  String time;
  int? sheetRow; // <--- Add this

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
    this.sheetRow,
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
      'sheetRow': sheetRow,
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
      sheetRow: map['sheetRow'], // <-- parse it
    );
  }
}