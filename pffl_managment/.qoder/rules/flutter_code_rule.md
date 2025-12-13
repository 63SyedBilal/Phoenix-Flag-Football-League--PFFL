---
trigger: always_on
alwaysApply: true
---
1. Use only StatelessWidget, avoid StatefulWidget.
2. Handle all state changes using Provider.
3. Keep project structure organized:
   - models/
   - providers/
   - screens/
   - widgets/
   - services/
   - utils/
4. Name files and classes in PascalCase.
5. Name variables and functions in camelCase.
6. Keep constants in UPPER_CASE or a separate constants file.
7. Do not use magic numbers; define padding, margin, font sizes in constants.
8. Make UI pixel-perfect, follow Figma/design specs.
9. Create reusable widgets in widgets/ folder.
10. Use a base widget for common scaffold, AppBar, BottomNav, etc.
11. Keep Provider variables private; use getters/setters and notifyListeners().
12. Do not call APIs or Firebase directly from UI; use services/ folder.
13. Show errors via provider variables, not directly in UI.
14. Maintain responsive UI using Sizer, MediaQuery, or custom utilities.
15. Do not hardcode strings or colors; use constants or theme.
16. Define theme and fonts in a separate file for consistency.
17. Use named routes or GoRouter for navigation.
18. Keep animations simple and reusable; create separate animation widgets if needed.
19. Comment only for complex logic; avoid obvious code comments.
