import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/call_history_tile.dart';
import '../call/audio_call_screen.dart';
import '../call/video_call_screen.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = Missed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CallProvider>(context, listen: false).loadCallHistory();
    });
  }

  void _startCall(UserModel targetUser, CallType type) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.startCall(
      currentUser: currentUser,
      targetUser: targetUser,
      type: type,
    );

    Widget screen = (type == CallType.video)
        ? const VideoCallScreen()
        : const AudioCallScreen();

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final callProvider = Provider.of<CallProvider>(context);
    final currentUser = authProvider.currentUser;

    List<CallModel> history = callProvider.callHistory;
    if (_selectedFilterIndex == 1) {
      history = history.where((c) => c.status == CallStatus.missed || c.status == CallStatus.rejected).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
      ),
      body: Column(
        children: [
          // Filter Choice Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Calls'),
                  selected: _selectedFilterIndex == 0,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilterIndex = 0);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Missed Calls'),
                  selected: _selectedFilterIndex == 1,
                  selectedColor: AppColors.missedRed.withValues(alpha: 0.2),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilterIndex = 1);
                  },
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: callProvider.isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.history_rounded, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No call records found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final call = history[index];
                          return CallHistoryTile(
                            call: call,
                            currentUserId: currentUser?.id ?? '',
                            onCallBack: () {
                              final targetId = (call.callerId == currentUser?.id)
                                  ? call.calleeId
                                  : call.callerId;

                              final targetContact = userProvider.contacts.firstWhere(
                                (c) => c.id == targetId,
                                orElse: () => UserModel(
                                  id: targetId,
                                  name: call.callerName,
                                  email: '',
                                  avatarUrl: call.callerAvatar,
                                ),
                              );

                              _startCall(targetContact, call.type);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
