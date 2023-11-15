import 'package:esxile/app/home/home.cubit.dart';
import 'package:esxile/app/home/home.state.dart';
import 'package:esxile/app/home/widgets/import_dialog.dart';
import 'package:esxile/model/vm.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  final Map<String, int?> importingVM = {};

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
        if (state is ImportingVMState) {
          setState(() {
            importingVM[state.name] = state.progress;
          });
        }
        if (state is ImportedVMState) {
          setState(() {
            importingVM.remove(state.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Virtual machine ${state.name} has been imported.'),
              ),
            );
          });
        }
        if (state is ImportVMErrorState) {
          setState(() {
            importingVM.remove(state.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot import virtual machine ${state.name}! ${state.error}'),
              ),
            );
          });
        }
      },
      buildWhen: (_, state) {
        return state is VMLoadedState || state is LoadingVMState || state is LoadVMErrorState;
      },
      builder: (context, state) {
        return Scaffold(
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
                    child: buildSidebar(),
                  ),
                  const VerticalDivider(
                    width: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: currentSelected == null
                        ? const Center(
                            child: Text('Select a virtual machine.'),
                          )
                        : buildContent(),
                  ),
                ],
              );
            }
          }.call(),
        );
      },
    );
  }

  Widget buildSidebar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 32),
            child: Text(
              'Virtual Machines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...cubit.vmList.map((e) {
                  return buildVMTile(e);
                }),
                ...importingVM.entries.map((e) {
                  return buildLoadingVMTile(
                    e.key,
                    progress: e.value == null ? null : e.value! / 100,
                  );
                }),
              ],
            ),
          ),
          TextButton.icon(
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
            icon: const Icon(Icons.add_rounded),
            label: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentSelected!.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text(
                'Virtual machine informations:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(4),
                },
                children: [
                  buildInfoRow('ID', currentSelected!.id),
                  buildInfoRow('Path', currentSelected!.path),
                  buildInfoRow('Processor', currentSelected!.processors.toString()),
                  buildInfoRow('Memory', currentSelected!.memory.toString()),
                ],
              ),
            ),
            if (cloningVM.contains(currentSelected)) buildProgressIndicator('Cloning ${currentSelected!.displayName}...'),
            if (exportingVM.containsKey(currentSelected))
              buildProgressIndicator(
                'Exporting ${currentSelected!.displayName}...',
                value: exportingVM[currentSelected] == null ? null : (exportingVM[currentSelected]! / 100).toDouble(),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: cloningVM.contains(currentSelected)
                      ? null
                      : () {
                          cubit.clone(currentSelected!);
                        },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Clone this VM'),
                ),
                FilledButton.icon(
                  onPressed: exportingVM.containsKey(currentSelected)
                      ? null
                      : () {
                          cubit.export(currentSelected!);
                        },
                  icon: const Icon(Icons.outbox_rounded),
                  label: const Text('Export to OVF'),
                ),
                FilledButton.icon(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: (cloningVM.contains(currentSelected) || exportingVM.containsKey(currentSelected))
                      ? null
                      : () {
                          showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Warning'),
                                  content: const Text('Are you sure to delete this virtual machine?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.pop(false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.pop(true);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              }).then((value) {
                            if (value == true) {
                              cubit.delete(currentSelected!);
                            }
                          });
                        },
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Delete this VM'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressIndicator(String title, {double? value}) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(title + ((value == null) ? '' : ' (${(value * 100).round()}%)')),
          ),
          LinearProgressIndicator(
            value: value,
          ),
        ],
      ),
    );
  }

  TableRow buildInfoRow(String title, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildVMTile(VirtualMachine vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        selected: currentSelected == vm,
        leading: const Icon(Icons.computer_rounded),
        title: Text(vm.displayName),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: currentSelected == vm
                ? BorderSide(
                    color: Colors.blue.shade200,
                  )
                : BorderSide.none),
        onTap: () {
          setState(() {
            currentSelected = vm;
          });
        },
      ),
    );
  }

  Widget buildLoadingVMTile(String name, {double? progress}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: progress,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.grey),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
