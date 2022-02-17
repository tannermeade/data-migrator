import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:console_flutter_sdk/models.dart' as aw;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectWidget extends ConsumerWidget {
  const ProjectWidget({Key? key, required this.project, required this.onTap}) : super(key: key);

  final aw.Project project;
  final Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var dataOrigin = ref.read(destinationOriginProvider);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: dataOrigin.selectedProject != null && dataOrigin.selectedProject!.$id == project.$id
                    ? Colors.blueAccent
                    : Colors.grey),
          ),
          child: Text(project.name),
        ),
      ),
    );
  }
}
