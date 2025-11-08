import SwiftUI

struct CustomBindingView: View {
    // 通常のState変数
    @State private var isPresented: Bool = false
    // オプショナルBinding変数
    @State private var viewModel: CustomBindingViewModel?

    var body: some View {
        VStack {
            Button("Show Sheet") {
                isPresented = true
            }
            // $を使用してBindingを作成
            .sheet(isPresented: $isPresented) {
                Text("Hello, World!")
            }
        }
        // ViewModelを使用したBinding
        Group {
            if let viewModel: CustomBindingViewModel = viewModel {
                VStack {
                    Toggle(
                        "Show Sheet",
                        isOn: Binding(
                            get: { viewModel.isPresented },
                            set: { viewModel.isPresented = $0 }
                        )
                    )
                    .padding()
                    .sheet(
                        isPresented: Binding(
                            get: { viewModel.isPresented },
                            set: { viewModel.isPresented = $0 }
                        )
                    ) {
                        Text("Hello from ViewModel Sheet!")
                    }
                }
            } else {
                ProgressView()
            }
        }
        // ViewModelの初期化
        .onAppear {
            if viewModel == nil {
                let vm: CustomBindingViewModel = CustomBindingViewModel()
                viewModel = vm
            }
        }
    }
}

#Preview {
    CustomBindingView()
}
