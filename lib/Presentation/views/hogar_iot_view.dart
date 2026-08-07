import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';

class HogarIotView extends StatelessWidget {
  final List<SmartDevice> devices;
  final ValueChanged<SmartDevice> onDeviceToggle;

  const HogarIotView({
    super.key,
    required this.devices,
    required this.onDeviceToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISPOSITIVOS DOMÉSTICOS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _SmartDeviceCard(
                device: device,
                onToggle: () => onDeviceToggle(device),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SmartDeviceCard extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onToggle;

  const _SmartDeviceCard({required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    String iconEmoji = '💡';
    Color activeColor = AppTheme.accentTertiary;
    
    if (device.type == 'thermostat') {
      iconEmoji = '🌡️';
      activeColor = AppTheme.accentPrimary;
    } else if (device.type == 'tv') {
      iconEmoji = '📺';
      activeColor = AppTheme.accentSecondary;
    } else {
      activeColor = AppTheme.accentTertiary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: AppTheme.gameBorder, width: 3),
        boxShadow: [
          if (device.isOn) ...[
            BoxShadow(
              color: activeColor,
              blurRadius: 0,
              offset: const Offset(4, 6),
            ),
          ] else ...[
            const BoxShadow(
              color: AppTheme.gameBorder,
              blurRadius: 0,
              offset: Offset(4, 6),
            ),
          ]
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedScale(
                      scale: device.isOn ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        iconEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: device.isOn,
                        onChanged: (_) => onToggle(),
                        activeColor: Colors.white,
                        activeTrackColor: activeColor,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppTheme.textMuted.withValues(alpha: 0.2),
                        trackOutlineColor: WidgetStateProperty.all(AppTheme.gameBorder),
                        trackOutlineWidth: WidgetStateProperty.all(2),
                      ),
                    ),
                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: device.isOn ? AppTheme.textDark : AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: device.isOn ? activeColor : const Color(0xFFCBD5E1),
                            border: Border.all(color: AppTheme.gameBorder, width: 2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          device.isOn ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 12,
                            color: device.isOn ? activeColor : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
