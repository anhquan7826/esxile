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
  Future<void> editVirtualMachine(String id, {String? name, int? processors, int? memory}) async {
    if (name != null) {
      await dio.put(
        '/vms/$id/params',
        data: jsonEncode({
          'name': 'displayName',
          'value': name,
        }),
      );
    }
    if (processors != null || memory != null) {
      await dio.put(
        '/vms/$id',
        data: jsonEncode({
          if (processors != null) 'processors': processors,
          if (memory != null) 'memory': memory,
        }),
      );
    }
  }

  @override
  Future<String> cloneVirtualMachine(VirtualMachine vm) async {
    final result = await dio.post(
      '/vms',
      data: jsonEncode({
        'name': '${vm.displayName}_copy',
        'parentId': vm.id,
      }),
    );
    return (result.data as Map)['id'].toString();
  }

  @override
  Future<String> importVirtualMachine({
    required String ovfPath,
    required String installationPath,
    required String vmName,
    required void Function(int?) onProgress,
  }) async {
    final process = await Process.start(
      'ovftool',
      ['--name=$vmName', ovfPath, installationPath],
      runInShell: true,
    );
    onProgress.call(0);
    String lastLine = '';
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      lastLine = line;
      if (line.contains('Disk progress')) {
        onProgress(int.parse(RegExp(r'Disk progress: (\d+)%').firstMatch(line)!.group(1)!));
      }
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception(lastLine);
    }
    return (await dio.post('/vms/registration', data: jsonEncode({'name': vmName, 'path': '$installationPath/$vmName/$vmName.vmx'}))).data['id'];
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
      runInShell: true,
    );
    onProgress.call(null);
    String lastLine = '';
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      lastLine = line;
      if (line.contains('Disk progress')) {
        onProgress(int.parse(RegExp(r'Disk progress: (\d+)%').firstMatch(line)!.group(1)!));
      }
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception(lastLine);
    }
  }

  @override
  Future<void> deleteVirtualMachine(VirtualMachine vm) async {
    await dio.delete('/vms/${vm.id}');
  }

  @override
  Future<void> registerVirtualMachine({required String name, required String path}) async {
    await dio.post(
      '/vms/registration',
      data: jsonEncode({
        'name': name,
        'path': path,
      }),
    );
  }
}
