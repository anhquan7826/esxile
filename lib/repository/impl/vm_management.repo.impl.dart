import 'dart:convert';
import 'dart:io';

import 'package:esxile/model/vm.model.dart';
import 'package:esxile/repository/vm_management.repo.dart';

class VMManagementRepositoryImpl extends VMManagementRepository {
  @override
  Future<List<VirtualMachine>> getVirtualMachines() async {
    final idsResult = await dio.get('/vms');
    late final List<String> ids;
    late final List<String> paths;
    late final List<String> displayNames;
    late final List<int> processors;
    late final List<int> memories;
    ids = (idsResult.data as List).map((e) => (e as Map)['id'].toString()).toList();
    paths = (idsResult.data as List).map((e) => (e as Map)['path'].toString()).toList();
    displayNames = List.filled(ids.length, '');
    processors = List.filled(ids.length, -1);
    memories = List.filled(ids.length, -1);
    for (int i = 0; i < ids.length; i++) {
      final displayNameResult = await dio.get('/vms/${ids[i]}/params/displayName');
      displayNames[i] = (displayNameResult.data as Map)['value'].toString();
      final settingsResult = await dio.get('/vms/${ids[i]}');
      processors[i] = ((settingsResult.data as Map)['cpu'] as Map)['processors'] as int;
      memories[i] = (settingsResult.data as Map)['memory'] as int;
    }
    final result = <VirtualMachine>[];
    for (int i = 0; i < ids.length; i++) {
      result.add(VirtualMachine(
        id: ids[i],
        displayName: displayNames[i],
        path: paths[i],
        memory: memories[i],
        processors: processors[i],
      ));
    }
    return result;
  }

  @override
  Future<void> editVirtualMachine(VirtualMachine vm, {required List<String> fields}) async {
    if (fields.contains('displayName')) {
      final configParamResult = await dio.put('/vms/${vm.id}/configparams');
      // 404
      if (configParamResult.statusCode != 200) {
        throw Exception(configParamResult.statusMessage);
      }
    }
    await dio.put(
      '/vms/${vm.id}',
      data: jsonEncode({
        'processors': vm.processors,
        'memory': vm.memory,
      }),
    );
  }

  @override
  Future<void> cloneVirtualMachine(VirtualMachine vm) async {
    await dio.post(
      '/vms',
      data: jsonEncode({
        'name': vm.displayName,
        'parentId': vm.id,
      }),
    );
  }

  @override
  Future<void> importVirtualMachine({
    required String ovfPath,
    required String installationPath,
    required String vmName,
    required void Function(int?) onProgress,
  }) async {
    final process = await Process.start(
      'ovftool',
      [ovfPath, installationPath],
    );
    onProgress.call(0);
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line.contains('Disk progress')) {
        onProgress(int.parse(RegExp(r'Disk progress: (\d+)%').firstMatch(line)!.group(1)!));
      }
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception('Exitcode: $exitCode');
    }
    await dio.post('/vms/registration', data: jsonEncode({'name': vmName, 'path': installationPath}));
  }

  @override
  Future<void> exportVirtualMachine({
    required String vmPath,
    required String exportPath,
    required void Function(int?) onProgress,
  }) async {
    final process = await Process.start(
      'ovftool',
      [vmPath, exportPath],
    );
    onProgress.call(null);
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line.contains('Disk progress')) {
        onProgress(int.parse(RegExp(r'Disk progress: (\d+)%').firstMatch(line)!.group(1)!));
      }
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception('Exitcode: $exitCode');
    }
  }

  @override
  Future<void> deleteVirtualMachine(VirtualMachine vm) async {
    await dio.delete('/vms/${vm.id}');
  }
}
