import 'dart:convert';

import 'package:esxile/model/vm.model.dart';
import 'package:esxile/repository/esxile.repo.dart';

class VMManagementRepository extends EsxileRepository {
  Future<List<VirtualMachine>> getVirtualMachines() async {
    final idsResult = await dio.get('/vms');
    late final List<String> ids;
    late final List<String> paths;
    late final List<String> displayNames;
    late final List<int> processors;
    late final List<int> memories;
    if (idsResult.statusCode == 200) {
      ids = (idsResult.data as List).map((e) => (e as Map)['id'].toString()).toList();
      paths = (idsResult.data as List).map((e) => (e as Map)['path'].toString()).toList();
      displayNames = List.filled(ids.length, '');
      processors = List.filled(ids.length, -1);
      memories = List.filled(ids.length, -1);
      for (final i in ids.indexed) {
        final displayNameResult = await dio.get('/vms/${i.$2}/params/displayName');
        if (displayNameResult.statusCode == 200) {
          displayNames[i.$1] = (displayNameResult.data as Map)['value'].toString();
        } else {
          throw Exception(idsResult.statusMessage);
        }
        final settingsResult = await dio.get('/vms/${i.$2}');
        if (settingsResult.statusCode == 200) {
          processors[i.$1] = int.parse(((settingsResult.data as Map)['cpu'] as Map)['processors']);
          memories[i.$1] = int.parse((settingsResult.data as Map)['memory']);
        } else {
          throw Exception(idsResult.statusMessage);
        }
      }
    } else {
      throw Exception(idsResult.statusMessage);
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

  Future<void> editVirtualMachine(VirtualMachine vm, {required List<String> fields}) async {
    if (fields.contains('displayName')) {
      final configParamResult = await dio.put('/vms/${vm.id}/configparams');
      // 404
      if (configParamResult.statusCode != 200) {
        throw Exception(configParamResult.statusMessage);
      }
    }
    if (fields.contains('processors') || fields.contains('memory')) {
      final vmSettingsResult = await dio.put(
        '/vms/${vm.id}',
        data: jsonEncode({
          'processors': vm.processors,
          'memory': vm.memory,
        }),
      );
      if (vmSettingsResult.statusCode != 200) {
        throw Exception(vmSettingsResult.statusMessage);
      }
    }
  }

  Future<void> cloneVirtualMachine(VirtualMachine vm) async {
    final cloneResult = await dio.post(
      '/vms',
      data: jsonEncode({
        'name': vm.displayName,
        'parentId': vm.id,
      }),
    );
    if (cloneResult.statusCode != 201) {
      throw Exception(cloneResult.statusMessage);
    }
  }

  Future<void> createVirtualMachine({required String name, required int processors, required int memory, }) async {

  }
}
