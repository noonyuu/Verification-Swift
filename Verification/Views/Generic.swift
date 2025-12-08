import SwiftUI

struct GenericView: View {
    @State private var noGenericValue: Bool = false
    @State private var genericValue: Bool = false
    
    var body: some View {
        // ジェネリック不使用
        // 型ごとに同じ関数をオーバーロードしないといけない
        HStack(spacing: 0) {
            Button {
                noGenericValue = noGeneric(1, 2)
            } label: {
                Text("ジェネリック不使用:比較")
            }
            .padding()
            Text(noGenericValue ? "True" : "False")
        }
        HStack(spacing: 0) {
            Button {
                genericValue = generic("1", "1")
            } label: {
                Text("ジェネリック使用:比較")
            }
            .padding()
            Text(genericValue ? "True" : "False")
        }
    }
}

func noGeneric(_ x: Int, _ y: Int) -> Bool {
    x == y
}

// <T: Equatable> → Equatableに準拠するすべての型
func generic<T: Equatable>(_ x: T, _ y: T) -> Bool {
    x == y
}

#Preview {
    GenericView()
}
