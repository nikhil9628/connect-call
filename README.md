# ConnectCall - 1-to-1 Audio & Video Calling App in Flutter

> **Flutter Development Intern Assignment Submission**  
> **Tagline:** Connect with anyone, anywhere.

ConnectCall is a feature-complete 1-to-1 real-time audio and video calling application built with **Flutter**, **Dart**, and **Provider** state management. The app demonstrates clean modular architecture, persistent authentication, live contact search, active call state signaling, call controls (mute, speaker, video toggle, camera flip), call history logging, and dark mode support.

---

## 🌟 Features Overview

### 1. 📱 Authentication & User Profile
- **Splash Screen:** Animated app logo, tagline, and automatic authentication check.
- **Login & Registration:** Persistent email/phone authentication using `SharedPreferences`. Includes single-tap **Evaluator Quick Demo Presets** for easy reviewer testing.
- **User Profile:** Displays user avatar, name, email, phone, status bio, dark mode toggle, and blocked user management.

### 2. 👥 Contacts & Search
- **Live Search:** Instant filter by contact name, email, or phone number.
- **Online/Offline Indicators:** Visual real-time green/grey status badges.
- **Contact Action Tiles:** One-tap direct launch for Audio and Video calls.
- **User Detail Modal:** Interactive bottom sheet with full profile info and call triggers.

### 3. 📞 Audio Calling (`1-to-1`)
- **Caller UI:** Displays caller photo with dynamic pulse ripple animation, caller name, connection status (`Calling...` ➔ `Ringing...` ➔ `Connected` ➔ `In Call`).
- **Call Timer:** Real-time duration timer updating every second (`02:35`).
- **Controls:**
  - **Mute / Unmute Microphone**
  - **Speaker On / Off**
  - **End Call** (logs completed call to persistent history)

### 4. 📹 Video Calling (`1-to-1`)
- **Remote Video Display:** Simulated high-definition remote video stream layout.
- **Picture-in-Picture (PiP) Local Preview:** Draggable floating local camera window showing active camera mode (Front/Rear).
- **Network Quality Badge:** Dynamic connection indicator (**HD • Good**, **Fair**, **Poor**).
- **Controls:**
  - **Mute / Unmute Mic**
  - **Camera On / Off** (disables local preview)
  - **Switch Front / Rear Camera**
  - **End Call**

### 5. 🔔 Incoming Call Management
- **Global Banner Alert:** Top floating overlay banner that triggers anywhere inside the app when another user calls.
- **Full Screen Incoming Call UI:** Displays caller photo, caller name, call type badge (Audio/Video), **Decline** (red), and **Accept** (green) buttons.
- **Incoming Call Simulator:** Built-in "Test Call" button on Home dashboard allowing reviewers to test incoming call popups instantly.

### 6. 📜 Call History & Log Records
- **Detailed History Items:** Stores past calls with partner details, timestamp ("Today, 11:45 AM", "Yesterday, 6:20 PM"), direction arrow (Incoming / Outgoing / Missed), duration badge, and audio/video icon.
- **Filter Tabs:** Toggle between **All Calls** and **Missed Calls**.
- **One-Tap Callback:** Redial button to immediately re-initiate audio/video call.

---

## 🛠️ Environment & Packages Used

- **Flutter SDK:** `3.38.2` (Channel stable)
- **Dart SDK:** `3.10.0`
- **State Management:** `Provider 6.1.5` (ChangeNotifier)
- **Persistent Storage:** `shared_preferences 2.5.5`
- **Typography & Theme:** `google_fonts 6.3.3` (Inter & Outfit)
- **Formatting:** `intl 0.19.0`
- **Icons:** `cupertino_icons 1.0.8`

---

## 📐 Project Architecture

The codebase strictly follows the feature-layered architecture recommended in the assignment guidelines:

```
connect_call/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # Color design tokens & light/dark palettes
│   │   │   └── app_strings.dart        # Static strings & UI text
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Light and Dark ThemeData definitions
│   │   └── utils/
│   │       ├── duration_formatter.dart # Seconds to MM:SS / HH:MM:SS formatter
│   │       └── date_formatter.dart     # Timestamp to human-readable string
│   ├── models/
│   │   ├── user_model.dart             # User profile data model
│   │   └── call_model.dart             # Active call & history log data model
│   ├── services/
│   │   ├── auth_service.dart           # Auth & persistent session service
│   │   ├── user_service.dart           # Contacts, search & block service
│   │   └── calling_service.dart        # Active call state machine & signaling engine
│   ├── providers/
│   │   ├── auth_provider.dart          # Authentication state management
│   │   ├── theme_provider.dart         # Theme mode (Light/Dark) state management
│   │   ├── user_provider.dart          # Contacts search state management
│   │   └── call_provider.dart          # Active call & history state management
│   ├── screens/
│   │   ├── splash/splash_screen.dart   # Animated splash screen
│   │   ├── auth/
│   │   │   ├── login_screen.dart       # Login screen with demo quick presets
│   │   │   └── register_screen.dart    # Registration screen
│   │   ├── home/
│   │   │   ├── main_navigation_screen.dart # 4-tab bottom navigation & call listener
│   │   │   └── home_tab.dart           # Home overview & quick call ribbon
│   │   ├── contacts/contacts_screen.dart# Contacts search & list
│   │   ├── profile/profile_screen.dart # User profile & dark mode toggle
│   │   ├── call/
│   │   │   ├── audio_call_screen.dart  # 1-to-1 Audio call screen
│   │   │   ├── video_call_screen.dart  # 1-to-1 Video call screen with PiP
│   │   │   └── incoming_call_screen.dart# Incoming call accept/decline modal
│   │   └── history/call_history_screen.dart # Call history log screen
│   ├── widgets/
│   │   ├── user_tile.dart             # Contact item card
│   │   ├── call_button.dart           # Circular call action control button
│   │   ├── common_button.dart         # Primary/Secondary form buttons
│   │   ├── call_history_tile.dart     # Past call log item card
│   │   ├── network_quality_indicator.dart # Network signal quality badge
│   │   └── incoming_call_banner.dart  # Floating incoming call notification banner
│   └── main.dart                       # MultiProvider root setup
└── pubspec.yaml
```

---

## ⚡ How to Run the Project

1. **Clone or Extract Repository:**
   ```bash
   cd connect_call
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Static Code Analysis:**
   ```bash
   flutter analyze
   ```

4. **Run Application:**
   ```bash
   # Run on connected phone / emulator / web
   flutter run
   ```

---

## 💬 Technical Review & Interview Questions Guide

### 📱 Flutter
1. **Why did you choose Flutter?**
   - Flutter enables cross-platform compilation (Android, iOS, Web) from a single Dart codebase. It offers near-native performance (compiled directly to ARM machine code), hot reload for quick iterations, and rich customizable Material 3 UI widgets.
2. **Explain your widget structure.**
   - We separate presentation into Atomic Widgets (`widgets/`) and Screen Views (`screens/`). Screens assemble reusable atomic widgets (e.g. `UserTile`, `CallButton`, `CallHistoryTile`) and consume reactive state from `Provider` models.
3. **How does Flutter rebuild widgets?**
   - Flutter builds a widget tree, element tree, and render object tree. When state changes (via `notifyListeners()`), `Consumer` or `Provider.of` marks the dependent element dirty. Flutter recalculates `build()` only for dirty nodes without rebuilding the entire tree.
4. **How are async operations handled?**
   - Async calls (disk read/write, simulated network latency, signaling state timers) use Dart `Future` (`async/await`) and `Stream` controllers (`StreamController.broadcast`).
5. **How are permissions handled?**
   - Microphones and cameras require explicit runtime permission checks before initiating media streams. Permission requests are checked at call startup, gracefully prompting users or falling back to audio-only if camera access is denied.
6. **How does your state management work?**
   - We use `Provider` (`ChangeNotifier`). The app wraps top-level state in `MultiProvider` (`AuthProvider`, `ThemeProvider`, `UserProvider`, `CallProvider`). UI widgets listen selectively using `Consumer` or `context.watch<T>()` to re-render efficiently upon state updates.

---

### 📞 Calling Technology & Signaling
1. **How does the calling SDK / engine work?**
   - `CallingService` acts as the signaling state machine. It manages call transitions (`Calling` ➔ `Ringing` ➔ `Connected` ➔ `InCall` ➔ `Ended`). It uses broadcast streams for call state, duration timer ticks, microphone mute states, speaker toggles, camera states, and simulated network quality changes.
2. **How do you establish a connection between two users?**
   - In production WebRTC or Agora/ZEGOCLOUD implementations, signaling servers exchange SDP offers, SDP answers, and ICE candidates via WebSockets/Firebase. Once signaling succeeds, direct peer-to-peer or SFU media tracks are established. Our `CallingService` encapsulates this exact lifecycle so real WebRTC/Agora SDK handlers can be dropped in seamlessly.
3. **How do you handle incoming calls?**
   - `CallingService` broadcasts `incomingCallStream`. `MainNavigationScreen` wraps a global listener that overlays `IncomingCallBanner` or launches `IncomingCallScreen` when an incoming call arrives, allowing immediate Accept/Decline action.
4. **How do you detect when a call ends?**
   - Calling service emits `CallStatus.ended` via the active call stream. Timers are cancelled, call duration is finalized, the call record is automatically serialized into local call history, and the screen pops back to navigation.
5. **How do you handle network disconnection?**
   - `NetworkQualityIndicator` monitors live network quality (`Good`, `Fair`, `Poor`). If network drops completely, `CallingService` triggers state transition to `CallStatus.failed` / `disconnected` and prompts user retry.
6. **How do you manage microphone and camera permissions?**
   - Mic/Camera toggles (`isMuted`, `isCameraOn`) notify stream controllers. Turning off camera disables local stream rendering without dropping audio connection.

---

### 🏗️ Architecture & Scalability
1. **Explain your project structure.**
   - Clean architecture split into `core/` (tokens/theme/utils), `models/` (plain Dart entities), `services/` (business logic & I/O), `providers/` (state management bridge), `screens/` (UI pages), and `widgets/` (atomic reusable UI elements).
2. **Where is your business logic?**
   - Business logic is strictly contained in `services/` (`CallingService`, `AuthService`, `UserService`) and exposed to UI through `providers/`. UI widgets contain zero backend logic.
3. **How do your services communicate with the UI?**
   - Services expose `Stream` controllers or return data models. Providers listen to these services, store latest state, and call `notifyListeners()`, causing subscribed UI widgets to update reactively.
4. **How would you scale this application?**
   - To scale to millions of active users:
     - Implement **Firebase Cloud Messaging (FCM)** for background push notifications during incoming calls.
     - Integrate **Agora RTC Engine / WebRTC SFU** (e.g. LiveKit or Janus) for server-side video routing.
     - Add **WebSockets / Supabase Realtime** signaling server for instant peer status updates.
     - Use **GetIt / Injectable** dependency injection for modular service instantiation.

---

