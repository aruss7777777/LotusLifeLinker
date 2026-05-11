# Monetization Setup Guide

This app uses a combination of in-app purchases and rewarded ads to unlock Pro features.

## Pro Features Include:
- ✅ Full Customization Options (colors, backgrounds, text)
- ✅ 7 & 8 Player Modes
- ✅ Save & Load Games
- ✅ Commander & Poison Damage Tracking (Special Damage)

## Setup Instructions

### 1. StoreKit Configuration (In-App Purchase)

1. **Add the StoreKit Configuration File** (already created in Xcode):
   - File > New > File > StoreKit Configuration File
   - Name it `Products.storekit`
   - Add the following product:
     - **Product ID**: `com.yourapp.commandertracker.pro`
     - **Reference Name**: Commander Tracker Pro
     - **Type**: Non-Consumable
     - **Price**: $4.99 USD

2. **Configure in App Store Connect**:
   - Go to App Store Connect
   - Navigate to your app > In-App Purchases
   - Create a new Non-Consumable In-App Purchase
   - Use the same Product ID: `com.yourapp.commandertracker.pro`
   - Set the price to $4.99 USD
   - Add localizations and screenshots as required

3. **Update the Product ID in Code** (if different):
   - Open `StoreManager.swift`
   - Update line 9: `private let productID = "com.yourapp.commandertracker.pro"`

### 2. Google AdMob Setup (Rewarded Ads)

1. **Create a Google AdMob Account**:
   - Go to https://admob.google.com
   - Create an account or sign in

2. **Create an AdMob App**:
   - Add a new app in AdMob console
   - Get your App ID (looks like: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

3. **Create a Rewarded Ad Unit**:
   - In your app, go to Ad units > Add ad unit > Rewarded
   - Name it "Pro Access Reward"
   - Get the Ad Unit ID (looks like: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`)

4. **Install Google Mobile Ads SDK**:
   Add to your Xcode project via Swift Package Manager:
   - File > Add Package Dependencies
   - Enter: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
   - Select "Up to Next Major Version" with minimum 11.0.0

5. **Update Info.plist**:
   Add the following keys:
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
   <key>SKAdNetworkItems</key>
   <array>
       <dict>
           <key>SKAdNetworkIdentifier</key>
           <string>cstr6suwn9.skadnetwork</string>
       </dict>
       <!-- Add more SKAdNetwork IDs as needed -->
   </array>
   ```

6. **Initialize Google Mobile Ads in Your App**:
   Add to your main app file:
   ```swift
   import GoogleMobileAds
   
   @main
   struct YourApp: App {
       init() {
           GADMobileAds.sharedInstance().start(completionHandler: nil)
       }
       
       var body: some Scene {
           WindowGroup {
               ContentView()
           }
       }
   }
   ```

7. **Update Ad Unit ID**:
   - Open `AdManager.swift`
   - Replace the test ad unit ID on line 9:
     ```swift
     private let adUnitID = "YOUR_REWARDED_AD_UNIT_ID"
     ```

### 3. Testing

#### Testing In-App Purchases:
1. In Xcode, go to Product > Scheme > Edit Scheme
2. Select Run > Options
3. Under StoreKit Configuration, select your `Products.storekit` file
4. Run the app in the simulator or on a device
5. The purchase flow will use the local StoreKit configuration (no real money)

#### Testing Rewarded Ads:
1. The code currently uses a test ad unit ID
2. Test ads will show "Test Ad" watermark
3. Before releasing, replace with your real ad unit ID
4. Test on a real device for best results

### 4. Release Preparation

Before submitting to the App Store:

1. **App Store Connect**:
   - Upload app screenshots
   - Configure in-app purchase metadata
   - Submit for review

2. **Replace Test IDs**:
   - Replace test ad unit ID with production ID in `AdManager.swift`
   - Verify StoreKit product IDs match App Store Connect

3. **Privacy Info**:
   - Update Privacy Policy to mention:
     - In-app purchases
     - Ad tracking (if using personalized ads)
   - Add ATTrackingUsageDescription to Info.plist if using personalized ads:
     ```xml
     <key>NSUserTrackingUsageDescription</key>
     <string>We use tracking to show you personalized ads that help keep our app free.</string>
     ```

4. **Test with TestFlight**:
   - Upload build to TestFlight
   - Test with real users to verify purchase flow

### 5. Price Adjustment

To change the pro price:
1. The display price automatically comes from App Store Connect
2. To change it, update the price in App Store Connect
3. No code changes needed

### 6. Monitoring

- **Sales**: Monitor in App Store Connect > Sales and Trends
- **Ad Revenue**: Monitor in AdMob console
- **Crashes**: Use Xcode Organizer or third-party crash reporting

## File Structure

- `StoreManager.swift`: Handles in-app purchases and pro access
- `AdManager.swift`: Manages rewarded video ads
- `ProUpgradeView.swift`: UI for the upgrade/purchase screen
- `ContentView.swift`: Main app with pro access checks integrated
- `InGameMenu.swift`: Updated to show pro badges and restrict features

## Support

For issues:
- **StoreKit**: Apple Developer Forums
- **AdMob**: Google AdMob Support
- Check console logs for detailed error messages
