import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;

  const ProfileAvatar({super.key, required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final nameParts = name?.trim().split(RegExp(r'\s+')) ?? const <String>[];
    final firstName = nameParts.isEmpty ? '' : nameParts.first;
    final initial = firstName.isEmpty
        ? '?'
        : firstName.substring(0, 1).toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color.fromRGBO(128, 128, 204, 0.35),
          child: ClipOval(
            child: SizedBox.square(
              dimension: 64,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 96,
          child: Text(
            firstName.isEmpty ? 'Sin perfil' : firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
