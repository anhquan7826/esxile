import 'package:equatable/equatable.dart';
import 'package:esxile/model/vm.model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class LoadingVMState extends HomeState {
  const LoadingVMState();

  @override
  List<Object?> get props => [];
}

class VMLoadedState extends HomeState {
  const VMLoadedState(this.vms);

  final List<VirtualMachine> vms;

  @override
  List<Object?> get props => vms;
}

class LoadVMErrorState extends HomeState {
  const LoadVMErrorState();

  @override
  List<Object?> get props => [];
}

class CloningVMState extends HomeState {
  const CloningVMState(this.vm);

  final VirtualMachine vm;
  @override
  List<Object?> get props => [vm];
}

class VMClonedState extends HomeState {
  const VMClonedState(this.vm);

  final VirtualMachine vm;
  @override
  List<Object?> get props => [vm];
}

class VMCloneErrorState extends HomeState {
  const VMCloneErrorState(this.vm, this.error);

  final VirtualMachine vm;
  final String error;
  @override
  List<Object?> get props => [vm];
}

class ExportingVMState extends HomeState {
  const ExportingVMState(this.vm, {this.progress});

  final VirtualMachine vm;
  final int? progress;
  @override
  List<Object?> get props => [vm, progress];
}

class ExportedVMState extends HomeState {
  const ExportedVMState(this.vm);

  final VirtualMachine vm;
  @override
  List<Object?> get props => [vm];
}

class ExportVMErrorState extends HomeState {
  const ExportVMErrorState(this.vm, this.error);

  final VirtualMachine vm;
  final String error;

  @override
  List<Object?> get props => [vm, error];
}

class DeleteVMState extends HomeState {
  const DeleteVMState(this.vm);

  final VirtualMachine vm;
  @override
  List<Object?> get props => [vm];
}

class ImportingVMState extends HomeState {
  const ImportingVMState(this.name, {this.progress});
  final String name;
  final int? progress;

  @override
  List<Object?> get props => [name, progress];
}

class ImportedVMState extends HomeState {
  const ImportedVMState(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

class ImportVMErrorState extends HomeState {
  const ImportVMErrorState(this.name, this.error);

  final String name;
  final String error;

  @override
  List<Object?> get props => [name];
}

class EditVMState extends HomeState {
  const EditVMState(this.vm);

  final VirtualMachine vm;
  
  @override
  List<Object?> get props => [vm];
}
