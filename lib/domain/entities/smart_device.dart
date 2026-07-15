class SmartDevice {
  final String id;
  final String name;
  final bool isOn;
  final String type; // 'light', 'thermostat', 'tv'

  const SmartDevice({
    required this.id,
    required this.name,
    required this.isOn,
    required this.type,
  });

  SmartDevice copyWith({
    String? id,
    String? name,
    bool? isOn,
    String? type,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      isOn: isOn ?? this.isOn,
      type: type ?? this.type,
    );
  }
}
