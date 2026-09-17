import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../models/call_model.dart';
import '../../providers/call_provider.dart';
import '../../widgets/call_button.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/network_quality_indicator.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.callBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header Signal Badge
              NetworkQualityIndicator(quality: activeCall.networkQuality),

              const SizedBox(height: 40),

              // Receiver Name
              Text(
                activeCall.calleeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Status / Duration
              Text(
                statusText,
                style: TextStyle(
                  color: (activeCall.status == CallStatus.connected || activeCall.status == CallStatus.inCall)
                      ? AppColors.accentGreen
                      : Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Animated Profile Picture Circle
              Center(
                child: AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, child) {
                    final double rippleSize = 180 + (_rippleController.value * 35);
                    final double opacity = 1.0 - _rippleController.value;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: rippleSize,
                          height: rippleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: opacity * 0.35),
                          ),
                        ),
                        CustomAvatar(
                          avatarUrl: activeCall.calleeAvatar,
                          name: activeCall.calleeName,
                          radius: 75,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // Audio Controls
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute / Unmute
                    CallButton(
                      icon: callProvider.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: callProvider.isMuted ? 'Muted' : 'Mute',
                      isActive: callProvider.isMuted,
                      onPressed: () => callProvider.toggleMute(),
                    ),

                    // End Call
                    CallButton(
                      icon: Icons.call_end_rounded,
                      label: 'End',
                      backgroundColor: AppColors.endCallRed,
                      iconColor: Colors.white,
                      size: 68,
                      onPressed: () async {
                        await callProvider.endCall();
                        if (context.mounted && Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),

                    // Speaker On / Off
                    CallButton(
                      icon: callProvider.isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                      label: callProvider.isSpeakerOn ? 'Speaker On' : 'Speaker',
                      isActive: callProvider.isSpeakerOn,
                      onPressed: () => callProvider.toggleSpeaker(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
