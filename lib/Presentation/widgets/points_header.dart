import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class PointsHeader extends StatefulWidget {
  final int points;
  final VoidCallback? onLogout;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onLinkWatch;

  const PointsHeader({
    super.key,
    required this.points,
    this.onLogout,
    this.onNotificationsTap,
    this.onLinkWatch,
  });

  @override
  State<PointsHeader> createState() => _PointsHeaderState();
}

class _PointsHeaderState extends State<PointsHeader> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isWatchHovered = false; // Tracks hover state for watch icon

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 24,
        bottom: 28,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.accentTertiary, // Yellow background for header
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.gameBorder, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gameBorder,
            blurRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle shine effect
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HomeTask Smart',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Nivel Familiar',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Points Pill & Action Buttons Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.gameBorder, width: 3),
                        boxShadow: const [
                          BoxShadow(color: AppTheme.gameBorder, blurRadius: 0, offset: Offset(2, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.warning, size: 24),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.points} XP',
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.onNotificationsTap != null) ...[
                    const SizedBox(width: 8),
                    _buildIconButton(
                      icon: Icons.notifications_rounded,
                      onPressed: widget.onNotificationsTap!,
                      tooltip: 'Notificaciones Familiares',
                    ),
                  ],
                  if (widget.onLinkWatch != null) ...[
                    const SizedBox(width: 8),
                    MouseRegion(
                      onEnter: (_) => setState(() => _isWatchHovered = true),
                      onExit: (_) => setState(() => _isWatchHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: _isWatchHovered ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ] : [],
                        ),
                        child: _buildIconButton(
                          icon: Icons.watch_rounded,
                          onPressed: widget.onLinkWatch!,
                          tooltip: 'Vincular Smartwatch',
                        ),
                      ),
                    ),
                  ],
                  if (widget.onLogout != null) ...[
                    const SizedBox(width: 8),
                    _buildIconButton(
                      icon: Icons.exit_to_app_rounded,
                      onPressed: widget.onLogout!,
                      tooltip: 'Cerrar Sesión',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed, required String tooltip}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.gameBorder, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.gameBorder,
            blurRadius: 0,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppTheme.textDark, size: 22),
        tooltip: tooltip,
        splashColor: AppTheme.accentTertiary.withValues(alpha: 0.5),
        highlightColor: Colors.transparent,
      ),
    );
  }
}
