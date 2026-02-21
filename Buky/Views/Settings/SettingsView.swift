import SwiftUI

struct SettingsView: View {

    @Environment(\.colorScheme) var colorScheme
    @State private var showReadingTips = false

    var body: some View {
        List {
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
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
