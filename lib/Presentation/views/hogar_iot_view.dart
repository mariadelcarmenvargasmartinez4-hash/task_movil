import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

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
              color: Color(0xFF8E9CB2),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          // We can use a GridView or a custom Layout to mimic the exact layout of the screenshot
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _buildDeviceCard(context, device);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, SmartDevice device) {
    // Get emoji/icon and color depending on status and type
    String iconEmoji = '💡';
    if (device.type == 'thermostat') {
      iconEmoji = '🌡️';
    } else if (device.type == 'tv') {
      iconEmoji = '📺';
    }

    return GlassCard(
      padding: const EdgeInsets.all(14.0),
      borderRadius: 20,
      backgroundColor: Colors.white,
      shadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Switch Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                iconEmoji,
                style: const TextStyle(fontSize: 22),
              ),
              // Custom Switch style using Transform.scale
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: device.isOn,
                  onChanged: (value) => onDeviceToggle(device),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppTheme.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
            ],
          ),
          
          // Device Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                device.isOn ? 'Encendido' : 'Apagado',
                style: TextStyle(
                  fontSize: 11,
                  color: device.isOn ? AppTheme.electricBlue : AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
