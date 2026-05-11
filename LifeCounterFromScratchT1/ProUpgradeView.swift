import SwiftUI

struct ProUpgradeView: View {
    @ObservedObject var storeManager: StoreManager
    @ObservedObject var adManager: AdManager
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.proBadge)
                    
                    Text("Upgrade to Pro")
                        .font(.title.bold())
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("Unlock all premium features")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.top, 20)
                
                // Features List
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "paintbrush.fill", text: "Full Customization Options")
                    FeatureRow(icon: "person.3.fill", text: "7 & 8 Player Modes")
                    FeatureRow(icon: "square.and.arrow.down.fill", text: "Save & Load Games")
                    FeatureRow(icon: "bolt.heart.fill", text: "Commander & Poison Damage Tracking")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.proBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Purchase Options
                VStack(spacing: 12) {
                    // Permanent Purchase
                    if let product = storeManager.products.first {
                        Button {
                            Task {
                                try? await storeManager.purchase(product)
                                onDismiss()
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text("Buy Pro Forever")
                                    .font(.headline)
                                Text(product.displayPrice)
                                    .font(.title2.bold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    
                    // Watch Ad for Temporary Access
                    Button {
                        // Get the view controller to present the ad
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let viewController = windowScene.windows.first?.rootViewController {
                            adManager.onAdRewarded = {
                                storeManager.grantTemporaryProAccess()
                                onDismiss()
                            }
                            adManager.showRewardedAd(from: viewController)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                Text("Watch Ad for 2 Hours Free")
                            }
                            .font(.headline)
                            
                            if !adManager.isRewardedAdReady {
                                Text("Loading ad...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!adManager.isRewardedAdReady)
                    .opacity(adManager.isRewardedAdReady ? 1.0 : 0.6)
                    
                    // Restore Purchases
                    Button {
                        Task {
                            await storeManager.restorePurchases()
                            onDismiss()
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 20)
                
                // Close Button
                Button {
                    onDismiss()
                } label: {
                    Text("Maybe Later")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 20)
            }
            .frame(width: 350)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct ProStatusBadge: View {
    @ObservedObject var storeManager: StoreManager
    
    var body: some View {
        if storeManager.hasProAccess {
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.caption2)
                
                if let remainingTime = storeManager.remainingProTime() {
                    Text("Pro: \(formatTime(remainingTime))")
                        .font(.caption2.bold())
                } else {
                    Text("Pro")
                        .font(.caption2.bold())
                }
            }
            .foregroundStyle(.yellow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    ProUpgradeView(
        storeManager: StoreManager(),
        adManager: AdManager(),
        onDismiss: {}
    )
}
