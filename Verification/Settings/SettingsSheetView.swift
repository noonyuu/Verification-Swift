import SwiftUI

struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isNotificationEnabled = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sub
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 56) {
                        userInfoSection
                        notificationSection

                        Spacer()
                            .frame(height: 212)

                        accountActionsSection
                    }
                    .padding(.horizontal, 16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("設定")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var userInfoSection: some View {
        SettingsUserInfoSection(
            userName: "noonyuu",
            iconName: "collage-icon"
        )
    }

    private var notificationSection: some View {
        SettingsNotificationSection(isEnabled: $isNotificationEnabled)
    }

    private var accountActionsSection: some View {
        VStack(spacing: 16) {
            SettingsActionButton(
                icon: "rectangle.portrait.and.arrow.right",
                title: "ログアウト",
                action: {
                    // ログアウト処理
                }
            )

            SettingsActionButton(
                icon: "trash",
                title: "アカウント削除",
                action: {
                    // アカウント削除処理
                }
            )
        }
    }
}

#Preview {
    SettingsSheetView()
}
