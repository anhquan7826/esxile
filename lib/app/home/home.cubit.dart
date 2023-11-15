import 'package:esxile/app/home/home.state.dart';
import 'package:esxile/model/vm.model.dart';
import 'package:esxile/repository/vm_management.repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.vmRepo) : super(const LoadingVMState()) {
    load();
  }

  final VMManagementRepository vmRepo;

  late List<VirtualMachine> vmList;

  Future<void> load() async {
    emit(const LoadingVMState());
    try {
      vmList = await vmRepo.getVirtualMachines();
      emit(VMLoadedState(vmList));
    } catch (e) {
      emit(const LoadVMErrorState());
    }
  }

  Future<void> import({
    required String ovfPath,
    required String installationPath,
    required String name,
  }) async {
    await vmRepo.importVirtualMachine(
      ovfPath: ovfPath,
      installationPath: installationPath,
      vmName: name,
      onProgress: (progress) {},
    );
  }

  Future<void> export(VirtualMachine vm) async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose export folder path',
    );
    if (path == null) {
      return;
    }
    emit(ExportingVMState(vm));
    try {
      await vmRepo.exportVirtualMachine(
        vmPath: vm.path,
        exportPath: path,
        onProgress: (progress) {
          emit(ExportingVMState(vm, progress: progress));
        },
      );
      emit(ExportedVMState(vm));
    } catch (e) {
      emit(ExportVMErrorState(vm, e.toString()));
    }
  }

  Future<void> clone(VirtualMachine vm) async {
    emit(CloningVMState(vm));
    try {
      await vmRepo.cloneVirtualMachine(vm.copy(displayName: '${vm.displayName}_copy'));
      vmList = await vmRepo.getVirtualMachines();
      emit(VMClonedState(vm));
    } on Exception catch (e) {
      emit(VMCloneErrorState(vm, e.toString()));
    }
  }

  Future<void> delete(VirtualMachine vm) async {
    await vmRepo.deleteVirtualMachine(vm);
    vmList = await vmRepo.getVirtualMachines();
    emit(DeleteVMState(vm));
  }
}