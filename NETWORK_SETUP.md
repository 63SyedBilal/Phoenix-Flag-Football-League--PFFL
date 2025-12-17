# Network Configuration Setup Guide

## ✅ Completed Configuration

### 1. Backend Server (Next.js)
- **Port**: 3000 (explicitly set)
- **Host**: 0.0.0.0 (accessible from network)
- **Status**: ✅ Running
- **Command**: `npm run dev` (now includes `-p 3000`)

### 2. Flutter App Configuration
- **IP Address**: `192.168.18.26:3000`
- **Base URL**: `http://192.168.18.26:3000/api`
- **Network Priority**: Network IP is now first priority for Android physical devices
- **Timeout**: Increased to 30 seconds for better reliability

### 3. Android Permissions
- ✅ INTERNET permission added
- ✅ ACCESS_NETWORK_STATE permission added

## ⚠️ Important: Windows Firewall Configuration

**You need to allow port 3000 through Windows Firewall manually:**

### Option 1: Using Windows GUI (Recommended)
1. Open **Windows Defender Firewall**
2. Click **Advanced settings**
3. Click **Inbound Rules** → **New Rule**
4. Select **Port** → **Next**
5. Select **TCP** and enter port **3000** → **Next**
6. Select **Allow the connection** → **Next**
7. Check all profiles (Domain, Private, Public) → **Next**
8. Name it "Next.js Dev Server Port 3000" → **Finish**

### Option 2: Using Command Prompt (Run as Administrator)
```cmd
netsh advfirewall firewall add rule name="Next.js Dev Server Port 3000" dir=in action=allow protocol=TCP localport=3000
```

## 🔧 Alternative: ADB Port Forwarding (If Firewall Can't Be Changed)

If you cannot modify Windows Firewall, use ADB port forwarding:

```bash
adb reverse tcp:3000 tcp:3000
```

This will forward port 3000 from your device to your computer, allowing the app to use `localhost:3000` instead of the network IP.

## 📱 Current Network Configuration

### Backend Server
- **Local URL**: http://localhost:3000
- **Network URL**: http://192.168.18.26:3000
- **Status**: ✅ Running and listening on 0.0.0.0:3000

### Flutter App
- **Physical Device IP**: 192.168.18.26:3000
- **Connection Priority**:
  1. Network IP (192.168.18.26:3000) - First priority
  2. localhost:3000 (if ADB forwarding is set)
  3. 127.0.0.1:3000 (fallback)
  4. 10.0.2.2:3000 (emulator only)

## 🚀 Running Both Projects

### Start Backend:
```bash
cd c:\Users\waqas\Desktop\Phoenix-Flag-Football-League--PFFL
npm run dev
```

### Start Flutter App:
```bash
cd c:\Users\waqas\Desktop\Phoenix-Flag-Football-League--PFFL\pffl_managment
flutter run -d 067682514L109381
```

## 🔍 Troubleshooting

### Issue: Connection Timeout
**Solution**: 
1. Ensure both devices are on the same WiFi network
2. Check Windows Firewall allows port 3000
3. Verify IP address hasn't changed: `ipconfig | findstr IPv4`

### Issue: Connection Refused
**Solution**:
1. Restart backend server
2. Check if port 3000 is in use: `netstat -an | findstr :3000`
3. Use ADB port forwarding as alternative

### Issue: IP Address Changed
**Solution**:
1. Run `ipconfig | findstr IPv4` to get new IP
2. Update `pffl_managment/lib/config/app_config.dart` with new IP
3. Hot restart Flutter app (press `R` in terminal)

## 📝 Files Modified

1. **package.json**: Added explicit port `-p 3000`
2. **pffl_managment/lib/config/app_config.dart**: Network IP configured
3. **pffl_managment/lib/core/services/auth_service.dart**: Network IP priority + increased timeout
4. **pffl_managment/android/app/src/main/AndroidManifest.xml**: Network permissions added

## ✅ Verification Checklist

- [x] Backend running on port 3000
- [x] Backend listening on 0.0.0.0 (network accessible)
- [x] Flutter app configured with correct IP
- [x] Android permissions added
- [ ] Windows Firewall rule added (requires admin)
- [x] Network IP priority set in Flutter app
- [x] Connection timeout increased to 30s
