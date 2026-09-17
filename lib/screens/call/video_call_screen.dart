import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../models/call_model.dart';
import '../../providers/call_provider.dart';
import '../../widgets/call_button.dart';
import '../../widgets/network_quality_indicator.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Offset _pipPosition = const Offset(20, 80);

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);
    final activeCall = callProvider.activeCall;

    if (activeCall == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: Colors.black, body: SizedBox());
    }

    final String statusText;
    switch (activeCall.status) {
      case CallStatus.calling:
        statusText = 'Calling...';
        break;
      case CallStatus.ringing:
        statusText = 'Ringing...';
        break;
      case CallStatus.connected:
      case CallStatus.inCall:
        statusText = DurationFormatter.formatSeconds(callProvider.callDuration);
        break;
      default:
        statusText = 'Call Ended';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video Stream Simulation Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(activeCall.calleeAvatar),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.1), BlendMode.darken),
                child: const SizedBox(),
              ),
            ),
          ),

          // Floating Picture-in-Picture Local Camera Preview Window (Draggable)
          if (callProvider.isCameraOn)
            Positioned(
              left: _pipPosition.dx,
              top: _pipPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _pipPosition += details.delta;
                  });
                },
                child: Container(
                  width: 110,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(Icons.person, color: Colors.white54, size: 40),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              callProvider.isFrontCamera ? 'Front' : 'Rear',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Header Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeCall.calleeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statusText,
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                            ),
                          ),
                        ],
                      ),
                      NetworkQualityIndicator(quality: activeCall.networkQuality),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls Bar
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute / Unmute Mic
                  CallButton(
                    icon: callProvider.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: callProvider.isMuted ? 'Muted' : 'Mic',
                    isActive: callProvider.isMuted,
                    onPressed: () => callProvider.toggleMute(),
                  ),

                  // Camera On / Off
                  CallButton(
                    icon: callProvider.isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    label: callProvider.isCameraOn ? 'Camera' : 'Cam Off',
                    isActive: !callProvider.isCameraOn,
                    onPressed: () => callProvider.toggleCamera(),
                  ),

                  // Switch Front/Rear Camera
                  CallButton(
                    icon: Icons.flip_camera_ios_rounded,
                    label: 'Switch',
                    onPressed: () => callProvider.switchCamera(),
                  ),

                  // End Call
                  CallButton(
                    icon: Icons.call_end_rounded,
                    label: 'End',
                    backgroundColor: AppColors.endCallRed,
                    iconColor: Colors.white,
                    size: 64,
                    onPressed: () async {
                      await callProvider.endCall();
                      if (context.mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
