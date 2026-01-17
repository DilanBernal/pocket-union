class NewUserDto {
  final String id;
  final String fullName;
  String? avatarUrl;

  NewUserDto({required this.id, required this.fullName, this.avatarUrl});
}
