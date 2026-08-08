import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class StoreKitService {
    private(set) var products: [Product] = []

    func loadProducts(identifiers: Set<String>) async throws {
        products = try await Product.products(for: identifiers)
    }
}
