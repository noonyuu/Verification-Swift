# Grand Central Dispatch

GCD提供するタスク実行キュー
引数を省略すると serialキュー（投げた順に1つずつ実行、並行しない）になる
並行で動かしたければ attributes: .concurrentを指定する必要がある

## なぜGCDを使用するのか

1. メインスレッドを止めないため
   1. case camera
      AVCaptureSession.startRunning() は数百 ms ブロックすることがある
      MainActor で直接呼ぶとUIがカクつくので、別スレッドに逃がす
   2. AVFoundation は「単一スレッドから触る」前提
      Apple のドキュメントは「session の設定変更や start/stop は同じ serial queueから行え」と推奨している
      複数のスレッドから同時に触ると未定義動作。
      serialキューを1本用意して全部そこから呼べば、自然と「同時に触らない」ことが保証される

## 引数

`label: "com.xxx.yyy.camera"`

デバッガ（Xcode の Debug Navigator や Instruments）でこのキューがどれか識別するための名前
慣例でreverse-DNS 形式（バンドル ID + 用途名）にします。実行には影響しない

`qos: .userInitiated`

Quality of Service = OS にこのキューの優先度を伝えるヒント

| QoS              | 想定                                                 |
| ---------------- | ---------------------------------------------------- |
| .userInteractive | フレーム描画など即応必須                             |
| .userInitiated   | ユーザー操作の結果すぐ反応してほしい（数百ms〜数秒） |
| .default         | 明示しない場合                                       |
| .utility         | プログレスバー出る程度の処理                         |
| .background      | バックグラウンド同期など                             |

※ カメラの場合だとシャッターを押した瞬間に処理が始まってほしいので`.userInitiated`
