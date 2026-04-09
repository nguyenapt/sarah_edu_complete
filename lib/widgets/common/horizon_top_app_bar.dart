import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/cache/app_image_cache_manager.dart';
import '../../providers/auth_provider.dart';

/// App bar kiểu mới: back -> title -> avatar (đồng bộ các màn Horizon).
class HorizonTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HorizonTopAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.onAvatarTap,
    this.backgroundColor = const Color(0xFFF4F6FF),
    this.titleColor = const Color(0xFF14304F),
    this.avatarTint = const Color(0xFFDDE9FF),
    this.avatarIconColor = const Color(0xFF445D7F),
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAvatarTap;
  final Color backgroundColor;
  final Color titleColor;
  final Color avatarTint;
  final Color avatarIconColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
          child: Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: titleColor,
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                      backgroundImage: hasPhoto
                          ? CachedNetworkImageProvider(
                              photoUrl,
                              cacheManager: AppImageCacheManager.instance,
                            )
                          : null,
                      child: hasPhoto
                          ? null
                          : Icon(
                              Icons.person_rounded,
                              color: avatarIconColor,
                              size: 20,
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

