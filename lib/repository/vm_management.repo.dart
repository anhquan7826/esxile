import 'package:esxile/model/vm.model.dart';
import 'package:esxile/repository/esxile.repo.dart';

abstract class VMManagementRepository extends EsxileRepository {
  Future<List<VirtualMachine>> getVirtualMachines();

  Future<void> editVirtualMachine(VirtualMachine vm, {required List<String> fields});

  Future<void> cloneVirtualMachine(VirtualMachine vm);

  Future<void> deleteVirtualMachine(VirtualMachine vm);

  Future<void> importVirtualMachine({
    required String ovfPath,
    required String installationPath,
    required String vmName,
    required void Function(int?) onProgress,
  });

  Future<void> exportVirtualMachine({
    required String vmPath,
    required String exportPath,
    required void Function(int?) onProgress,
  });
}
