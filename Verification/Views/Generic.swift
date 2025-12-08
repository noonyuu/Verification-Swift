import SwiftUI

struct GenericView: View {
    @State private var noGenericValue: Bool = false
    
    var body: some View {
        // ジェネリック不使用
        // 型ごとに同じ関数をオーバーロードしないといけない
        HStack(spacing: 0) {
            Button {
                noGenericValue = noGeneric(1, 2)
            } label: {
                Text("比較")
            }
            .padding()
            Text(noGenericValue ? "True" : "False")
        }
    }
}

func noGeneric(_ x: Int, _ y: Int) -> Bool {
    x == y
}

#Preview {
    GenericView()
}
