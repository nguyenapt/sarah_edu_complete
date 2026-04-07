import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

/// Top navigation giống `PracticeScreen`: text + avatar tròn bên phải.
class PracticeTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PracticeTopAppBar({
    super.key,
    required this.title,
    this.onAvatarTap,
    this.backgroundColor,
    this.titleColor = const Color(0xFF0F172A),
    this.avatarTint = const Color(0xFFE0F2FE),
    this.avatarIconColor = const Color(0xFF0369A1),
  });

  final String title;
  final VoidCallback? onAvatarTap;
  final Color? backgroundColor;
  final Color titleColor;
  final Color avatarTint;
  final Color avatarIconColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Material(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final photoUrl = authProvider.user?.photoUrl;
                  final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

                  return InkWell(
                    onTap: onAvatarTap,
                    borderRadius: BorderRadius.circular(999),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: avatarTint,
                      child: hasPhoto
                          ? ClipOval(
                              child: Image.network(
                                photoUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.person_rounded,
                                  color: avatarIconColor,
                                  size: 22,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              color: avatarIconColor,
                              size: 22,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

