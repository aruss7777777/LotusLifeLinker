import Foundation
import UIKit
import GoogleMobileAds

@MainActor
class AdManager: NSObject, ObservableObject {
    @Published var isRewardedAdReady = false
    
    private var rewardedAd: RewardedAd?
    private let adUnitID = "ca-app-pub-8760782600257037/7533460951"
    
    var onAdRewarded: (() -> Void)?
    
    override init() {
        super.init()
        Task {
            await loadRewardedAd()
        }
    }
    
    func loadRewardedAd() {
        Task {
            isRewardedAdReady = false

            do {
                let ad = try await RewardedAd.load(with: adUnitID, request: Request())
                ad.fullScreenContentDelegate = self
                rewardedAd = ad
                isRewardedAdReady = true
            } catch {
                rewardedAd = nil
                print("Rewarded ad failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func showRewardedAd(from viewController: UIViewController) {
        guard let rewardedAd = rewardedAd else {
            print("Rewarded ad is not ready")
            loadRewardedAd()
            return
        }
        
        rewardedAd.present(from: viewController) { [weak self] in
            self?.onAdRewarded?()
        }
    }
}

extension AdManager: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        rewardedAd = nil
        loadRewardedAd()
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed")
        rewardedAd = nil
        loadRewardedAd()
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Ad recorded impression")
    }
}
