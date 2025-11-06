import SwiftUI

struct SettingsNotificationSection: View {
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "bell.fill")
                .font(.system(size: 24))
                .foregroundColor(.cyan)
                .padding(.leading, 12)

            Text("通知")
                .font(.system(size: 16, weight: .thin))
                .foregroundColor(.primary)

            Spacer()

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(.horizontal, 36)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("button"))
        )
    }
}
