import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ImportDialig extends StatefulWidget {
  const ImportDialig({super.key, required this.onSubmit});

  final void Function(String ovfFile, String installationFolder, String name, int processors, int memory) onSubmit;

  @override
  State<ImportDialig> createState() => _ImportDialigState();
}

class ConfiguredOVF {
  ConfiguredOVF({required this.tag, required this.name, required this.path});

  final String tag;
  final String name;
  String? path;
}

class _ImportDialigState extends State<ImportDialig> {
  final List<ConfiguredOVF> ovfs = [
    ConfiguredOVF(tag: 'ubuntu22.04', name: 'Ubuntu 22.04', path: '/home/anhquan7826/vmware/ovfs/ubuntu2204/ubuntu2204.ovf'),
    ConfiguredOVF(tag: 'win10', name: 'Windows 10', path: '/home/anhquan7826/vmware/ovfs/win10/win10.ovf'),
    ConfiguredOVF(tag: 'custom', name: 'Custom OVF file', path: null),
  ];

  late ConfiguredOVF selectedOvf = ovfs.first;
  String? installationFolder;
  TextEditingController nameController = TextEditingController();
  TextEditingController processorsController = TextEditingController(text: '2');
  TextEditingController memoryController = TextEditingController(text: '4096');

  @override
  void dispose() {
    nameController.dispose();
    processorsController.dispose();
    memoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New virtual machine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('OVF File:'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: DropdownButton<ConfiguredOVF>(
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    isDense: true,
                    items: [
                      ...ovfs.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name),
                          )),
                    ],
                    value: selectedOvf,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          selectedOvf = value;
                        }
                      });
                    },
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: (selectedOvf.tag != 'custom')
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () async {
                            selectedOvf.path = (await FilePicker.platform.pickFiles(
                                  dialogTitle: 'Choose OVF file...',
                                  initialDirectory: selectedOvf.path,
                                  allowedExtensions: ['ovf'],
                                  type: FileType.custom,
                                  lockParentWindow: true,
                                ))
                                    ?.files
                                    .single
                                    .path ??
                                selectedOvf.path;
                            setState(() {});
                          },
                          child: Text(selectedOvf.path?.split('/').last ?? 'Choose...'),
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Expanded(child: Text('Installation folder:')),
                Flexible(
                  flex: 3,
                  child: TextButton(
                    onPressed: () async {
                      installationFolder = (await FilePicker.platform.getDirectoryPath(
                            dialogTitle: 'Choose installation folder...',
                            initialDirectory: installationFolder,
                            lockParentWindow: true,
                          )) ??
                          installationFolder;
                      setState(() {});
                    },
                    child: Text(installationFolder ?? 'Choose...'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Expanded(child: Text('Set processors:')),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: processorsController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\b]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      suffix: Text('Processor'),
                      hintText: 'Maximum 8 processors',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Expanded(child: Text('Set memory:')),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: memoryController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\b]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      suffix: Text('MB'),
                      hintText: 'Maximum 12228MB',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Expanded(child: Text('VM name:')),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: (selectedOvf.path == null ||
                  installationFolder == null ||
                  nameController.text.trim().isEmpty ||
                  (processorsController.text.isEmpty || int.parse(processorsController.text) > 8) ||
                  (memoryController.text.isEmpty || int.parse(memoryController.text) > 12228))
              ? null
              : () {
                  widget.onSubmit(selectedOvf.path!, installationFolder!, nameController.text.trim(), int.parse(processorsController.text),
                      int.parse(memoryController.text));
                  context.pop();
                },
          child: const Text('Import'),
        ),
      ],
    );
  }
}
