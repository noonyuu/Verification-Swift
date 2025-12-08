import SwiftUI

struct GenericView: View {
    @State private var noGenericValue: Bool = false
    @State private var genericValue: Bool = false
    @State private var mixGenericResult: String = ""
    
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
        HStack(spacing: 0) {
            Button {
                let result = otherOne(1, "2", 1)
                mixGenericResult = "結果: \(result.0) : \(type(of: result.0)), \(result.1) : \(type(of: result.1)), \(String(describing: result.2)): \(type(of: result.2))"
            } label: {
                Text("ジェネリック混合:実行")
            }
            .padding()
            Text(mixGenericResult)
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

// 型引数として宣言された型は通常の型と同じように扱える
// ジェネリック関数の戻り値の型としても使用できる
func otherOne<T, U>(_ x: T, _ y: U, _ z: T) -> (T, U, T?) {
    let a: T = x        // 型アノテーション
    let b = y           // 型推論
    let c = z           // 型のキャスト
    
    return (a, b, c)
}

#Preview {
    GenericView()
}
