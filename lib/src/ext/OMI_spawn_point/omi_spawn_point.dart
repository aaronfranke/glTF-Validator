// Copyright 2022 The Khronos Group Inc.
//
// SPDX-License-Identifier: Apache-2.0

library gltf.extensions.omi_spawn_point;

import 'package:gltf/src/base/gltf_property.dart';
import 'package:gltf/src/ext/extensions.dart';

const String OMI_SPAWN_POINT = 'OMI_spawn_point';

const String TEAM = 'team';
const String TITLE = 'title';

const List<String> OMI_SPAWN_POINT_MEMBERS = <String>[
  TEAM,
  TITLE
];

class OmiSpawnPoint extends GltfProperty {
  final String team;
  final String title;

  OmiSpawnPoint._(this.team, this.title,
      Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  static OmiSpawnPoint fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, OMI_SPAWN_POINT_MEMBERS, context);
    }

    final team = getString(map, TYPE, context);
    final title = getString(map, TITLE, context);

    return OmiSpawnPoint._(
        team,
        title,
        getExtensions(map, OmiSpawnPoint, context),
        getExtras(map, context));
  }

  @override
  void link(Gltf gltf, Context context) {
    if (!context.validate) {
      return;
    }
    // Get the glTF node that this physics body is attached to.
    final path = context.path;
    if (path.length < 2 || path[0] != 'nodes') {
      return;
    }
    final nodeIndex = int.tryParse(path[1]);
    if (nodeIndex == null) {
      return;
    }
    final node = gltf.nodes[nodeIndex];
    // Ensure that the spawn point is not on the same node as a mesh or camera.
    if (node.mesh != null) {
      context.addIssue(SemanticError.omiSpawnPointInvalidNode);
    }
    if (node.camera != null) {
      context.addIssue(SemanticError.omiSpawnPointInvalidNode);
    }
  }
}

const Extension omiSpawnPointExtension = Extension(
    OMI_SPAWN_POINT, <Type, ExtensionDescriptor>{
  Node: ExtensionDescriptor(OmiSpawnPoint.fromMap)
});
