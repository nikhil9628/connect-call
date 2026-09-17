import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/call_history_tile.dart';
import '../../widgets/custom_avatar.dart';
import '../call/audio_call_screen.dart';
import '../call/video_call_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<UserProvider>(context, listen: false)
            .fetchContacts(currentUserId: authProvider.currentUser!.id);
      }
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

  void _triggerSimulatedIncomingCall() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null || userProvider.contacts.isEmpty) return;

    final caller = userProvider.contacts.first; // e.g. John Smith or Alex Wilson

    callProvider.simulateIncomingCall(
      caller: caller,
      currentUser: currentUser,
      type: CallType.video,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📞 Simulated Incoming Video Call from ${caller.name}!'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final callProvider = Provider.of<CallProvider>(context);

    final currentUser = authProvider.currentUser;
    final contacts = userProvider.contacts;
    final history = callProvider.callHistory.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectCall'),
        actions: [
          IconButton(
            tooltip: 'Simulate Incoming Call',
            icon: const Icon(Icons.ring_volume_rounded, color: AppColors.accentGreen),
            onPressed: _triggerSimulatedIncomingCall,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            if (currentUser != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CustomAvatar(
                      avatarUrl: currentUser.avatarUrl,
                      name: currentUser.name,
                      radius: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUser.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: currentUser.isOnline ? AppColors.onlineGreen : AppColors.offlineGrey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: currentUser.isOnline,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.onlineGreen,
                          onChanged: (_) => authProvider.toggleOnlineStatus(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Quick Call Simulation Tester Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Test Incoming Call Flow',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _triggerSimulatedIncomingCall,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Test Call', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Active Contacts Horizontal Ribbon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Contacts',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${contacts.where((c) => c.isOnline).length} Online',
                    style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Container(
                          width: 85,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _startCall(contact, CallType.video),
                                child: Stack(
                                  children: [
                                    CustomAvatar(
                                      avatarUrl: contact.avatarUrl,
                                      name: contact.name,
                                      radius: 28,
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 13,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          color: contact.isOnline ? AppColors.onlineGreen : AppColors.offlineGrey,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                contact.name.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () => _startCall(contact, CallType.audio),
                                    child: const Icon(Icons.phone, size: 14, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _startCall(contact, CallType.video),
                                    child: const Icon(Icons.videocam, size: 14, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // Recent Calls Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Calls',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No call history yet. Start your first call above!'),
                ),
              )
            else
              ...history.map((call) {
                return CallHistoryTile(
                  call: call,
                  currentUserId: currentUser?.id ?? '',
                  onCallBack: () {
                    final targetId = (call.callerId == currentUser?.id) ? call.calleeId : call.callerId;
                    final targetContact = contacts.firstWhere(
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
              }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
