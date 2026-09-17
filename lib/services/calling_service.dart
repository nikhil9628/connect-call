import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/call_model.dart';
import '../models/user_model.dart';

class CallingService {
  static const String _callHistoryKey = 'connect_call_history_v1';

  CallModel? _activeCall;
  CallModel? _incomingCall;

  Timer? _callDurationTimer;
  Timer? _stateTransitionTimer;
  Timer? _networkQualityTimer;

  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  int _currentDuration = 0;

  // Stream controllers for state updates
  final StreamController<CallModel?> _activeCallController = StreamController<CallModel?>.broadcast();
  final StreamController<CallModel?> _incomingCallController = StreamController<CallModel?>.broadcast();
  final StreamController<int> _durationController = StreamController<int>.broadcast();
  final StreamController<bool> _muteController = StreamController<bool>.broadcast();
  final StreamController<bool> _speakerController = StreamController<bool>.broadcast();
  final StreamController<bool> _cameraController = StreamController<bool>.broadcast();
  final StreamController<bool> _frontCameraController = StreamController<bool>.broadcast();

  // Getters
  CallModel? get activeCall => _activeCall;
  CallModel? get incomingCall => _incomingCall;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraOn => _isCameraOn;
  bool get isFrontCamera => _isFrontCamera;
  int get currentDuration => _currentDuration;

  Stream<CallModel?> get activeCallStream => _activeCallController.stream;
  Stream<CallModel?> get incomingCallStream => _incomingCallController.stream;
  Stream<int> get durationStream => _durationController.stream;
  Stream<bool> get muteStream => _muteController.stream;
  Stream<bool> get speakerStream => _speakerController.stream;
  Stream<bool> get cameraStream => _cameraController.stream;
  Stream<bool> get frontCameraStream => _frontCameraController.stream;

  /// Start an outgoing 1-to-1 audio or video call
  Future<CallModel> initiateCall({
    required UserModel currentUser,
    required UserModel targetUser,
    required CallType type,
  }) async {
    // Reset controls
    _isMuted = false;
    _isSpeakerOn = (type == CallType.video); // default speaker for video
    _isCameraOn = true;
    _isFrontCamera = true;
    _currentDuration = 0;

    _muteController.add(_isMuted);
    _speakerController.add(_isSpeakerOn);
    _cameraController.add(_isCameraOn);
    _frontCameraController.add(_isFrontCamera);
    _durationController.add(_currentDuration);

    final call = CallModel(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      callerId: currentUser.id,
      callerName: currentUser.name,
      callerAvatar: currentUser.avatarUrl,
      calleeId: targetUser.id,
      calleeName: targetUser.name,
      calleeAvatar: targetUser.avatarUrl,
      type: type,
      direction: CallDirection.outgoing,
      status: CallStatus.calling,
      timestamp: DateTime.now(),
      networkQuality: NetworkQuality.good,
    );

    _activeCall = call;
    _activeCallController.add(_activeCall);

    // Simulate Signaling State transitions: Calling -> Ringing -> Connected
    _stateTransitionTimer?.cancel();
    _stateTransitionTimer = Timer(const Duration(seconds: 2), () {
      if (_activeCall != null && _activeCall!.status == CallStatus.calling) {
        _updateCallStatus(CallStatus.ringing);

        _stateTransitionTimer = Timer(const Duration(seconds: 3), () {
          if (_activeCall != null && _activeCall!.status == CallStatus.ringing) {
            _updateCallStatus(CallStatus.connected);
            _startCallTimer();
            _startNetworkQualitySimulation();
          }
        });
      }
    });

    return _activeCall!;
  }

  /// Simulate receiving an incoming call from a contact
  void triggerIncomingCall({
    required UserModel caller,
    required UserModel currentUser,
    required CallType type,
  }) {
    if (_activeCall != null || _incomingCall != null) return; // Busy state

    final call = CallModel(
      id: 'incoming_${DateTime.now().millisecondsSinceEpoch}',
      callerId: caller.id,
      callerName: caller.name,
      callerAvatar: caller.avatarUrl,
      calleeId: currentUser.id,
      calleeName: currentUser.name,
      calleeAvatar: currentUser.avatarUrl,
      type: type,
      direction: CallDirection.incoming,
      status: CallStatus.ringing,
      timestamp: DateTime.now(),
      networkQuality: NetworkQuality.good,
    );

    _incomingCall = call;
    _incomingCallController.add(_incomingCall);
  }

  /// Accept an incoming call
  void acceptIncomingCall() {
    if (_incomingCall == null) return;

    final acceptedCall = _incomingCall!.copyWith(
      status: CallStatus.connected,
      timestamp: DateTime.now(),
    );

    _incomingCall = null;
    _incomingCallController.add(null);

    _activeCall = acceptedCall;
    _isMuted = false;
    _isSpeakerOn = (acceptedCall.type == CallType.video);
    _isCameraOn = true;
    _isFrontCamera = true;
    _currentDuration = 0;

    _muteController.add(_isMuted);
    _speakerController.add(_isSpeakerOn);
    _cameraController.add(_isCameraOn);
    _frontCameraController.add(_isFrontCamera);

    _activeCallController.add(_activeCall);
    _startCallTimer();
    _startNetworkQualitySimulation();
  }

  /// Decline / Reject an incoming call
  Future<void> declineIncomingCall() async {
    if (_incomingCall == null) return;

    final rejectedCall = _incomingCall!.copyWith(
      status: CallStatus.rejected,
      durationSeconds: 0,
    );

    await saveCallToHistory(rejectedCall);

    _incomingCall = null;
    _incomingCallController.add(null);
  }

  /// End active call
  Future<void> endCall({CallStatus finalStatus = CallStatus.ended}) async {
    _callDurationTimer?.cancel();
    _stateTransitionTimer?.cancel();
    _networkQualityTimer?.cancel();

    if (_activeCall != null) {
      final endedCall = _activeCall!.copyWith(
        status: finalStatus,
        durationSeconds: _currentDuration,
      );

      await saveCallToHistory(endedCall);

      _activeCall = null;
      _activeCallController.add(null);
    }
  }

  /// Toggle audio microphone mute
  void toggleMute() {
    _isMuted = !_isMuted;
    _muteController.add(_isMuted);
  }

  /// Toggle speaker output
  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    _speakerController.add(_isSpeakerOn);
  }

  /// Toggle camera state (video call)
  void toggleCamera() {
    _isCameraOn = !_isCameraOn;
    _cameraController.add(_isCameraOn);
  }

  /// Switch front / rear camera
  void switchCamera() {
    _isFrontCamera = !_isFrontCamera;
    _frontCameraController.add(_isFrontCamera);
  }

  void _updateCallStatus(CallStatus newStatus) {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(status: newStatus);
      _activeCallController.add(_activeCall);
    }
  }

  void _startCallTimer() {
    _callDurationTimer?.cancel();
    _currentDuration = 0;
    _durationController.add(_currentDuration);

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration++;
      _durationController.add(_currentDuration);

      if (_activeCall != null) {
        _activeCall = _activeCall!.copyWith(
          durationSeconds: _currentDuration,
          status: CallStatus.inCall,
        );
        _activeCallController.add(_activeCall);
      }
    });
  }

  void _startNetworkQualitySimulation() {
    _networkQualityTimer?.cancel();
    final qualities = [
      NetworkQuality.good,
      NetworkQuality.good,
      NetworkQuality.fair,
      NetworkQuality.good,
      NetworkQuality.poor,
      NetworkQuality.good,
    ];
    int index = 0;

    _networkQualityTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_activeCall != null) {
        index = (index + 1) % qualities.length;
        _activeCall = _activeCall!.copyWith(networkQuality: qualities[index]);
        _activeCallController.add(_activeCall);
      }
    });
  }

  /// Save finished call to local persistent history
  Future<void> saveCallToHistory(CallModel call) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getCallHistory();
    history.insert(0, call); // Add to top

    final jsonList = history.map((c) => c.toJson()).toList();
    await prefs.setString(_callHistoryKey, jsonEncode(jsonList));
  }

  /// Fetch past call history records
  Future<List<CallModel>> getCallHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJsonStr = prefs.getString(_callHistoryKey);
    if (historyJsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(historyJsonStr);
        return list.map((item) => CallModel.fromJson(item as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    // Default sample history if empty
    final now = DateTime.now();
    return [
      CallModel(
        id: 'hist_1',
        callerId: 'user_001',
        callerName: 'Ananya Verma',
        callerAvatar: 'preset_1',
        calleeId: 'user_003',
        calleeName: 'Rohan Gupta',
        calleeAvatar: 'preset_3',
        type: CallType.video,
        direction: CallDirection.outgoing,
        status: CallStatus.ended,
        timestamp: now.subtract(const Duration(hours: 2)),
        durationSeconds: 155, // 02:35
        networkQuality: NetworkQuality.good,
      ),
      CallModel(
        id: 'hist_2',
        callerId: 'user_002',
        callerName: 'Aarav Sharma',
        callerAvatar: 'preset_2',
        calleeId: 'user_001',
        calleeName: 'Ananya Verma',
        calleeAvatar: 'preset_1',
        type: CallType.audio,
        direction: CallDirection.incoming,
        status: CallStatus.missed,
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        durationSeconds: 0,
        networkQuality: NetworkQuality.fair,
      ),
      CallModel(
        id: 'hist_3',
        callerId: 'user_001',
        callerName: 'Ananya Verma',
        callerAvatar: 'preset_1',
        calleeId: 'user_004',
        calleeName: 'Priya Patel',
        calleeAvatar: 'preset_4',
        type: CallType.audio,
        direction: CallDirection.outgoing,
        status: CallStatus.ended,
        timestamp: now.subtract(const Duration(days: 2)),
        durationSeconds: 412,
        networkQuality: NetworkQuality.good,
      ),
    ];
  }

  void dispose() {
    _callDurationTimer?.cancel();
    _stateTransitionTimer?.cancel();
    _networkQualityTimer?.cancel();
    _activeCallController.close();
    _incomingCallController.close();
    _durationController.close();
    _muteController.close();
    _speakerController.close();
    _cameraController.close();
    _frontCameraController.close();
  }
}
