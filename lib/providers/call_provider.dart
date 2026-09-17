import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call_model.dart';
import '../models/user_model.dart';
import '../services/calling_service.dart';

class CallProvider extends ChangeNotifier {
  final CallingService _callingService = CallingService();

  CallModel? _activeCall;
  CallModel? _incomingCall;
  List<CallModel> _callHistory = [];
  int _callDuration = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  bool _isLoadingHistory = false;

  StreamSubscription? _activeCallSub;
  StreamSubscription? _incomingCallSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _muteSub;
  StreamSubscription? _speakerSub;
  StreamSubscription? _cameraSub;
  StreamSubscription? _frontCameraSub;

  CallModel? get activeCall => _activeCall;
  CallModel? get incomingCall => _incomingCall;
  List<CallModel> get callHistory => _callHistory;
  int get callDuration => _callDuration;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraOn => _isCameraOn;
  bool get isFrontCamera => _isFrontCamera;
  bool get isLoadingHistory => _isLoadingHistory;

  CallProvider() {
    _initSubscriptions();
    loadCallHistory();
  }

  void _initSubscriptions() {
    _activeCallSub = _callingService.activeCallStream.listen((call) {
      _activeCall = call;
      notifyListeners();
    });

    _incomingCallSub = _callingService.incomingCallStream.listen((call) {
      _incomingCall = call;
      notifyListeners();
    });

    _durationSub = _callingService.durationStream.listen((duration) {
      _callDuration = duration;
      notifyListeners();
    });

    _muteSub = _callingService.muteStream.listen((muted) {
      _isMuted = muted;
      notifyListeners();
    });

    _speakerSub = _callingService.speakerStream.listen((speaker) {
      _isSpeakerOn = speaker;
      notifyListeners();
    });

    _cameraSub = _callingService.cameraStream.listen((camera) {
      _isCameraOn = camera;
      notifyListeners();
    });

    _frontCameraSub = _callingService.frontCameraStream.listen((front) {
      _isFrontCamera = front;
      notifyListeners();
    });
  }

  Future<void> loadCallHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    _callHistory = await _callingService.getCallHistory();
    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Start an outgoing audio or video call
  Future<void> startCall({
    required UserModel currentUser,
    required UserModel targetUser,
    required CallType type,
  }) async {
    await _callingService.initiateCall(
      currentUser: currentUser,
      targetUser: targetUser,
      type: type,
    );
  }

  /// Trigger a simulated incoming call for testing purposes
  void simulateIncomingCall({
    required UserModel caller,
    required UserModel currentUser,
    required CallType type,
  }) {
    _callingService.triggerIncomingCall(
      caller: caller,
      currentUser: currentUser,
      type: type,
    );
  }

  /// Accept incoming call
  void acceptIncomingCall() {
    _callingService.acceptIncomingCall();
  }

  /// Decline incoming call
  Future<void> declineIncomingCall() async {
    await _callingService.declineIncomingCall();
    await loadCallHistory();
  }

  /// End current call
  Future<void> endCall() async {
    await _callingService.endCall();
    await loadCallHistory();
  }

  void toggleMute() => _callingService.toggleMute();
  void toggleSpeaker() => _callingService.toggleSpeaker();
  void toggleCamera() => _callingService.toggleCamera();
  void switchCamera() => _callingService.switchCamera();

  @override
  void dispose() {
    _activeCallSub?.cancel();
    _incomingCallSub?.cancel();
    _durationSub?.cancel();
    _muteSub?.cancel();
    _speakerSub?.cancel();
    _cameraSub?.cancel();
    _frontCameraSub?.cancel();
    _callingService.dispose();
    super.dispose();
  }
}
