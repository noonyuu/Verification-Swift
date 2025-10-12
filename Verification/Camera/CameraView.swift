import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?
    @State private var showPreview = false

    var body: some View {
        ZStack {
            if showPreview, let capturedImage = viewModel.capturedImage {
                photoPreview(image: capturedImage)
            } else {
                CameraPreviewView(previewLayer: viewModel.previewLayer)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    if viewModel.isTimerRunning {
                        timerOverlay
                    }

                    controls
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            viewModel.setupCamera()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onChange(of: viewModel.capturedImage) { _, newImage in
            if newImage != nil {
                showPreview = true
            }
        }
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    private func photoPreview(image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 50) {
                    Button {
                        showPreview = false
                        viewModel.capturedImage = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Button {
                        self.image = image
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.green.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }

    private var timerOverlay: some View {
        VStack {
            Text("\(viewModel.timerCount)")
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 10)

            Text("秒後に撮影")
                .font(.title2)
                .foregroundColor(.white)
                .shadow(radius: 5)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }

    private var controls: some View {
        HStack(spacing: 50) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Button {
                if viewModel.isTimerRunning {
                    viewModel.stopTimer()
                } else {
                    viewModel.startTimer()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 70, height: 70)

                    Circle()
                        .fill(viewModel.isTimerRunning ? Color.red : Color.white)
                        .frame(width: 60, height: 60)

                    if viewModel.isTimerRunning {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }

            Button {
                viewModel.capturePhoto()
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }
}
