import Foundation
import UIKit
// import GoogleMobileAds // Temporarily disabled - uncomment after installing SDK

@MainActor
class AdManager: NSObject, ObservableObject {
    @Published var isRewardedAdReady = false
    
    // private var rewardedAd: GADRewardedAd?
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313" // Test Ad Unit ID
    
    var onAdRewarded: (() -> Void)?
    
    override init() {
        super.init()
        // Simulate ad being ready for testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isRewardedAdReady = true
        }
        // loadRewardedAd()
    }
    
    func loadRewardedAd() {
        // Temporarily disabled - will be enabled when SDK is installed
        /*
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
                self?.isRewardedAdReady = false
                return
            }
            
            self?.rewardedAd = ad
            self?.isRewardedAdReady = true
            self?.rewardedAd?.fullScreenContentDelegate = self
        }
        */
    }
    
    func showRewardedAd(from viewController: UIViewController) {
        // Simulate watching an ad for testing
        print("⚠️ Ad SDK not installed - simulating ad reward")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onAdRewarded?()
        }
        
        /*
        guard let rewardedAd = rewardedAd else {
            print("Rewarded ad is not ready")
            loadRewardedAd() // Try to load again
            return
        }
        
        rewardedAd.present(fromRootViewController: viewController) { [weak self] in
            // User earned the reward
            self?.onAdRewarded?()
        }
        */
    }
}

// Temporarily disabled - will be enabled when SDK is installed
/*
extension AdManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        loadRewardedAd() // Load a new ad
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad dismissed")
        loadRewardedAd() // Load a new ad
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("Ad recorded impression")
    }
}
*/
