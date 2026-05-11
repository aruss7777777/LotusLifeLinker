# Pro Status Badge and Upgrade Option Location

The Pro interface now appears in **two locations**:

## 1. Main Menu (Top Left)
When the user is on the main menu/home screen, the Pro status badge appears in the top-left corner showing:
- **"Pro"** if they have permanent Pro access (purchased)
- **"Pro: Xh Ym"** if they have temporary Pro access from watching an ad (shows countdown)
- Only appears when user HAS Pro access

## 2. In-Game Menu → Settings (Top Row)
When the user opens the in-game menu and taps on the Settings gear icon, a **"Pro" upgrade/manage row** appears at the top showing:

### When User Has No Pro Access:
```
👑 Pro
   Tap to unlock premium features     >
```
Tapping opens the Pro Upgrade screen where they can:
- Buy Pro forever ($4.99)
- Watch an ad for 2 hours free

### When User Has Temporary Pro (From Ad):
```
👑 Pro
   Active: 1h 45m remaining     >
```
Tapping opens the Pro Upgrade screen where they can:
- Buy Pro forever to make it permanent
- Watch another ad to extend their time by 2 more hours

### When User Has Permanent Pro (Purchased):
```
👑 Pro
   Active     >
```
Shows confirmation that Pro is active forever

## What It Shows

### Main Menu Badge (Only When Pro Is Active)
**Permanent Pro:**
```
👑 Pro
```

**Temporary Pro:**
```
👑 Pro: 1h 45m
```

### Settings Pro Row (Always Visible)
This row is **always present** in settings, making it easy to:
- ✅ Upgrade to permanent Pro
- ✅ Watch ads to extend temporary access
- ✅ Check Pro status at a glance

## Implementation Details

### Main Menu Badge
- Located in `ContentView.swift`
- Positioned in a `VStack` / `HStack` overlay on the MainMenu view
- Top-left corner with padding
- Only visible when `displayedView == "MainMenu"` AND `hasProAccess == true`

### Settings Pro Row
- Located in `InGameMenu.swift` in the `settingsContent` computed property
- **Always visible** as the first option in settings
- Taps call `onShowProUpgrade()` to open the upgrade modal
- Shows different text based on Pro status:
  - No Pro: "Tap to unlock premium features"
  - Temporary Pro: "Active: Xh Ym remaining"
  - Permanent Pro: "Active"

### Badge Component
- Defined in `ProUpgradeView.swift` as `ProStatusBadge`
- Takes `@ObservedObject var storeManager: StoreManager` as parameter
- Automatically updates when Pro status changes
- Formats remaining time as hours and minutes

## User Experience

### Discovery & Upgrade Path
1. **New Users** see "Pro" in settings with "Tap to unlock premium features"
2. **Temporary Pro Users** can easily extend time by watching more ads
3. **All Users** have clear path to upgrade to permanent Pro

### Benefits
- **Always accessible** - Pro upgrade is never hidden
- **Status at a glance** - See remaining time without opening upgrade screen
- **Easy extension** - Watch another ad anytime to add 2 more hours
- **Clear value** - Settings row explains what Pro offers
- **Non-intrusive** - Badge only shows on home screen when active
