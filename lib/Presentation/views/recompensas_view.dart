import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class RecompensasView extends StatefulWidget {
  final List<FamilyReward> rewards;
  final int totalPoints;
  final bool isParent;
  final String childName;
  final Function(String title, int points)? onRewardAdded;
  final Function(String rewardId)? onRewardDeleted;
  final Function(String rewardId, int points)? onRewardClaimed;

  const RecompensasView({
    super.key,
    required this.rewards,
    required this.totalPoints,
    required this.isParent,
    required this.childName,
    this.onRewardAdded,
    this.onRewardDeleted,
    this.onRewardClaimed,
  });

  @override
  State<RecompensasView> createState() => _RecompensasViewState();
}

class _RecompensasViewState extends State<RecompensasView> with SingleTickerProviderStateMixin {
  late AnimationController _pointsAnimController;
  late Animation<int> _pointsAnimation;
  int _lastPoints = 0;

  @override
  void initState() {
    super.initState();
    _lastPoints = widget.totalPoints;
    _pointsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pointsAnimation = IntTween(begin: _lastPoints, end: widget.totalPoints).animate(
      CurvedAnimation(parent: _pointsAnimController, curve: Curves.easeOutCubic),
    );
    _pointsAnimController.forward(from: 0);
  }

  @override
  void didUpdateWidget(RecompensasView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalPoints != widget.totalPoints) {
      _pointsAnimation = IntTween(begin: _lastPoints, end: widget.totalPoints).animate(
        CurvedAnimation(parent: _pointsAnimController, curve: Curves.easeOutCubic),
      );
      _lastPoints = widget.totalPoints;
      _pointsAnimController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pointsAnimController.dispose();
    super.dispose();
  }

  void _showAddRewardDialog(BuildContext context) {
    final titleController = TextEditingController();
    final pointsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Nueva Recompensa', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título del Premio',
                    hintText: 'ej. 1 Hora de Videojuegos',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Puntos Necesarios',
                    hintText: 'ej. 50',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa los puntos';
                    }
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Ingresa un número entero positivo';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  widget.onRewardAdded?.call(
                    titleController.text.trim(),
                    int.parse(pointsController.text.trim()),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPrimary,
                foregroundColor: Colors.white,
                shadowColor: AppTheme.gameBorder,
                elevation: 0,
              ),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showClaimConfirmationDialog(BuildContext context, FamilyReward reward) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Confirmar Canje', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('¿Deseas canjear "${reward.title}" por ${reward.points} puntos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onRewardClaimed?.call(reward.id, reward.points);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isParent ? 'ADMINISTRAR RECOMPENSAS' : 'CANJEAR RECOMPENSAS',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              if (widget.isParent)
                ElevatedButton.icon(
                  onPressed: () => _showAddRewardDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Crear Premio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 0,
                    shadowColor: AppTheme.gameBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Total points animated display
          AnimatedBuilder(
            animation: _pointsAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentTertiary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.gameBorder, width: 3),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.gameBorder, blurRadius: 0, offset: Offset(4, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.gameBorder, width: 3),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppTheme.warning, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isParent ? 'Saldo del Hogar' : 'Tus Puntos Disponibles',
                            style: const TextStyle(
                              fontSize: 14, 
                              color: AppTheme.textDark, 
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_pointsAnimation.value} XP',
                            style: const TextStyle(
                              fontSize: 32, 
                              fontWeight: FontWeight.w900, 
                              color: AppTheme.textDark,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
          const SizedBox(height: 24),

          if (widget.rewards.isEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              borderRadius: 24,
              backgroundColor: Colors.white,
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.card_giftcard_rounded, size: 48, color: AppTheme.textMuted),
                    SizedBox(height: 16),
                    Text(
                      'No hay recompensas creadas todavía.',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.rewards.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final reward = widget.rewards[index];
                final canClaim = widget.totalPoints >= reward.points;
                final progress = (widget.totalPoints / reward.points).clamp(0.0, 1.0);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.gameBorder, width: 3),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.gameBorder, blurRadius: 0, offset: Offset(4, 6)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Reward Icon with Gradient
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: canClaim ? AppTheme.accentSecondary : AppTheme.textMuted.withValues(alpha: 0.2),
                            border: Border.all(color: AppTheme.gameBorder, width: 2),
                          ),
                          child: Icon(Icons.card_giftcard_rounded, color: canClaim ? Colors.white : AppTheme.textMuted, size: 28),
                        ),
                        const SizedBox(width: 16),

                        // Title & Progress Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: canClaim ? AppTheme.textDark : AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor: AppTheme.textMuted.withValues(alpha: 0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          canClaim ? AppTheme.success : AppTheme.accentTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${reward.points} pts',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: canClaim ? AppTheme.success : AppTheme.accentTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Action Button
                        if (widget.isParent)
                          IconButton(
                            onPressed: () => widget.onRewardDeleted?.call(reward.id),
                            icon: const Icon(Icons.delete_rounded, color: AppTheme.danger),
                            tooltip: 'Eliminar Recompensa',
                          )
                        else
                          ElevatedButton(
                            onPressed: canClaim ? () => _showClaimConfirmationDialog(context, reward) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.success,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade100,
                              disabledForegroundColor: Colors.grey.shade400,
                              elevation: canClaim ? 4 : 0,
                              shadowColor: AppTheme.success.withValues(alpha: 0.4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              canClaim ? 'Canjear' : 'Faltan',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
