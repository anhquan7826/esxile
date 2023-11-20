import 'package:esxile/model/vm.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class EditDialog extends StatefulWidget {
  const EditDialog({super.key, required this.vm, required this.onEdit});

  final VirtualMachine vm;
  final void Function(VirtualMachine) onEdit;

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController processorsController = TextEditingController(
    text: widget.vm.processors.toString(),
  );
  late TextEditingController memoryController = TextEditingController(
    text: widget.vm.memory.toString(),
  );
  late TextEditingController nameController = TextEditingController(
    text: widget.vm.displayName,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.vm.displayName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Expanded(child: Text('Set processors:')),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
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
                ),
              ],
            ),
          )
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
          onPressed: ((processorsController.text.isEmpty || int.parse(processorsController.text) > 8) ||
                  (memoryController.text.isEmpty || int.parse(memoryController.text) > 12228) ||
                  nameController.text.trim().isEmpty)
              ? null
              : () {
                  widget.onEdit(widget.vm.copy(
                    displayName: nameController.text.trim(),
                    processors: int.parse(processorsController.text),
                    memory: int.parse(memoryController.text),
                  ));
                  context.pop();
                },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
