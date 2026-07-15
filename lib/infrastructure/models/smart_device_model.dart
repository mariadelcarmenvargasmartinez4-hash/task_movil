import '../../domain/domain.dart';

class SmartDeviceModel extends SmartDevice {
  const SmartDeviceModel({
    required super.id,
    required super.name,
    required super.isOn,
    required super.type,
  });

  factory SmartDeviceModel.fromJson(Map<String, dynamic> json) {
    return SmartDeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isOn: json['isOn'] as bool,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOn': isOn,
      'type': type,
    };
  }

  static SmartDeviceModel fromEntity(SmartDevice entity) {
    return SmartDeviceModel(
      id: entity.id,
      name: entity.name,
      isOn: entity.isOn,
      type: entity.type,
    );
  }
}
