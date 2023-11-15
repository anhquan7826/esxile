import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImportDialig extends StatefulWidget {
  const ImportDialig({super.key, required this.onSubmit});

  final void Function(String ovfFile, String installationFolder, String name) onSubmit;

  @override
  State<ImportDialig> createState() => _ImportDialigState();
}

class _ImportDialigState extends State<ImportDialig> {
  String? ovfPath;
  String? installationFolder;
  TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import virtual machine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: Text('OVF File:')),
              Flexible(
                flex: 3,
                child: TextButton(
                  onPressed: () async {
                    ovfPath =
                        (await FilePicker.platform.pickFiles(dialogTitle: 'Choose OVF file...', allowedExtensions: ['ovf'], type: FileType.custom))
                            ?.files
                            .single
                            .path;
                    setState(() {});
                  },
                  child: Text(ovfPath ?? 'Choose...'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Installlation folder:')),
              Flexible(
                flex: 3,
                child: TextButton(
                  onPressed: () async {
                    installationFolder = await FilePicker.platform.getDirectoryPath(
                      dialogTitle: 'Choose installation folder...',
                    );
                    setState(() {});
                  },
                  child: Text(installationFolder ?? 'Choose...'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('VM name:')),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: nameController,
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
          onPressed: (ovfPath == null || installationFolder == null || nameController.text.isEmpty)
              ? null
              : () {
                  widget.onSubmit(ovfPath!, installationFolder!, nameController.text);
                  context.pop();
                },
          child: const Text('Import'),
        ),
      ],
    );
  }
}
