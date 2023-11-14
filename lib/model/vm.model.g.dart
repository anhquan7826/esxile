// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vm.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VirtualMachine _$VirtualMachineFromJson(Map<String, dynamic> json) =>
    VirtualMachine(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      path: json['path'] as String,
      memory: json['memory'] as int,
      processors: json['processors'] as int,
    );

Map<String, dynamic> _$VirtualMachineToJson(VirtualMachine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'path': instance.path,
      'memory': instance.memory,
      'processors': instance.processors,
    };
