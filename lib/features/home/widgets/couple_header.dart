import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pocket_union/features/home/widgets/profile_avatar.dart';

class CoupleHeader extends StatelessWidget {
  final String? userName;
  final String? partnerName;
  final String? userAvatarUrl;
  final String? partnerAvatarUrl;

  const CoupleHeader({
    super.key,
    required this.userName,
    required this.partnerName,
    required this.userAvatarUrl,
    required this.partnerAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileAvatar(name: userName, avatarUrl: userAvatarUrl),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            TablerIcons.heart,
            color: Color.fromRGBO(255, 17, 203, 1),
          ),
        ),
        ProfileAvatar(name: partnerName, avatarUrl: partnerAvatarUrl),
      ],
    );
  }
}
