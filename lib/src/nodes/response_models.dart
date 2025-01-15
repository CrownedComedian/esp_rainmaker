import 'package:esp_rainmaker/src/api_response_models.dart';
import 'package:meta/meta.dart';

import 'node_status.dart';

/// List of node IDs and node data if requested.
@immutable
class NodesList {
  /// List of node IDs.
  final List<String> nodeIds;

  ///List of node details if requested.
  final List<NodeDetails> nodeDetails;

  /// The next node ID.
  final String? nextId;

  /// The total number of nodes.
  final int? totalNodes;

  const NodesList({
    required this.nodeIds,
    required this.nodeDetails,
    required this.nextId,
    required this.totalNodes,
  });

  factory NodesList.fromJson(Map<String, dynamic> json) => NodesList(
    nodeIds: [...(json['nodes'] ?? []).cast<String>()],
    nodeDetails: [
      ...(json['node_details'] ?? [])
          .map<NodeDetails>(
              (nodeDetails) => NodeDetails.fromJson(nodeDetails))
          .toList()
    ],
    nextId: json['next_id'],
    totalNodes: json['total'],
  );

  @override
  String toString() {
    return 'NodesList(Node Ids: $nodeIds, Node Details: $nodeDetails, Next Id: $nextId, Total Nodes: $totalNodes)';
  }
}

/// Detailed information related to a node.
@immutable
class NodeDetails {
  /// The node's ID.
  final String id;

  /// The node's role.
  final String role;

  /// The connectivity status of the node.
  final NodeConnectivity? status;

  /// Configuration data related to the node.
  final NodeConfig? config;

  /// Key-value pairs of the parameters associated with a node.
  final Map<String, dynamic>? params;

  const NodeDetails({
    required this.id,
    required this.role,
    this.status,
    this.config,
    this.params,
  });

  factory NodeDetails.fromJson(Map<String, dynamic> json) => NodeDetails(
    id: json['id'],
    role: json['role'],
    status: json['status'] != null ? NodeConnectivity.fromJson(json['status']['connectivity']) : null,
    config: json['config'] != null ? NodeConfig.fromJson(json['config']) : null,
    params: json['params'],
  );

  @override
  String toString() {
    return 'NodeDetails(Node Id: $id, Connectivity Status: $status, Config: $config, Node Params: $params)';
  }
}

@immutable
class LocalControlData {
  static const String proofOfPossessionKey = 'POP';
  static const String typeKey = 'Type';

  final String proofOfPossession;
  final int type;

  const LocalControlData({
    required this.proofOfPossession,
    required this.type,
  });

  factory LocalControlData.fromJson(Map<String, dynamic> json) {
    return LocalControlData(
      proofOfPossession: json[LocalControlData.proofOfPossessionKey],
      type: json[LocalControlData.typeKey],
    );
  }
}

@immutable
class SystemData {
  static const String rebootKey = 'Reboot';
  static const String factoryResetKey = 'Factory-Reset';
  static const String wifiResetKey = 'Wi-Fi-Reset';

  final bool? reboot;
  final bool? factoryReset;
  final bool? wifiReset;

  const SystemData({
    this.reboot,
    this.factoryReset,
    this.wifiReset,
  });

  factory SystemData.fromJson(Map<String, dynamic> json) => SystemData(
    reboot: json[rebootKey],
    factoryReset: json[factoryResetKey],
    wifiReset: json[wifiResetKey],
  );
}

@immutable
class Schedule {
  final Map<String, dynamic>? action;
  final bool enabled;
  final String id;
  final String name;
  final List<ScheduleTrigger> trigger;

  const Schedule({
    required this.id,
    required this.name,
    required this.enabled,
    required this.trigger,
    this.action,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    List<dynamic> trigs = json['triggers'];

    List<ScheduleTrigger> finalForm = trigs.map<ScheduleTrigger>((json) {
      if(json['d'] != null && json['m'] != null) {
        return DayOfWeekTrigger.fromJson(json);
      } else {
        return DateTrigger.fromJson(json);
      }

    }).toList();

    return Schedule(
      id: json['id'],
      name: json['name'],
      enabled: json['enabled'],
      trigger: finalForm,
      action: json['action']
    );
  }
}

@immutable
class TimeZoneData {
  final String timezone;
  final String posix;

  const TimeZoneData({
    required this.timezone,
    required this.posix,
  });

  factory TimeZoneData.fromJson(Map<String, dynamic> json) {
    return TimeZoneData(
      timezone: json['TZ'],
      posix: json['TZ-POSIX'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}

/// Connectivity information related to a node.
@immutable
class NodeConnectivity {
  /// Connectivity status of a node.
  final bool isConnected;

  /// Last time at which a node was connected.
  final int? timestamp;

  const NodeConnectivity({
    required this.isConnected,
    this.timestamp,
  });

  factory NodeConnectivity.fromJson(Map<String, dynamic> json) {
    return NodeConnectivity(
      isConnected: json['connected'],
      timestamp: json['timestamp'],
    );
  }

  @override
  String toString() {
    return 'NodeConnectivity(Is Connected: $isConnected, Timestamp: $timestamp)';
  }
}

/// Configuration information related to a node.
@immutable
class NodeConfig {
  /// The node's ID.
  final String id;
  final String configVersion;

  /// The version of firmware running on the node.
  final String firmwareVersion;

  /// The name of the node.
  final String name;

  /// The type of the node.
  final String type;

  /// Key-value pairs of the parameters associated with a node.
  final List<Map<String, dynamic>> devices;

  const NodeConfig({
    required this.id,
    required this.configVersion,
    required this.firmwareVersion,
    required this.name,
    required this.type,
    required this.devices,
  });

  factory NodeConfig.fromJson(Map<String, dynamic> json) {
    return NodeConfig(
      id: json['node_id'],
      configVersion: json['config_version'],
      firmwareVersion: json['info']['fw_version'],
      name: json['info']['name'],
      type: json['info']['type'],
      devices: json['devices']?.cast<Map<String, dynamic>>(),
    );
  }

  @override
  String toString() {
    return 'NodeConfig(Id: $id, ConfigVer: $configVersion, FWVer: $firmwareVersion, Name: $name, Type: $type, Devices: $devices)';
  }
}

/// The status of a mapping operation.
@immutable
class MappingStatus {
  /// The ID of the node being mapped.
  final String? nodeId;
  final String? timestamp;

  /// The current status of the mapping request.
  final MappingRequestStatus status;
  final String? confirmTimestamp;
  final String? discardedTimestamp;

  /// The source of the mapping request.
  final MappingRequestSource? source;

  /// The mapping request ID.
  final String? requestId;

  const MappingStatus({
    required this.nodeId,
    required this.timestamp,
    required this.status,
    required this.confirmTimestamp,
    required this.discardedTimestamp,
    required this.source,
    required this.requestId,
  });

  factory MappingStatus.fromJson(Map<String, dynamic> json) {
    MappingRequestStatus enumFromString(
        List<MappingRequestStatus> enumList, String value) {
      return enumList.firstWhere(
        (type) => type.name == value,
      );
    }

    T? enumFromStringNull<T>(List<T> enumList, String? value) {
      if (value == null) return null;
      return enumList.firstWhere(
        (type) => type.toString().split('.').last == value,
      );
    }

    print(json);
    return MappingStatus(
      nodeId: json['user_node_id'],
      timestamp: json['request_timestamp'],
      status:
          enumFromString(MappingRequestStatus.values, json['request_status']),
      confirmTimestamp: json['confirm_timestamp'],
      discardedTimestamp: json['discarded_timestamp'],
      source: enumFromStringNull(
          MappingRequestSource.values, json['request_source']),
      requestId: json['request_id'],
    );
  }
}

/// Details of who a node is shared with.
@immutable
class SharingDetail {
  /// The ID of the node in question.
  final String nodeId;

  /// The primary users associated with the node.
  final List<String> primaryUsers;

  /// The secondary users associated with the node.
  final List<String> secondaryUsers;

  const SharingDetail({
    required this.nodeId,
    required this.primaryUsers,
    required this.secondaryUsers,
  });

  factory SharingDetail.fromJson(Map<String, dynamic> json) {
    return SharingDetail(
      nodeId: json['node_id'],
      primaryUsers: json['users']['primary']?.cast<String>() ?? [],
      secondaryUsers: json['users']['secondary']?.cast<String>() ?? [],
    );
  }

  @override
  String toString() {
    return 'SharingDetail(nodeId: $nodeId, primaryUsers: $primaryUsers, secondaryUsers: $secondaryUsers)';
  }
}

/// Possible statuses for a mapping request.
enum MappingRequestStatus {
  requested,
  confirmed,
  timedout,
  discarded,
}

/// Possible sources for a mapping request.
enum MappingRequestSource { user, node }

@immutable
class APIResponseWithNodeID extends APIResponseModel {
  static const String nodeIDKey = 'node_id';
  final String nodeID;

  APIResponseWithNodeID({
    required this.nodeID,
    required String status,
    required String description,
  }) : super(status: status, description: description);

  factory APIResponseWithNodeID.fromJson(Map<String, dynamic> json) {
    return APIResponseWithNodeID(
      nodeID: json[APIResponseWithNodeID.nodeIDKey],
      status: json[APIResponseModel.statusKey],
      description: json[APIResponseModel.descriptionKey],
    );
  }

  Map<String, dynamic> toJson() => {
    APIResponseWithNodeID.nodeIDKey: nodeID,
    ...super.toJson(),
  };
}
