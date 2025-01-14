import 'package:esp_rainmaker/esp_rainmaker.dart';
import 'package:http/http.dart';
import 'package:isolate_json/isolate_json.dart';
import 'package:meta/meta.dart';

/// Provides access to methods for obtaining and updating node state.
class NodeState {
  final String accessToken;
  final URLBase _urlBase;

  static const String _nodeState = 'user/nodes/params';

  /// Constructs object to access node state methods.
  ///
  /// Uses the default API version of v1, though an
  /// alternative version can be specified.
  NodeState(this.accessToken, [APIVersion version = APIVersion.v1])
      : _urlBase = URLBase(version);

  /// Updates the state of a node with the given [params].
  ///
  /// Example map input:
  /// ```dart
  ///{
  ///  'Light': {
  ///    'brightness': 0,
  ///    'output': true,
  ///  },
  ///  'Switch': {
  ///    'output': true,
  ///  }
  ///}
  ///```
  Future<List<APIResponseWithNodeID>> updateState(List<SetNodeParamsRequestBody> nodeParamsRequests) async {
    final uri = _urlBase.getPath(_nodeState);

    final body = await JsonIsolate().encodeJson(nodeParamsRequests);

    final resp = await put(
      uri,
      body: body,
      headers: {
        URLBase.authHeader: accessToken,
      },
    );

    if(resp.statusCode != 207) {
      final Map<String, dynamic> bodyResp = await JsonIsolate().decodeJson(resp.body);

      throw bodyResp['description'];
    } else {
      final List<dynamic> bodyResp = await JsonIsolate().decodeJson(resp.body);

      return List.from(bodyResp).map<APIResponseWithNodeID>(
        (d) => APIResponseWithNodeID.fromJson(d),
      ).toList();
    }
  }

  /// Obtains the state of the node with id [nodeId].
  ///
  /// Example map output:
  /// ```dart
  ///{
  ///  'Light': {
  ///    'brightness': 0,
  ///    'output': true,
  ///  },
  ///  'Switch': {
  ///    'output': true,
  ///  }
  ///}
  ///```
  Future<Map<String, dynamic>> getState(String nodeId) async {
    final uri = _urlBase.getPath(_nodeState, {
      'node_id': nodeId,
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

    return bodyResp;
  }

  /// Helper function for adding a default Rainmaker schedule.
  ///
  /// Takes an [action] parameter that triggers at the
  /// given time. The action parameter is identical to
  /// the parameters used by the other state functions.
  ///
  /// E.g.
  /// ```dart
  ///{
  ///  'Light': {
  ///    'brightness': 0,
  ///    'output': true,
  ///  },
  ///  'Switch': {
  ///    'output': true,
  ///  }
  ///}
  ///```
  Future<List<APIResponseWithNodeID>> createSchedule({
    required List<String> nodeIDs,
    required String name,
    required String scheduleID,
    required List<ScheduleTrigger> triggers,
    required Map<String, dynamic> action,
  }) async {
    final parsedTriggers = <Map<String, dynamic>>[];
    for (final trigger in triggers) {
      if (trigger is DayOfWeekTrigger) {
        parsedTriggers.add({
          'd': _getBitList<DaysOfWeek>(trigger.daysOfWeek),
          'm': trigger.minutesSinceMidnight,
        });
      } else if (trigger is DateTrigger) {
        parsedTriggers.add({
          'dd': trigger.day,
          'mm': _getBitList<MonthsOfYear>(trigger.months),
          'yy': trigger.year,
          'r': trigger.repeatEveryYear,
          'm': trigger.minutesSinceMidnight,
        });
      }
    }

    return await updateState(
      List.generate(
        nodeIDs.length,
        (index) => SetNodeParamsRequestBody(
          nodeID: nodeIDs[index],
          payload: {
            'Schedule': {
              'Schedules': [
                {
                  'name': name,
                  'id': scheduleID,
                  'operation': 'add',
                  'triggers': parsedTriggers,
                  'action': action,
                }
              ],
            }
          },
        ),
      ),
    );
  }

  /// Helper function for editing a default Rainmaker schedule.
  ///
  /// Takes an [action] parameter that triggers at the
  /// given time. The action parameter is identical to
  /// the parameters used by the other state functions.
  ///
  /// E.g.
  /// ```dart
  ///{
  ///  'Light': {
  ///    'brightness': 0,
  ///    'output': true,
  ///  },
  ///  'Switch': {
  ///    'output': true,
  ///  }
  ///}
  ///```
  ///
  /// When updating the [action] and [triggers] parameters,
  /// *all*, the objects should be complete. They cannot be partial.
  /// E.g. you should pass `"action":{"Light": {"power": true, "brightness":100}}`
  /// and not just `"action":{"Light": {"brightness":100}}`.
  Future<List<APIResponseWithNodeID>> editSchedule({
    required List<String> nodeIDs,
    required String scheduleID,
    String? name,
    List<ScheduleTrigger>? triggers,
    Map<String, dynamic>? action,
  }) async {
    final parsedTriggers = <Map<String, dynamic>>[];

    if (triggers != null) {
      for (final trigger in triggers) {
        if (trigger is DayOfWeekTrigger) {
          parsedTriggers.add({
            'd': _getBitList<DaysOfWeek>(trigger.daysOfWeek),
            'm': trigger.minutesSinceMidnight,
          });
        } else if (trigger is DateTrigger) {
          parsedTriggers.add({
            'dd': trigger.day,
            'mm': _getBitList<MonthsOfYear>(trigger.months),
            'yy': trigger.year,
            'r': trigger.repeatEveryYear,
            'm': trigger.minutesSinceMidnight,
          });
        }
      }
    }

    return await updateState(
      List.generate(
        nodeIDs.length,
        (index) => SetNodeParamsRequestBody(
          nodeID: nodeIDs[index],
          payload: {
            'Schedule': {
              'Schedules': [
                {
                  'name': name,
                  'id': scheduleID,
                  'operation': 'edit',
                  'triggers': parsedTriggers,
                  'action': action,
                }
              ],
            }
          },
        ),
      ),
    );
  }

  /// Helper function for removing a default Rainmaker schedule.
  Future<List<APIResponseWithNodeID>> deleteSchedule({
    required List<String> nodeIDs,
    required scheduleID,
  }) async {
    return await updateState(
      List.generate(
        nodeIDs.length,
        (index) => SetNodeParamsRequestBody(
          nodeID: nodeIDs[index],
          payload: {
            'Schedule': {
              'Schedules': [
                {
                  'id': scheduleID,
                  'operation': 'remove',
                }
              ],
            }
          },
        ),
      ),
    );
  }

  /// Helper function for change the enable
  /// status of a default Rainmaker schedule.
  Future<List<APIResponseWithNodeID>> changeEnableSchedule({
    required List<String> nodeIDs,
    required String scheduleID,
    required ScheduleEnableOperation operation,
  }) async {
    return await updateState(
      List.generate(
        nodeIDs.length,
          (index) => SetNodeParamsRequestBody(
          nodeID: nodeIDs[index],
          payload: {
            'Schedule': {
              'Schedules': [
                {
                  'id': scheduleID,
                  'operation': operation.toShortString(),
                }
              ],
            }
          },
        ),
      ),
    );
  }

  /// Helper function to get the number of minutes from midnight.
  ///
  /// Useful for passing a schedule to the scheduling functions.
  /// Returns the number of minutes from midnight of the
  /// day of the DateTime object.
  static int getMinutesFromMidnight(DateTime time) {
    final dayStart = DateTime(time.year, time.month, time.day);
    final dur = time.difference(dayStart);
    return dur.inMinutes;
  }

  int _getBitList<T>(List<T> list) {
    final bitList = <int>[];

    if (T == DaysOfWeek) {
      for (final dayOfWeek in list) {
        final index = DaysOfWeek.values.indexOf(dayOfWeek as DaysOfWeek);
        bitList.add(1 << index);
      }
    } else if (T == MonthsOfYear) {
      for (final month in list) {
        final index = MonthsOfYear.values.indexOf(month as MonthsOfYear);
        bitList.add(1 << index);
      }
    } else {
      throw StateError(
          'There was a problem parsing the days of the week or months');
    }

    return bitList.reduce((val1, val2) {
      return val1 | val2;
    });
  }
}

@immutable
class SetNodeParamsRequestBody {
  static const String nodeIDKey = 'node_id';
  static const String payloadKey = 'payload';

  final String nodeID;
  final Map<String, dynamic> payload;

  const SetNodeParamsRequestBody({
    required this.nodeID,
    required this.payload,
  });

  factory SetNodeParamsRequestBody.fromJson(Map<String, dynamic> json) {
    return SetNodeParamsRequestBody(
      nodeID: json[SetNodeParamsRequestBody.nodeIDKey],
      payload: json[SetNodeParamsRequestBody.payloadKey],
    );
  }

  Map<String, dynamic> toJson() => {
    SetNodeParamsRequestBody.nodeIDKey: nodeID,
    SetNodeParamsRequestBody.payloadKey: payload,
  };
}

/// Details the times at which a schedule event should trigger.
@immutable
abstract class ScheduleTrigger {
  /// The time in minutes since midnight that an action is triggered.
  final int minutesSinceMidnight;

  const ScheduleTrigger(this.minutesSinceMidnight);
}

@immutable
class DayOfWeekTrigger extends ScheduleTrigger {
  /// Days of week that the action should trigger.
  final List<DaysOfWeek> daysOfWeek;

  const DayOfWeekTrigger(this.daysOfWeek, int minutesSinceMidnight)
      : super(minutesSinceMidnight);

  factory DayOfWeekTrigger.fromJson(Map<String, dynamic> json) {
    return DayOfWeekTrigger(
      _parseBit(json['d']),
      json['m']
    );
  }

  static List<DaysOfWeek> _parseBit(int bit) {
    List<DaysOfWeek> result = [];

    for(int i = 0; i < DaysOfWeek.values.length; i++) {
      if((bit & (1 << i)) != 0) {
        result.add(DaysOfWeek.values[i]);
      }
    }

    return result;
  }
}

@immutable
class DateTrigger extends ScheduleTrigger {
  /// Months that the action should trigger at.
  final List<MonthsOfYear> months;

  /// Day of month that action should trigger.
  final int day;

  /// Year that the action should trigger.
  final int year;

  /// If the schedule should repeat every year.
  final bool repeatEveryYear;

  const DateTrigger(this.months, this.day, this.year, this.repeatEveryYear,
      int minutesSinceMidnight)
      : super(minutesSinceMidnight);

  factory DateTrigger.fromJson(Map<String, dynamic> json) {
    return DateTrigger(
      _parseBit(json['mm']),
      json['dd'],
      json['yy'],
      json['r'] == 1 ? true : false,
      json['m'],
    );
  }

  static List<MonthsOfYear> _parseBit(int bit) {
    List<MonthsOfYear> result = [];

    for(int i = 0; i < MonthsOfYear.values.length; i++) {
      if((bit & (1 << i)) != 0) {
        result.add(MonthsOfYear.values[i]);
      }
    }

    return result;
  }
}

enum DaysOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

enum MonthsOfYear {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december,
}

enum ScheduleEnableOperation {
  disable,
  enable,
}

extension ParseEnableOperationToString on ScheduleEnableOperation {
  String toShortString() {
    return toString().split('.').last;
  }
}
