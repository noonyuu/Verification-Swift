// 参考: https://qiita.com/imchino/items/d9b0ed48af8658f34d92

import SwiftUI

struct AsyncAwait: View {
    @State var opacity = 1.0
    @State var isTapped = false   // 非同期的なボタンが押されたかどうか
    
    var body: some View {
        VStack {
            // 非同期ボタンが押されると、色が変わるテキスト
            Text("Hello")
                .foregroundColor(isTapped ? .red : .black)
                .font(.system(size: 65))
                .fontWeight(.bold)
                .opacity(opacity)

            Slider(value: $opacity, in: 0...1) {
                Text("Opacity")
            }
            .padding()

            // 同期的に5秒を数えるボタン
            Button {
                sleep(5)
            } label: {
                Text("Count")
                    .frame(maxWidth: 180, maxHeight: 66)
            }
            .buttonStyle(.bordered)
            
            // 非同期的に5秒を数えるボタン
            Button {
                // 非同期的なタスクを作成する
                Task {
                    // タスクの中は非同期的なコンテキストなので、
                    // 非同期関数を呼び出せる
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    isTapped.toggle()
                }
            } label: {
                Text("Async count")
                    .frame(maxWidth: 180, maxHeight: 66)
            }
            .buttonStyle(.bordered)
            
        }
    }
}

#Preview {
    AsyncAwait()
}
