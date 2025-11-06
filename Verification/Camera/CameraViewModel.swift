import AVFoundation
import Combine
import SwiftUI

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?  // 撮影した画像
    @Published var isTimerRunning = false  // タイマー実行中フラグ
    @Published var timerCount = 5  // カウントダウン数（5秒）
    @Published var showError = false  // エラー表示フラグ
    @Published var errorMessage = ""  // エラーメッセージ

    private let captureSession = AVCaptureSession()  // カメラセッション
    private var photoOutput = AVCapturePhotoOutput()  // 写真出力
    private var timer: Timer?  // タイマーオブジェクト
    // カメラのプレビューを表示するためのレイヤー, lazyにより初回アクセス時に初期化
    private(set) lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    // カメラのセットアップ
    func setupCamera() {
        checkPermissions()
    }

    // カメラの権限確認
    private func checkPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            configureCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted, let self = self else { return }
                Task { @MainActor [weak self] in
                    self?.configureCaptureSession()
                }
            }
        case .denied, .restricted:
            showError = true
            errorMessage = "カメラへのアクセスが拒否されています。設定アプリで許可してください。"
        @unknown default:
            break
        }
    }

    // カメラセッションの設定を行う
    private func configureCaptureSession() {
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self = self else { return }

            // セッションの設定開始
            self.captureSession.beginConfiguration()
            // 写真撮影プリセットの設定
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            // 背面カメラの取得
            guard
                let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back)
            else {
                self.showError = true
                self.errorMessage = "カメラデバイスが見つかりません"
                return
            }
            // オートフォーカス・露出の設定
            do {
                try camera.lockForConfiguration()
                if camera.isFocusModeSupported(.continuousAutoFocus) {
                    camera.focusMode = .continuousAutoFocus
                }
                if camera.isExposureModeSupported(.continuousAutoExposure) {
                    camera.exposureMode = .continuousAutoExposure
                }
                camera.unlockForConfiguration()
            } catch {
                self.showError = true
                self.errorMessage = "カメラの設定に失敗しました"
            }
            // 入力デバイスの作成
            guard let input = try? AVCaptureDeviceInput(device: camera) else {
                self.showError = true
                self.errorMessage = "カメラ入力の作成に失敗しました"
                return
            }
            // 入力デバイスの追加
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            // 出力デバイスの追加
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            // 設定のコミットとセッションの開始
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }

    // タイマー関数
    func startTimer() {
        isTimerRunning = true
        timerCount = 5

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.timerCount > 0 {
                    self.timerCount -= 1
                } else {
                    self.stopTimer()
                    self.capturePhoto()
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        timerCount = 5
    }

    // 実際の撮影を行う
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    // カメラセッションの停止
    func stopSession() {
        if captureSession.isRunning {
            Task {
                captureSession.stopRunning()
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    // nonisolatedにすることで、非同期コンテキストから呼び出されても問題ないようにする
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            Task { @MainActor in
                self.showError = true
                self.errorMessage = "撮影に失敗しました: \(error.localizedDescription)"
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData)
        else {
            Task { @MainActor in
                self.showError = true
                self.errorMessage = "画像の変換に失敗しました"
            }
            return
        }

        Task { @MainActor in
            self.capturedImage = image
        }
    }
}
