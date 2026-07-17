import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class RecompensasView extends StatelessWidget {
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

  void _showAddRewardDialog(BuildContext context) {
    final titleController = TextEditingController();
    final pointsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                  onRewardAdded?.call(
                    titleController.text.trim(),
                    int.parse(pointsController.text.trim()),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.electricBlue,
                foregroundColor: Colors.white,
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
          title: const Text('Confirmar Canje', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('¿Deseas canjear "${reward.title}" por ${reward.points} puntos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                onRewardClaimed?.call(reward.id, reward.points);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
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
                isParent ? 'ADMINISTRAR RECOMPENSAS' : 'CANJEAR RECOMPENSAS',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8E9CB2),
                  letterSpacing: 0.8,
                ),
              ),
              if (isParent)
                ElevatedButton.icon(
                  onPressed: () => _showAddRewardDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Crear Premio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.electricBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Total points display
          GlassCard(
            padding: const EdgeInsets.all(16.0),
            borderRadius: 20,
            backgroundColor: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isParent ? 'Saldo del Hogar' : 'Tus Puntos Disponibles',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalPoints pts',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (rewards.isEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              borderRadius: 24,
              backgroundColor: Colors.white,
              child: const Center(
                child: Text(
                  'No hay recompensas creadas todavía.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rewards.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reward = rewards[index];
                final canClaim = totalPoints >= reward.points;

                return GlassCard(
                  padding: const EdgeInsets.all(16.0),
                  borderRadius: 24,
                  backgroundColor: Colors.white,
                  child: Row(
                    children: [
                      // Reward Icon / Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.electricBlue.withValues(alpha: 0.08),
                        ),
                        child: const Icon(Icons.card_giftcard, color: AppTheme.electricBlue, size: 24),
                      ),
                      const SizedBox(width: 16),

                      // Title & Points Cost
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Costo: ${reward.points} pts',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Button
                      if (isParent)
                        IconButton(
                          onPressed: () => onRewardDeleted?.call(reward.id),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        )
                      else
                        ElevatedButton(
                          onPressed: canClaim ? () => _showClaimConfirmationDialog(context, reward) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: Text(
                            canClaim ? 'Canjear' : 'Faltan Puntos',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
