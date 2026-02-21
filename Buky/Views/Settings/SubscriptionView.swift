import SwiftUI

struct SubscriptionView: View {

    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var isDarkMode: Bool { colorScheme == .dark }

    var body: some View {
        ZStack {
            // Background gradient matching MenuView first button
            LinearGradient(
                colors: [.tertiaryBrand, .cuarterlyBrand],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(Color.black.opacity(isDarkMode ? 0.35 : 0))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        plansSection
                        featuresSection
                    }
                    .padding()
                }

                subscribeButton
                    .padding()
                    .background(Color.cuarterlyBrand)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let msg = viewModel.errorMessage {
                Text(msg)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

            Text("Buky Premium", comment: "Subscription paywall title")
                .font(.h2Bold)
                .foregroundStyle(.white)

            Text("Unlock the full magic of storytelling", comment: "Subscription paywall subtitle")
                .font(.h5Medium)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    // MARK: - Plans

    private var plansSection: some View {
        HStack(spacing: 12) {
            if let monthly = viewModel.monthlyProduct {
                PlanCardView(
                    product: monthly,
                    selectedProductID: $viewModel.selectedProductID
                )
            }
            if let yearly = viewModel.yearlyProduct {
                PlanCardView(
                    product: yearly,
                    selectedProductID: $viewModel.selectedProductID
                )
            }
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            featureRow(
                title: String(localized: "120 Stories a Month", comment: "Feature: stories per month"),
                subtitle: String(localized: "Because \"one more story, please?\" should never go unanswered.", comment: "Feature description: stories")
            )
            featureRow(
                title: String(localized: "More Animals", comment: "Feature: more animals"),
                subtitle: String(localized: "New characters to fall in love with, sparking wonder and empathy in every little heart.", comment: "Feature description: animals")
            )
            featureRow(
                title: String(localized: "More Places", comment: "Feature: more places"),
                subtitle: String(localized: "Worlds that ignite their imagination and remind them that anything is possible.", comment: "Feature description: places")
            )
            featureRow(
                title: String(localized: "More Emotions", comment: "Feature: more emotions"),
                subtitle: String(localized: "Stories that help them feel seen, understood, and never alone in what they feel.", comment: "Feature description: emotions")
            )
            featureRow(
                title: String(localized: "Moralejas", comment: "Feature: moralejas"),
                subtitle: String(localized: "Gentle lessons that stay with them long after the lights go out.", comment: "Feature description: moralejas")
            )
            featureRow(
                title: String(localized: "Save & Revisit", comment: "Feature: save and revisit"),
                subtitle: String(localized: "The stories that make their eyes light up, always within reach, always ready to be told again.", comment: "Feature description: save")
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }

    private func featureRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.yellow)
                .frame(width: 28, alignment: .center)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bodySemiBold)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.captionRegular)
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical)
    }

    // MARK: - Actions

    private var subscribeButton: some View {
        Button {
            Task {
                await viewModel.purchase()
                if viewModel.isSubscribed {
                    dismiss()
                }
            }
        } label: {
            Group {
                if viewModel.isPurchasing {
                    ProgressView()
                        .tint(Color.cuarterlyBrand)
                } else {
                    Text("Subscribe Now", comment: "Subscribe button label")
                        .font(.h4SemiBold)
                }
            }
            .foregroundStyle(viewModel.hasSelection ? Color.cuarterlyBrand : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.hasSelection ? .white : .white.opacity(0.15))
            )
        }
        .disabled(!viewModel.hasSelection || viewModel.isPurchasing)
        .buttonStyle(.plain)
    }

}

#Preview {
    SubscriptionView()
}
