# Quick Start: Monetization Setup

## What I've Added

Your app now has a **Pro version** that users can unlock in two ways:
1. **Buy Pro Forever** - $4.99 one-time purchase
2. **Watch Ad for 2 Hours** - Watch a rewarded video ad to get 2 hours of Pro access

## Pro Features (Locked Behind Paywall)

✅ **Full Customization** - Color picker, backgrounds, text styles
✅ **7 & 8 Player Modes** - Access to larger games  
✅ **Save & Load Games** - Persistent game states
✅ **Special Damage** - Commander damage and poison counter tracking

## Files Added/Modified

### New Files:
1. **StoreManager.swift** - Manages in-app purchases and Pro access state
2. **AdManager.swift** - Handles rewarded video ads from Google AdMob
3. **ProUpgradeView.swift** - The upgrade screen shown when users try to access Pro features
4. **MONETIZATION_SETUP.md** - Detailed setup instructions

### Modified Files:
1. **ContentView.swift** - Added pro access checks and UI elements
2. **InGameMenu.swift** - Added pro badges and restrictions
3. **LifeCounterFromScratchT1App.swift** - Initialized Google Mobile Ads
4. **SpecialDamageDeathBackground** - Now uses JPEG image from assets

## Next Steps (Required Before Release)

### 1. Install Google Mobile Ads SDK
In Xcode:
- File > Add Package Dependencies
- URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
- Version: 11.0.0 or later

### 2. Create AdMob Account & App
- Go to https://admob.google.com
- Create app and get your App ID
- Create a Rewarded Ad unit and get the Ad Unit ID

### 3. Update Info.plist
Add your AdMob App ID:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_APP_ID</string>
```

### 4. Update Ad Unit ID in Code
In `AdManager.swift` line 9, replace:
```swift
private let adUnitID = "YOUR_REWARDED_AD_UNIT_ID_HERE"
```

### 5. Configure App Store Connect
- Create the in-app purchase product
- Product ID: `com.yourapp.commandertracker.pro`
- Type: Non-Consumable
- Price: $4.99 USD

### 6. Add Skull Image
Add a skull and crossbones JPEG to your Assets catalog:
- Name it: `skull-crossbones`
- This shows when players reach lethal commander/poison damage

## Testing

### Test In-App Purchase (No Money Required):
1. In Xcode: Product > Scheme > Edit Scheme
2. Run > Options > StoreKit Configuration
3. Create a `.storekit` file with your product
4. Run in simulator - purchases use local configuration

### Test Rewarded Ads:
- Current code uses Google's **test ad unit ID**
- Shows "Test Ad" watermark
- Will work immediately in simulator/device
- Replace with real ad unit ID before release

## How It Works

1. **User tries to access Pro feature** (e.g., 7-player mode, customization)
2. **Pro check fails** → ProUpgradeView appears
3. **User can choose**:
   - Buy Pro Forever ($4.99) → Permanent access
   - Watch Ad → 2 hours of Pro access
4. **Pro access is verified** on every feature attempt
5. **Temporary Pro** (from ads) is persisted across app launches

## Revenue Potential

- **IAP**: ~$3.50 per purchase (after Apple's 30% cut)
- **Ads**: Varies by region, typically $0.50-$5.00 per 1000 views
- Users can watch multiple ads if they don't want to pay

## UI Elements Added

1. **Pro Status Badge** - Shows in corner when Pro is active
   - Shows "Pro" for permanent access
   - Shows countdown timer for temporary access

2. **Crown Icons** - Appear next to locked features in menu
   - Indicates premium features

3. **Pro Upgrade Screen** - Beautiful modal with:
   - Feature list
   - Purchase button with price
   - Watch ad button (shows loading state)
   - Restore purchases button

## Support & Troubleshooting

Check `MONETIZATION_SETUP.md` for:
- Detailed setup instructions
- Common issues and solutions
- Privacy policy requirements
- TestFlight testing steps

## Code Locations

If you need to change the price or features:
- **Product ID**: `StoreManager.swift` line 9
- **Pro Features Check**: `ContentView.swift` `requiresProAccess()` function
- **Ad Unit ID**: `AdManager.swift` line 9
- **Pro Access Duration**: `StoreManager.swift` line 102 (currently 2 hours)

## Before Submitting to App Store

- [ ] Add real AdMob App ID to Info.plist
- [ ] Replace test ad unit with real ad unit
- [ ] Configure in-app purchase in App Store Connect
- [ ] Add privacy policy URL
- [ ] Test with TestFlight
- [ ] Add screenshots of Pro features

---

**Questions?** Check the detailed guide in `MONETIZATION_SETUP.md`
