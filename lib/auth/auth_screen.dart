//==========================================================
// Step 2: Build the Modern Auth System (Login / Sign-Up)
//==========================================================

import 'package:flutter/material.dart';
//import 'package:expense_tracker/admin/admin_dashboard.dart';
import 'package:expense_tracker/auth/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 📝 NOTE / HINTS:
  // 1) Global State Flags and Authentication Service Instances:
  // What it does: This initializes the local view controllers and state engines for your forms.
  // - '_formKey': A global token index tracker that handles triggering validation checks across your fields.
  // - '_authService': Pulls your custom login/signup business controller class ruleset into view.
  // - '_isLoginMode': A toggle variable tracking whether to paint the "Login" or "Register" layout tree.
  // - '_isLoading': A safety state flag variable used to block multi-clicks and switch button graphics.
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final AuthService _authService =
      AuthService(); // 2. Initialize the service layer

  var _isLoginMode = true; // State toggle variable
  var _isLoading = false; // 3. Added a clean UI loading tracker flag variable
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _selectedRole = 'user'; // Defaults safely to standard user mode

  // 📝 NOTE / HINTS:
  // 2) Form Submission Handler and Async Authentication Gate (_submitAuthForm):
  // What it does: This is the operational engine that handles user authentication requests.
  // 1. It validates every single input field on-screen using your global form key trackers.
  // 2. Turns on a spinning loading indicator and invokes your asynchronous '_authService' methods.
  // 3. Branches smoothly between 'signInUser()' or 'signUpAdmin()' depending on your '_isLoginMode' state flag.
  // 4. Safely guards against context drops via 'if (!mounted) return;' before performing layout routing transitions.
  void _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true; // Turn on spinning progress indicator
    });
    try {
      if (_isLoginMode) {
        // Run cloud authentication request
        await _authService.signInUser(
          email: _enteredEmail.trim(),
          password: _enteredPassword.trim(),
        );
      } else {
        // Run cloud registration request
        await _authService.signUpUser(
          email: _enteredEmail.trim(),
          password: _enteredPassword.trim(),
          username: _enteredUsername.trim(),
          role: _selectedRole, // 👈 PASS THE DYNAMIC ROLE SELECTION HERE
        );
      }

      if (!mounted) return;

      // Authentication clear: Router navigates forward to the Admin System
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const AdminDashboard()),
      // );

      // 📝 NOTE / HINTS:
      // 3) Visual Server Validation Error Guard (Catch Block):
      // What it does: This is your network connection validation watchdog block.
      // If your Firebase server rejects the login request (like an invalid password or non-existent email),
      // this block intercepts the network crash and pushes a clean error string onto a floating SnackBar notification layer.
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      // Handle server validation drops by triggering professional warning snackbars
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating, // Premium floating format look
        ),
      );
      // 📝 NOTE / HINTS:
      // 4) Stateful Layout Reset Watchdog (Finally Block):
      // What it does: This is a safe final execution block that always runs whether the network transaction succeeded or failed.
      // It safely verifies that the viewport screen is still active ('if (mounted)') and sets your '_isLoading' flag back to false
      // to restore click behaviors and clear spinning widgets.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Turn off spinning indicator safely
        });
      }
    }

    // ⚠️ CRITICAL NOTE / BUG ALERT:
    // 5) Note on Bug / Logic Duplicate 💡
    // This second 'Navigator.pushReplacement' block down here accidentally sits OUTSIDE of your try/catch logic gate!
    // Even if a user types a wrong password and your Firebase request throws an error snackbar, this line will executing-fire
    // anyway, bypassing security and forcing the screen forward into your AdminDashboard layout window regardless.
    // REMEDY: You should safely DELETE this duplicate code block, as your secure routing line is already written inside the try loop above!
    // 2. Visual feedback: Simulates a successful login and routes to Admin Dashboard
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const AdminDashboard()),
    // );
  }

  // 📝 NOTE / HINTS:
  // 6) Main Interface Layout Builder & Conditional Header Text:
  // What it does: This builds the core visual user viewport framework for your Authentication page.
  // - 'SingleChildScrollView': Protects your forms against keyboard overflow yellow stripe crashes when input targets are clicked.
  // - Conditional Title: Uses a ternary condition operator ('_isLoginMode ? ... : ...') to dynamically change the on-screen text
  //   strings between 'Welcome Back' and 'Create Admin Profile' smoothly based on the active selection state.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branding Section
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _isLoginMode ? 'Welcome Back' : 'Create Admin Profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                if (!_isLoginMode)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Account Role Profile Type',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('Standard Personal User'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Master Console Administrator'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value; // Tracks selection state
                        });
                      }
                    },
                  ),
                if (!_isLoginMode) const SizedBox(height: 16),

                // 📝 NOTE / HINTS:
                // 7) Dynamic Field Visibility & Field Validation Checkers:
                // What it does: These are your individual form data entry lines.
                // - Conditional Row: 'if (!_isLoginMode)' blocks the 'Username' field from drawing when a user simply tries to sign in.
                // - Validation Watchdogs: 'validator: (value) => ...' evaluates field criteria in real-time, blocking submission steps
                //   if text lengths are missing or symbols like '@' are skipped inside your inputs.
                // Username input field (Only shown during registration)
                if (!_isLoginMode)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().length < 4)
                        ? 'Username must be at least 4 characters.'
                        : null,
                    onSaved: (value) => _enteredUsername = value ?? '',
                  ),
                if (!_isLoginMode) const SizedBox(height: 16),

                // Email input field
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'Please enter a valid email address.'
                      : null,
                  onSaved: (value) => _enteredEmail = value ?? '',
                ),
                const SizedBox(height: 16),

                // Password input field
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 6)
                      ? 'Password must be at least 6 characters long.'
                      : null,
                  onSaved: (value) => _enteredPassword = value ?? '',
                ),
                const SizedBox(height: 24),

                // 📝 NOTE / HINTS:
                // 8) Primary Execution Button & Clean Mode Switcher:(8) Loading-Aware Execution Button & Toggle Link Button)
                // What it does: These are your lower structural layout action triggers.
                // - 'ElevatedButton': Uses a ternary check to check if '_isLoading' is active. If active, it locks clicking behavior to 'null'
                //   and draws a spinning 'CircularProgressIndicator'. If clear, it runs '_submitAuthForm'.
                // - 'TextButton': Toggles your boolean variable mode status state (`_isLoginMode = !_isLoginMode`) inside a quick 'setState()' call,
                //   allowing users to bounce between login and signup interfaces instantly without opening a separate page route!
                // Primary Execution Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _submitAuthForm, // Disables button clicks while active
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isLoginMode ? 'Sign In' : 'Register Account'),
                ),

                // Clean Mode Switcher Toggler Link
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(
                    _isLoginMode
                        ? 'Create new admin account'
                        : 'I already have an account. Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
