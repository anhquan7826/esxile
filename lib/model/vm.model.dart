import 'package:json_annotation/json_annotation.dart';

part 'vm.model.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class VirtualMachine {
  VirtualMachine({
    required this.id,
    required this.displayName,
    required this.path,
    required this.memory,
    required this.processors,
  });

  factory VirtualMachine.fromJson(Map<String, dynamic> json) => _$VirtualMachineFromJson(json);

  final String id;
  final String displayName;
  final String path;
  final int memory;
  final int processors;

  Map<String, dynamic> toJson() => _$VirtualMachineToJson(this);

  VirtualMachine copy({
    String? displayName,
    int? memory,
    int? processors,
  }) {
    return VirtualMachine(
      id: id,
      displayName: displayName ?? this.displayName,
      path: path,
      memory: memory ?? this.memory,
      processors: processors ?? this.processors,
    );
  }
}
