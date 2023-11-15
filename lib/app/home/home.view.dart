import 'package:esxile/app/home/home.cubit.dart';
import 'package:esxile/app/home/home.state.dart';
import 'package:esxile/app/home/widgets/import_dialog.dart';
import 'package:esxile/model/vm.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeCubit get cubit => BlocProvider.of(context);

  VirtualMachine? currentSelected;
  final List<VirtualMachine> cloningVM = [];
  final Map<VirtualMachine, int?> exportingVM = {};

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is CloningVMState) {
          setState(() {
            cloningVM.add(state.vm);
          });
        }
        if (state is VMClonedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Virtual machine ${state.vm.displayName} has been cloned.')),
          );
          setState(() {
            cloningVM.remove(state.vm);
          });
        }
        if (state is VMCloneErrorState) {
          setState(() {
            cloningVM.remove(state.vm);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error while cloning ${state.vm.displayName}! ${state.error}')),
          );
        }
        if (state is ExportingVMState) {
          setState(() {
            exportingVM[state.vm] = state.progress;
          });
        }
        if (state is ExportedVMState) {
          setState(() {
            exportingVM.remove(state.vm);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Virtual machine ${state.vm.displayName} has been exported.')),
          );
        }
        if (state is ExportVMErrorState) {
          setState(() {
            exportingVM.remove(state.vm);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot export ${state.vm.displayName}! ${state.error}')),
          );
        }
        if (state is DeleteVMState) {
          setState(() {
            currentSelected = null;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Virtual machine ${state.vm.displayName} has been deleted.')),
            );
          });
        }
      },
      buildWhen: (_, state) {
        return state is VMLoadedState || state is LoadingVMState || state is LoadVMErrorState;
      },
      builder: (context, state) {
        return Scaffold(
          // appBar: () {
          //   if (state is VMLoadedState) {
          //     return AppBar(
          //       // title: Row(),
          //       actions: [
          //         Padding(
          //           padding: const EdgeInsets.only(right: 16),
          //           child: FilledButton.icon(
          //             onPressed: () {},
          //             icon: const Icon(Icons.import_export_rounded),
          //             label: const Text('Import'),
          //           ),
          //         )
          //       ],
          //     );
          //   }
          // }.call(),
          body: () {
            if (state is LoadingVMState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is LoadVMErrorState) {
              return Center(
                child: Column(
                  children: [
                    const Text('Cannot load virtual machines!'),
                    FilledButton(
                      onPressed: () {
                        cubit.load();
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Virtual Machines'),
                            FilledButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ImportDialig(
                                      onSubmit: (ovfFile, installationFolder, name) {
                                        cubit.import(ovfPath: ovfFile, installationPath: installationFolder, name: name);
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Text('Import'),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: cubit.vmList.length,
                            itemBuilder: (context, index) {
                              return buildVMTile(cubit.vmList[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: currentSelected == null
                        ? const Center(
                            child: Text('Select a virtual machine.'),
                          )
                        : Column(
                            children: [
                              Text(currentSelected!.displayName),
                              Table(
                                children: [
                                  TableRow(
                                    children: [
                                      const TableCell(
                                        child: Text('ID'),
                                      ),
                                      TableCell(
                                        child: Text(currentSelected!.id),
                                      )
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const TableCell(
                                        child: Text('Path'),
                                      ),
                                      TableCell(
                                        child: Text(currentSelected!.path),
                                      )
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const TableCell(
                                        child: Text('Processors'),
                                      ),
                                      TableCell(
                                        child: Text(currentSelected!.processors.toString()),
                                      )
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const TableCell(
                                        child: Text('Memory'),
                                      ),
                                      TableCell(
                                        child: Text('${currentSelected!.memory} MB'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  FilledButton(
                                    onPressed: () {
                                      cubit.clone(currentSelected!);
                                    },
                                    child: const Text('Clone this VM'),
                                  ),
                                  if (cloningVM.contains(currentSelected)) const CircularProgressIndicator(),
                                  FilledButton(
                                    onPressed: () {
                                      cubit.export(currentSelected!);
                                    },
                                    child: const Text('Export to OVF'),
                                  ),
                                  if (exportingVM.containsKey(currentSelected))
                                    CircularProgressIndicator(
                                      value: exportingVM[currentSelected] == null ? null : (exportingVM[currentSelected]! / 100).toDouble(),
                                    ),
                                  FilledButton(
                                    onPressed: () {
                                      cubit.delete(currentSelected!);
                                    },
                                    child: const Text('Delete this VM'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ],
              );
            }
          }.call(),
        );
      },
    );
  }

  Widget buildVMTile(VirtualMachine vm) {
    return ListTile(
      selected: currentSelected == vm,
      leading: const Icon(Icons.computer_rounded),
      title: Text(vm.displayName),
      onTap: () {
        setState(() {
          currentSelected = vm;
        });
      },
    );
  }
}
