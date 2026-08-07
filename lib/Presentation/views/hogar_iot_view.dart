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
    Color activeColor = AppTheme.glassCyan;
    
    if (device.type == 'thermostat') {
      iconEmoji = '🌡️';
      activeColor = AppTheme.warning;
    } else if (device.type == 'tv') {
      iconEmoji = '📺';
      activeColor = AppTheme.glassPurple;
    } else {
      activeColor = AppTheme.glassCyan;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: device.isOn 
            ? LinearGradient(
                colors: [activeColor.withValues(alpha: 0.15), activeColor.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: device.isOn ? AppTheme.cardGlass.withValues(alpha: 0.3) : AppTheme.cardGlass,
        boxShadow: [
          if (device.isOn)
            BoxShadow(
              color: activeColor.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
        ],
        border: Border.all(
          color: device.isOn ? activeColor.withValues(alpha: 0.5) : AppTheme.borderGlass,
          width: 1.5,
        ),
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
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
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
                        color: device.isOn ? AppTheme.textLight : AppTheme.textMuted,
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
                            boxShadow: device.isOn ? [
                              BoxShadow(color: activeColor.withValues(alpha: 0.5), blurRadius: 4)
                            ] : null,
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
