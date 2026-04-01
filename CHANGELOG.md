Changelog

[2.1.0] - 2026-04-01

✨ Added

- Added optimized "setup.sh" with faster and cleaner installation flow
- Added improved VNC startup script with better stability
- Added automatic cleanup for stale VNC locks and sessions
- Added safer environment setup and launcher handling
- Improved sound configuration with duplicate prevention

🔄 Changed

- Refactored installer scripts for better performance and readability
- Reduced redundant package updates and installs
- Improved VNC configuration (resolution, depth, and startup handling)
- Updated default behavior to prevent unnecessary reinstallation
- Cleaned overall script structure for maintainability

🐛 Fixed

- Fixed VNC PID cleanup issue (wildcard bug)
- Fixed incorrect VNC stop script behavior
- Fixed potential “VNC already running” false errors
- Fixed duplicate entries in sound configuration
- Fixed minor path and permission issues

🔒 Security

- Restricted VNC server to localhost by default
- Prevented unintended network exposure

---

<!-- END -->