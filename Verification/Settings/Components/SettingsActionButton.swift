import SwiftUI

struct SettingsActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(Color.red)
                    .font(.system(size: 24))
                    .padding(.leading, 20)

                Text(title)
                    .font(.system(size: 16, weight: .thin))
                    .foregroundColor(.red)

                Spacer()
            }
            .padding(.horizontal, 36)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color("button"))
            )
        }
    }
}
