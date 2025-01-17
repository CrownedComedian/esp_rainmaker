import 'package:esp_rainmaker/esp_rainmaker.dart';
import 'package:esp_rainmaker/src/url_base.dart';
import 'package:http/http.dart';
import 'package:isolate_json/isolate_json.dart';

/// Provides access to methods for associating a node with a user.
class NodeAssociation {
  final String accessToken;
  final URLBase _urlBase;

  static const String _nodesBase = 'user/nodes';
  static const String _nodeConfig = _nodesBase + '/config';
  static const String _nodeMapping = _nodesBase + '/mapping';
  static const String _nodeStatus = _nodesBase + '/status';
  static const String _nodeSharing = _nodesBase + '/sharing';

  /// Constructs object to access node association methods.
  ///
  /// Requires [accessToken] obtained from authentication.
  /// Uses the default API version of v1, though an
  /// alternative version can be specified.
  NodeAssociation(this.accessToken, [APIVersion version = APIVersion.v1])
      : _urlBase = URLBase(version);

  /// Gets the nodes associated with the user
  ///
  /// Can optionally include node details by setting [includeNodeDetails]
  /// true. Will throw an exception when there is a failure containing
  /// a description of the failure.
  Future<NodesList> nodes(
      {String? nodeId,
      bool includeNodeDetails = false,
      bool status = true,
      bool config = true,
      bool params = true,
      String? startId,
      int? numRecords,
      showTags = false,
      isMatter = false}) async {
    final uri = _urlBase.getPath(_nodesBase, {
      'node_id': nodeId ?? '',
      'node_details': includeNodeDetails.toString(),
      'status': status.toString(),
      'config': config.toString(),
      'params': params.toString(),
      'start_id': startId ?? '',
      'num_records': numRecords?.toString() ?? '',
      'show_tags': showTags.toString(),
      'is_matter': isMatter.toString(),
    });

    final resp = await get(
      uri,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }

    return NodesList.fromJson(bodyResp);
  }

  /// Adds tags to the given **nodeId**.
  ///
  /// Will throw an exception when there is a failure containing a
  /// description of the failure.
  Future<void> addNodeTags(String nodeId, Map<String, String> tags) async {
    final uri = _urlBase.getPath(_nodesBase, {
      'node_id': nodeId,
    });

    final body = await JsonIsolate().encodeJson({
      'tags': tags.entries.map((entry) => "${entry.key}:${entry.value}").toList(),
    });

    final resp = await put(
      uri,
      body: body,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
    await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }
  }

  /// Removes tags of the given node.
  ///
  /// Will throw an exception when there is a failure containing a
  /// description of the failure.
  Future<void> removeTags(String nodeId, Map<String, String> tags) async {
    final uri = _urlBase.getPath(_nodesBase, {
      'node_id': nodeId,
    });

    final body = await JsonIsolate().encodeJson({
      'tags': tags.entries.map((entry) => "${entry.key}:${entry.value}").toList(),
    });

    final resp = await delete(
      uri,
      body: body,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
    await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }
  }

  /// Gets the configuration of a single node.
  ///
  /// Will throw an exception when there is a failure containing a
  /// description of the failure.
  Future<NodeConfig> nodeConfig(String nodeId) async {
    final uri = _urlBase.getPath(_nodeConfig, {
      'nodeid': nodeId,
    });

    final resp = await get(
      uri,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }

    return NodeConfig.fromJson(bodyResp);
  }

  /// Adds a user node mapping and returns the **request id**.
  ///
  /// Will throw an exception when there is a failure containing a
  /// description of the failure.
  Future<String> addNodeMapping(String nodeId, String secretKey) async {
    final uri = _urlBase.getPath(_nodeMapping);

    final body = await JsonIsolate().encodeJson({
      'node_id': nodeId,
      'secret_key': secretKey,
      'operation': 'add',
    });

    final resp = await put(
      uri,
      body: body,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }

    return bodyResp['request_id'];
  }

  /// Removes a user node mapping.
  ///
  /// Will throw an exception when there is a failure containing a
  /// description of the failure.
  Future<void> removeNodeMapping(String nodeId) async {
    final uri = _urlBase.getPath(_nodeMapping);

    final body = await JsonIsolate().encodeJson({
      'node_id': nodeId,
      'operation': 'remove',
    });

    final resp = await put(
      uri,
      body: body,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }
  }

  /// Gets the status of User Node mapping request.
  ///
  /// Will throw an exception when there is a failure containing a
  /// description of the failure.
  Future<MappingStatus> getMappingStatus(String requestId) async {
    final uri = _urlBase.getPath(_nodeMapping, {
      'request_id': requestId,
    });

    final resp = await get(
      uri,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }

    return MappingStatus.fromJson(bodyResp);
  }

  /// Get the connectivity status for the node.
  ///
  /// Will throw an exception when there is a failure containing a
  /// description of the failure.
  Future<NodeConnectivity> getNodeStatus(String nodeId) async {
    final uri = _urlBase.getPath(_nodeStatus, {
      'nodeid': nodeId,
    });

    final resp = await get(
      uri,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }

    return NodeConnectivity.fromJson(bodyResp['connectivity']);
  }

  /// Shares nodes with another user.
  ///
  /// Takes list of node ids to share and
  /// a single email to share them with.
  Future<void> share(List<String> nodeIds, String email) async {
    final uri = _urlBase.getPath(_nodeSharing);

    final body = await JsonIsolate().encodeJson({
      'nodes': nodeIds,
      'email': email,
    });

    final resp = await put(
      uri,
      body: body,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }
  }

  /// Unshares nodes with another user.
  ///
  /// Takes list of node ids to share and
  /// a single email to share them with.
  Future<void> unshare(List<String> nodeIds, String email) async {
    final uri = _urlBase.getPath(_nodeSharing, {
      'nodes': nodeIds.reduce((value, element) => '$value,$element'),
      'email': email,
    });

    final resp = await delete(
      uri,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final Map<String, dynamic> bodyResp =
        await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      throw bodyResp['description'];
    }
  }

  /// Obtains who a node is shared with.
  ///
  /// Optionally takes the id of the node and returns
  /// who it's shared with.
  Future<List<SharingDetail>> getShare([String? nodeId]) async {
    final uri = _urlBase.getPath(_nodeSharing, {
      'node_id': nodeId ?? '',
    });

    final resp = await get(
      uri,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );
    final dynamic bodyResp = await JsonIsolate().decodeJson(resp.body);
    if (resp.statusCode != 200) {
      if (bodyResp is Map) {
        throw bodyResp['description'];
      }
      throw 'Bad state!';
    }

    return bodyResp['node_sharing']
        ?.map<SharingDetail>((e) => SharingDetail.fromJson(e))
        ?.toList();
  }
}
