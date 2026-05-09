# nonisolated

## 隔離（isolation）の前提

@MainActor付き

```swift
@MainActor
@Observable
final class CameraSession {
    var lastCaptured: Shared.RgbColor? // ← 自動で @MainActor 隔離
    var isRunning = false // ← 自動で @MainActor 隔離
}
```

クラス全体に @MainActor を付けると、そのメンバ全部 が暗黙に MainActor隔離になる
これらを触るには MainActor からでないとダメ（バックグラウンドスレッドからは await でhop する必要がある）

## nonisolated の役割

```swift
nonisolated let session = AVCaptureSession()
private nonisolated let photoOutput = AVCapturePhotoOutput()
```

nonisolated を付けると、そのプロパティだけ MainActor 隔離から外れて、どのスレッド/actorからでも直接アクセスできる ようになる

## 例

### CameraSession でこれが必要な理由

1. queue.async { [session, photoOutput] in ... } の中で触りたい
   バックグラウンド queue から MainActor 隔離プロパティを同期で読むのは禁止
   nonisolatedにしておけば、queue から直接 session.startRunning() を呼べる。
2. CameraPreviewView から camera.session を読みたい
   UIViewRepresentable.makeUIView から view.previewLayer.session = session のように渡している
   MainActor経由でしか読めないと取り回しが面倒

## nonisolated と nonisolated(unsafe) の違い

```swift
nonisolated let session = AVCaptureSession() // 普通の nonisolated
nonisolated(unsafe) let session = AVCaptureSession() // unsafe バリアント
```

|                     | 意味                                                                   |
| ------------------- | ---------------------------------------------------------------------- |
| nonisolated         | コンパイラの Sendable チェックは通る前提                               |
| nonisolated(unsafe) | Sendable じゃないけど、私が責任持って安全に扱うから黙って通せ」 と明示 |

まとめ

- クラスに @MainActor → メンバ全部が暗黙に MainActor 隔離
- 例外的に「どこからでも触っていい」ものを nonisolated で逃がす
- Sendable 不適合な型を逃がすときは nonisolated(unsafe) または @preconcurrency import で抑える

session / photoOutput を queue.async から触る必要があるから nonisolated にしている、ということ
