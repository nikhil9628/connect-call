import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/call_model.dart';
import '../providers/call_provider.dart';
import '../screens/call/incoming_call_screen.dart';
import 'custom_avatar.dart';

class IncomingCallBanner extends StatelessWidget {
  final CallModel call;

  const IncomingCallBanner({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final isVideo = (call.type == CallType.video);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            children: [
              CustomAvatar(
                avatarUrl: call.callerAvatar,
                name: call.callerName,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Incoming ${isVideo ? "Video" : "Audio"} Call...',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  callProvider.declineIncomingCall();
                },
                icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.endCallRed,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  callProvider.acceptIncomingCall();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IncomingCallScreen(call: call),
                    ),
                  );
                },
                icon: Icon(isVideo ? Icons.videocam_rounded : Icons.phone_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.acceptCallGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
