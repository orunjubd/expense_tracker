//==========================================================
// Step 3: Create the Professional Admin Dashboard Panel Layout
//==========================================================
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this is imported at the top of the file
//import 'package:expense_tracker/admin/manage_users.dart'; // Placeholder management view components
//import 'package:expense_tracker/admin/manage_data.dart'; // Placeholder management view components

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

// 📝 NOTE / HINTS:
// 1) Global Current Session Trackers & Navigation Index Variables:
// What it does: This initializes your state control parameters for the admin dashboard workspace.
// - '_selectedPageIndex': Tracks which tab index icon row is currently clicked at the bottom baseline.
// - '_currentUser': Pulls an identity reference package directly out of your active Firebase engine instance.
// How it connects: Decides which panel view sub-widget screen to paint inside your 'Scaffold' body slot.
class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedPageIndex = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // 📝 NOTE / HINTS:
  // 2) Secure Cloud Sign Out & Navigation History Stack Purge (_handleSignOut):
  // What it does: This handles the secure administrator logout routine workflow sequence.
  // 1. '.signOut()': Sends a request to revoke the current session token inside your cloud servers [INDEX].
  // 2. 'pushAndRemoveUntil': Destroys all active navigation screen tracking memory history loops
  //    and kicks the user back to the login screen. It acts as a safety wall blocking them from ever hitting
  //    the device back button to sneak back into the administrator panels without typing a password!
  // Function to handle logging out safely from the cloud
  // below handleSignOut() async line for icon and text(username) display
  void _handleSignOut() async {
    await FirebaseAuth.instance
        .signOut(); // 3. Disconnect session from Firebase servers
    if (!mounted) return;
    // 4. Wipe navigation stack history and push user completely back to login screen
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => const AuthScreen()),
    //   (route) =>
    //       false, // This clears the back button history so they cannot slip back in without a password
    // );
  }

  // 📝 NOTE / HINTS:
  // 3) Controller Subpage Matrix Collection Array (_adminPages):
  // What it does: This acts as your view controller page router matrix map. It groups your 3 standalone
  // administrator feature screens into a single array block, allowing you to cycle through them inside your build trees.
  // - Index 0: Metrics chart graphs overview panel.
  // - Index 1: Manage profiles and user lists engine hub.
  // - Index 2: Global category parameter configurations worksheet.
  // The separate structural components managed by the control panel
  final List<Widget> _adminPages = [
    const AdminOverviewGrid(), // Global graphs & metrics summaries
    const ManageUsersScreen(), // User control list engine hub
    const ManageDataScreen(), // Global parameters manager
  ];

  @override
  Widget build(BuildContext context) {
    // 📝 NOTE / HINTS:
    // 4) Dynamic Email-to-Name Formatting Processor (_adminDisplayName):
    // What it does: This is a cosmetic text formatting string helper block. It reads your raw user email parameter
    // string (e.g. 'john@email.com'), cuts off the text right after the '@' sign, and capitalizes the very first index
    // character to dynamically format a premium personal profile label (e.g. 'John') on the spot.
    // below two line for icon and text(username) display
    // 5. Get the clean email prefix to display as a temporary name string label
    String adminDisplayName = _currentUser?.email?.split('@')[0] ?? 'Admin';
    adminDisplayName =
        adminDisplayName.substring(0, 1).toUpperCase() +
        adminDisplayName.substring(
          1,
        ); // Capitalize the first letter for a clean look

    return Scaffold(
      appBar: AppBar(
        // ⚠️ CRITICAL NOTE / UX CHECK:
        // 5) Note on Header Navigation Control 💡
        // 'automaticallyImplyLeading: true' is turned on here. Since your 'AuthScreen' routes forward using
        // 'pushReplacement', Flutter should safely skip drawing an arrow back button (←). However, if your
        // layout ever forces an unintended back arrow, switching this parameter explicitly to 'false' will
        // hide the arrow to stop users from navigating backward into login screens while active in the panel!
        // 🚀 ADD THIS LINE to completely hide the confusing back arrow icon!
        automaticallyImplyLeading: true,
        //title: const Text('TrackFlow Master Console'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.errorContainer, // Visually alerts it's Admin Mode
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        // below elevation and  title: Row( line for icon and text(username) display

        // below title: Row( line for icon and text(username) display
        elevation: 0,

        // 📝 NOTE / HINTS:
        // 6) Dynamic Header Profile Avatar Row & Title Layout:
        // What it does: This builds the top panel brand section inside your header AppBar layout row.
        // - 'CircleAvatar': Generates a professional round initials bubble using the first character of your computed name string.
        // - 'Column': Packs your profile title name and a small fixed subtext ('Master Console') to match executive corporate tool layouts.
        // - 'errorContainer' Color: Shifts background shades automatically to red alerts to explicitly signal to admins they are browsing master roots.
        // TITLE SECTION: Combines a profile bubble and dynamic login name
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onErrorContainer.withAlpha(40),
              child: Text(
                adminDisplayName.substring(
                  0,
                  1,
                ), // Takes first character as avatar text
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  adminDisplayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Master Console',
                  style: TextStyle(fontSize: 10, letterSpacing: 0.5),
                ),
              ],
            ),
          ],
        ),

        // 📝 NOTE / HINTS:
        // 7) Master De-Authentication Dialog Trigger Action Button:
        // What it does: This builds your top-right exit action control button handler layer.
        // - Tapping the box opens a 'showDialog' overlay alert box asking for explicit log out confirmation.
        // - The 'ElevatedButton' within the dialog utilizes your master red 'error' theme color palette settings,
        //   closes the popup window context, and fires your backend '_handleSignOut()' script routine on click.
        // ACTIONS SECTION: Clean logout operation handler
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            tooltip: 'Logout from Console',
            onPressed: () {
              // Show a confirmation dialog before kicking them out
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text(
                    'Are you sure you want to log out of the admin master console session?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx); // Close dialog
                        _handleSignOut(); // Execute logout script sequence
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _adminPages[_selectedPageIndex],

      // 📝 NOTE / HINTS:
      // 8) Master Switcher Tab Navigation Bar (BottomNavigationBar):
      // What it does: This builds your lower core view switching bar controls.
      // - 'currentIndex' binds layout highlight tracks directly to your '_selectedPageIndex' state variable.
      // - 'onTap' listens for single finger clicks on row items and passes the selected tracking slot index directly
      //   into a 'setState(() => ...)' callback to instantly swap your main 'Scaffold' body widget view frame!
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) => setState(() => _selectedPageIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.error,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'System Config',
          ),
        ],
      ),
    );
  }
}

// 📝 NOTE / HINTS:
// 9) Admin Dashboard Overview Grid:(Global Analytics Layout Grid (AdminOverviewGrid):
// What it does: This component builds your admin main dashboard workspace screen layout.
// It groups macro-level system metrics (such as total registered profiles or hardware server loads)
// into an organized layout grid for executives.
// How it connects: It is hosted as the very first widget card item (Index 0) inside your master
// '_adminPages' array list collection lower down inside the core file class tracker.
// Sub-Widget: Clean dashboard layout metrics blocks
class AdminOverviewGrid extends StatelessWidget {
  const AdminOverviewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Health Snapshot',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 📝 NOTE / HINTS:
          // 10) Admin Dashboard Analytics Matrix Grid (GridView.count): High-Performance Quadrant Dashboard Grid (GridView.count)
          // What it does: This is a matrix layout engine. By setting 'crossAxisCount: 2', it forces
          // your analytics panel to mathematically divide screen width into a clean 2-column card grid grid.
          // - 'crossAxisSpacing' and 'mainAxisSpacing' handle setting uniform separation gaps.
          // - 'Expanded' constraints guarantee that the matrix scales gracefully across any phone screen viewport.
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMetricCard(
                  context,
                  'Total Users',
                  '1,248',
                  Icons.supervised_user_circle,
                  Colors.blue,
                ),
                _buildMetricCard(
                  context,
                  'Global Volume',
                  'Tk 4.2M',
                  Icons.monetization_on,
                  Colors.green,
                ),
                _buildMetricCard(
                  context,
                  'Active Syncs',
                  '412',
                  Icons.sync_lock_rounded,
                  Colors.purple,
                ),
                _buildMetricCard(
                  context,
                  'Server Health',
                  '99.8%',
                  Icons.cloud_done_rounded,
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📝 NOTE / HINTS:
  // 11) Admin Dashboard Metrics Card Template Method (Widget _buildMetricCard):
  // Reusable Metrics Component Builder (_buildMetricCard):
  // What it does: This is an efficient reusable widget function utility. Instead of repeating
  // 40 lines of messy layout code over and over for your metrics, this template method lets you
  // pass down a specific heading label string, value data string, and color tracker variable [INDEX].
  // How it connects: It is invoked 4 separate times inside your grid matrix tree to rapidly render
  // your 'Total Users', 'Global Volume', 'Active Syncs', and 'Server Health' stats error-free.
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),

        // 📝 NOTE / HINTS:
        // 12) Admin Dashboard Metrics Card Layout (Column):Left-Aligned Value Stacking Logic
        // What it does: This designs the structural item flow within an individual grid dashboard tile box card.
        // - 'Icon' paints your graphic color accent marker at the very top left edge corner.
        // - 'Spacer()' stretches out to push all subsequent text layers downward toward the card baseline.
        // - 'headlineSmall' fetches your typography settings variables, ensuring your bold numbers (like 'Tk 4.2M')
        //   look crisp, uniform, and highly professional out-of-the-box.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

//==========================================================
// Step 4: Create the Professional Admin Dashboard Control Panel
// PLACEHOLDER: Manage Users Screen Component
// ==========================================
class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📝 NOTE / HINTS:
      // 13) Admin Dashboard Manage Users Screen (StreamBuilder): Real-Time Reactive Network Pipeline:Reactive Cloud Data Tunnel (StreamBuilder)
      // What it does: This is a real-time reactive network pipeline wrapper widget.
      // - Instead of loading data once and freezing, 'StreamBuilder' establishes a permanent, active listener pipe directly to your cloud Firestore 'users' collection [INDEX].
      // - Whenever a new account registers, or a user updates their profile on another device, this stream instantly catches the change and re-draws the list view row profiles on the screen automatically!
      // - '.orderBy('createdAt', descending: true)' writes an SQL-style query filter rule ensuring the freshest signups appear at the very top of the list viewport [INDEX].
      body: StreamBuilder<QuerySnapshot>(
        // 1. Establishes a permanent live pipe directly to your cloud 'users' collection table
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy(
              'createdAt',
              descending: true,
            ) // Newest registrations show up first
            .snapshots(),
        builder: (context, snapshot) {
          // 📝 NOTE / HINTS:
          // 14) Network Data Safety Guard Firewall (Async Handlers):
          // Admin Dashboard Manage Users Screen (StreamBuilder): Reactive Cloud Data Tunnel (StreamBuilder)
          // What it does: This is your async state network monitor gatekeeper. It checks the live connection pipeline and handles 3 crucial lifecycle states safely:
          // 1. 'ConnectionState.waiting': If the user is on slow mobile internet, it draws a spinning 'CircularProgressIndicator' to indicate the app is actively working.
          // 3. 'snapshot.hasError': If security rules block access or the internet drops completely, it prevents app crashes by displaying a clear connection error text string.
          // 5. 'userDocs.isEmpty': If zero accounts are found inside your NoSQL Firestore collections table, it returns a clean fallback warning text string layer ('No registered users found.').
          // 2. Display a spinning wheel loader while data is traveling through the internet
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Handle errors if the database rules block access or connection drops
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Connection Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 4. Safely extract documents from the snapshot
          final userDocs = snapshot.data?.docs ?? [];

          // 5. Handle empty state if no user accounts exist in the cloud yet
          if (userDocs.isEmpty) {
            return const Center(
              child: Text(
                'No registered users found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // 📝 NOTE / HINTS:
          // 15) High-Performance Segmented List Builder (ListView.separated):
          // Admin Dashboard Manage Users Screen (ListView.separated): Professional Modern Scrolling Layout Manager
          // What it does: This is an upgraded scrolling layout manager.
          // - 'itemCount: userDocs.length' tells it exactly how many user records exist inside your server query array map data tracks.
          // - 'separatorBuilder' acts as a clean style tool, automatically injecting a uniform vertical spacing gap block ('SizedBox(height: 12)') between your rows without forcing you to add messy padding margins inside your card layouts manually.
          // 6. Build the modern reactive scrolling list view of profile records
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: userDocs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // 📝 NOTE / HINTS:
              // 16) Cloud Map Extraction and Date Formatter Blueprint:
              // Cloud Firestore Data Parsing Engine (Map<String, dynamic>):
              // What it does: This is your backend parsing engine.
              // 1. It extracts a row item out of Firestore and casts it into a structured Key-Value Map format ('Map<String, dynamic>').
              // 2. Grabs data parameters using matching bracket keys like userData['username'] or userData['role'].
              // 3. Translates raw cloud 'Timestamp' parameters down into simple text day/month/year digit numbers using '.toDate()' calculations.
              // Extract raw string maps cleanly from document arrays
              final userData = userDocs[index].data() as Map<String, dynamic>;

              final String username = userData['username'] ?? 'Anonymous';
              final String email = userData['email'] ?? 'No Email Provided';
              final String role = userData['role'] ?? 'user';
              final Timestamp? createdAt = userData['createdAt'] as Timestamp?;

              // Format date cleanly if snapshot timestamp parameter maps properly
              final String joinDate = createdAt != null
                  ? "${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}"
                  : "Unknown Date";

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  // 📝 NOTE / HINTS:
                  // 17) Role-Aware Custom Initials Avatar Generator (Leading):
                  //  Premium Responsive Profile Avatar Circle (CircleAvatar):
                  // What it does: This builds a premium responsive profile avatar circle inside each row item.
                  // - It evaluates the user's secret database 'role' parameter attribute word string.
                  // - If the account is an 'admin', it automatically tints the circle to a soft red background ('Colors.red.shade50') and paints a red initial letter.
                  // - If they are a standard profile user, it switches colors dynamically to light blues ('Colors.blue.shade50').
                  // Render a clean modern avatar holding user initials
                  leading: CircleAvatar(
                    backgroundColor: role == 'admin'
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: role == 'admin' ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),

                  // 📝 NOTE / HINTS:
                  // 18) Reactive Role Label Accent Badge (Title Row):
                  //  Premium Responsive Profile Avatar Circle (Trailing):
                  // What it does: This is a compact label decoration accent tag. It maps out your username, text spacing gaps, and packs an elegant status container chip next to it.
                  // - It reads your 'role' string variable, converts characters to uppercase, and uses a nested ternary color matcher rule to toggle tag colors ('red.shade100' vs 'blue.shade100') instantly based on access clearance privileges!
                  title: Row(
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Role Badge decoration accent tags
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: role == 'admin'
                              ? Colors.red.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: role == 'admin'
                                ? Colors.red.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Joined: $joinDate',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                  ),

                  // 📝 NOTE / HINTS:
                  // 19) Future Administration Interaction Hooks (onTap):
                  // Interactive Administrator Command Hook Slot (OnTap):
                  // What it does: This is your interactive administrator command hook slot handler.
                  // - Clicking anywhere inside a user's account card card row tile captures their structural ID profile.
                  // - This is the exact placeholder track where you will write code in your next update to slide up an action overlay menu sheet to change permissions, review user spending sheets, or execute account ban routines!
                  onTap: () {
                    // TODO: Implement user detail sheet or ban options overlay
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// PLACEHOLDER: Manage Data Screen Component
// ==========================================
// 📝 NOTE / HINTS:
// 20)  Global Configuration Dashboard Placeholder (ManageDataScreen):
// Manage Data Screen Placeholder Component:
// What it does: This builds your final system control settings page view placeholder component layout.
// - It sets up a centrally aligned column tree holding a warning storage system vector symbol emblem ('Icons.storage_rounded') and descriptive instruction paragraph text.
// - How it connects: This component is managed as the final selection widget (Index 2) inside your main dashboard 'BottomNavigationBar' tab index switcher array collections.
class ManageDataScreen extends StatelessWidget {
  const ManageDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_rounded,
              size: 64,
              color: Colors.orange.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Global System Configurations',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here you will manage global spending categories, app flags, limits, and review platform-wide expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
