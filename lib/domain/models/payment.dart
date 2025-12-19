class Payment {
  final String id;
  final String idUser;
  String name;
  DateTime date;
  String? description;
  final double price;
  final int category;
  bool inCloud;

  Payment(
      {required this.id,
        required this.idUser,
        required this.name,
        required this.date,
        this.description,
        required this.price,
        required this.category,
        required this.inCloud});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idUser': idUser,
      'name': name,
      'date': date,
      'description': description,
      'price': price,
      'category': category,
      'inCloud': inCloud == true ? 1 : 0
    };
  }
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
        id: map['id'],
        idUser: map['idUser'],
        name: map['name'],
        date: (map['date']).toDateTime(),
        price: (map['price'] as num).toDouble(),
        category: map['category'],
        inCloud: map['inCloud'] == 1
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
        id: json['id'],
        idUser: json['idUser'],
        name: json['name'],
        date: json['date'],
        description: json['description'],
        price: json['price'],
        category: json['category'],
        inCloud: json['inCloud'] == 1
    );
  }
}
