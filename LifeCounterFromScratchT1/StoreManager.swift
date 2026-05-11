import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published private(set) var hasProAccess: Bool = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var proExpirationDate: Date?
    
    private let productID = "com.yourapp.commandertracker.pro"
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            let loadedProducts = try await Product.products(for: [productID])
            products = loadedProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Handling
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            
        case .userCancelled:
            break
            
        case .pending:
            break
            
        @unknown default:
            break
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Transaction Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Update Purchased Products
    
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productID == productID {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedIDs
        updateProAccess()
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Pro Access Management
    
    private func updateProAccess() {
        // Check if user has purchased pro
        let hasPermanentPro = purchasedProductIDs.contains(productID)
        
        // Check if temporary pro from ad is still active
        let hasTemporaryPro = if let expirationDate = proExpirationDate {
            expirationDate > Date()
        } else {
            false
        }
        
        hasProAccess = hasPermanentPro || hasTemporaryPro
    }
    
    // MARK: - Rewarded Ad Pro Access
    
    func grantTemporaryProAccess() {
        // Grant 2 hours of pro access
        proExpirationDate = Date().addingTimeInterval(2 * 60 * 60)
        updateProAccess()
        
        // Save to UserDefaults for persistence
        UserDefaults.standard.set(proExpirationDate, forKey: "proExpirationDate")
    }
    
    func loadTemporaryProAccess() {
        if let savedDate = UserDefaults.standard.object(forKey: "proExpirationDate") as? Date {
            proExpirationDate = savedDate
            updateProAccess()
        }
    }
    
    func remainingProTime() -> TimeInterval? {
        guard let expirationDate = proExpirationDate else { return nil }
        let remaining = expirationDate.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }
}

enum StoreError: Error {
    case failedVerification
}
