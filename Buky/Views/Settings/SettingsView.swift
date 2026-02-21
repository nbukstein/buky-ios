import SwiftUI
import StoreKit

struct SettingsView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showReadingTips = false
    @State private var showManageSubscriptions = false
    @State private var showSubscriptionView = false

    var body: some View {
        List {
            // MARK: - Subscription
            Section {
                if viewModel.isSubscribed {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Buky Premium", comment: "Subscription active label")
                                .font(.h4Bold)
                            Text(viewModel.currentTierLabel)
                                .font(.bodyRegular)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        showManageSubscriptions = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                                .frame(width: 32)
                            Text("Manage Subscription", comment: "Button to manage subscription")
                                .font(.h5Medium)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Button {
                        showSubscriptionView = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.tertiaryBrand, .cuarterlyBrand],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Get Buky Premium", comment: "Upgrade to premium button")
                                    .font(.h4Bold)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("Unlock all stories and features", comment: "Premium upgrade subtitle")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.h5Bold)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Subscription", comment: "Subscription section header")
                    .font(.captionRegular)
            }

            // MARK: - General
            Section {
                Button {
                    showReadingTips = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 20))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.tertiaryBrand, .cuarterlyBrand],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32)
                        Text("Reading tips", comment: "Settings row to view reading tips")
                            .font(.h5Medium)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    Task {
                        await subscriptionManager.restorePurchases()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .frame(width: 32)
                        Text("Restore Purchases", comment: "Restore purchases button")
                            .font(.h5Medium)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(Text("Settings", comment: "Settings screen title"))
        .sheet(isPresented: $showReadingTips) {
            ReadingTipsSheet(isFirstTime: false)
        }
        .fullScreenCover(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(SubscriptionManager.shared)
    }
}
