import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/call_model.dart';
import '../../providers/call_provider.dart';
import '../../widgets/custom_avatar.dart';
import 'audio_call_screen.dart';
import 'video_call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final CallModel call;

  const IncomingCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);
    final isVideo = (call.type == CallType.video);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.callBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Title Header
              Text(
                'Incoming ${isVideo ? "Video" : "Audio"} Call',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Caller Name
              Text(
                call.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // Caller Profile Picture
              CustomAvatar(
                avatarUrl: call.callerAvatar,
                name: call.callerName,
                radius: 80,
              ),

              const Spacer(),

              // Accept / Decline Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline Call (Red)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.large(
                          heroTag: 'decline_btn',
                          backgroundColor: AppColors.endCallRed,
                          onPressed: () async {
                            await callProvider.declineIncomingCall();
                            if (context.mounted && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Decline',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // Accept Call (Green)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.large(
                          heroTag: 'accept_btn',
                          backgroundColor: AppColors.acceptCallGreen,
                          onPressed: () {
                            callProvider.acceptIncomingCall();
                            Widget screen = isVideo ? const VideoCallScreen() : const AudioCallScreen();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => screen),
                            );
                          },
                          child: Icon(
                            isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
