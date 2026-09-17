enum CallType { audio, video }
enum CallStatus { calling, ringing, connected, inCall, ended, rejected, missed, busy }
enum CallDirection { incoming, outgoing }
enum NetworkQuality { good, fair, poor }

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String calleeId;
  final String calleeName;
  final String calleeAvatar;
  final CallType type;
  final CallDirection direction;
  final CallStatus status;
  final DateTime timestamp;
  final int durationSeconds;
  final NetworkQuality networkQuality;

  const CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerAvatar,
    required this.calleeId,
    required this.calleeName,
    required this.calleeAvatar,
    required this.type,
    required this.direction,
    required this.status,
    required this.timestamp,
    this.durationSeconds = 0,
    this.networkQuality = NetworkQuality.good,
  });

  CallModel copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? callerAvatar,
    String? calleeId,
    String? calleeName,
    String? calleeAvatar,
    CallType? type,
    CallDirection? direction,
    CallStatus? status,
    DateTime? timestamp,
    int? durationSeconds,
    NetworkQuality? networkQuality,
  }) {
    return CallModel(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      calleeId: calleeId ?? this.calleeId,
      calleeName: calleeName ?? this.calleeName,
      calleeAvatar: calleeAvatar ?? this.calleeAvatar,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      networkQuality: networkQuality ?? this.networkQuality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'calleeId': calleeId,
      'calleeName': calleeName,
      'calleeAvatar': calleeAvatar,
      'type': type.name,
      'direction': direction.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
      'networkQuality': networkQuality.name,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String,
      callerAvatar: json['callerAvatar'] as String,
      calleeId: json['calleeId'] as String,
      calleeName: json['calleeName'] as String,
      calleeAvatar: json['calleeAvatar'] as String,
      type: CallType.values.byName(json['type'] as String),
      direction: CallDirection.values.byName(json['direction'] as String),
      status: CallStatus.values.byName(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      networkQuality: NetworkQuality.values.byName((json['networkQuality'] as String?) ?? 'good'),
    );
  }
}
