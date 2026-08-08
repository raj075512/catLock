import SwiftUI

struct RoomView: View {
    @State private var viewModel = RoomViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.large) {
                LiveSceneView(scene: .study, cat: .starter, chair: .starter)

                PurchasedItemsView(items: viewModel.purchasedItems)
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppColors.background)
            .navigationTitle("Room")
        }
    }
}
