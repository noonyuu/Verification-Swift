import SwiftUI

struct SettingsUserInfoSection: View {
    let userName: String
    let iconName: String

    var body: some View {
        HStack(spacing: 16) {
            Image(iconName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 28))

            Text(userName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal, 36)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color("button"))
        )
    }
}
