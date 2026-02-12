# QUICK FIX: Provider manuell refreshen

Da der Provider gecacht ist, müssen wir ihn manuell refreshen:

## Option 1: Logout/Login (schnellste Lösung)
1. In der App: Logout
2. Neu einloggen
3. Navigiere zum Signatur-Screen
→ Provider wird neu geladen

## Option 2: Provider in Dev Tools invalidieren
Wenn Flutter DevTools läuft:
1. Öffne DevTools → Provider Tab
2. Finde `userProfileProvider`
3. Klicke "Refresh"

## Option 3: Code-Fix (wenn Option 1+2 nicht helfen)
Das Problem ist dass der Provider bei Navigation zum Signatur-Screen
bereits gecacht ist.

Lösung: Provider in `initState()` oder bei Screen-Öffnung refreshen.
