# Swift 設計パターン（DI / シングルトン）

## DIの書き方

```swift
private let friendAPI: any FriendAPIServiceProtocol

init(friendAPI: any FriendAPIServiceProtocol = FriendAPIService.shared) {
    self.friendAPI = friendAPI
    self.friends = []
}
```

1. private let friendAPI: any FriendAPIServiceProtocol

   プロトコル型のプロパティ宣言

   `private let friendAPI: any FriendAPIServiceProtocol`

   | 部分                         | 意味                                                         |
   | ---------------------------- | ------------------------------------------------------------ |
   | private                      | このクラス内からのみアクセス可                               |
   | let                          | 一度代入したら変更不可                                       |
   | friendAPI                    | プロパティ名                                                 |
   | any FriendAPIServiceProtocol | 「FriendAPIServiceProtocol」に準拠した何らかの型という存在型 |

   具象クラスFriendAPIServiceではなく、プロトコルFriendAPIServiceProtocolであること
   これによりVMは「中身が誰なのか」を知らずに API を叩けます。

2. anyキーワードの意味

   `any FriendAPIServiceProtocol`
   - 存在型(existential type)の明示構文
   - 「FriendAPIServiceProtocol に準拠する何らかの型のインスタンス」

3. init(friendAPI: any FriendAPIServiceProtocol = FriendAPIService.shared)

   デフォルト引数つきイニシャライザ

   ```swift
   init(friendAPI: any FriendAPIServiceProtocol = FriendAPIService.shared) {
    self.friendAPI = friendAPI
    self.friends = []
   }
   ```

   構造を分解

   ```swift
   init(
   friendAPI: any FriendAPIServiceProtocol // ← 引数の型
   = FriendAPIService.shared // ← デフォルト値
   )

   ```

   | 部分                       | 意味                                                         |
   | -------------------------- | ------------------------------------------------------------ |
   | 本番では引数省略で簡潔     | FriendListViewModel()だけでシングルトン実装が刺さる          |
   | テストでモック差し替え可能 | FriendListViewModel(friendAPI: モック)でユニットテストできる |
   | VM は具象クラスを知らない  | FriendAPIServiceが変わってもVMは影響を受けにくい             |
   | イミュータブル             | letなので途中でAPI実装が差し替わる事故が起きない             |

---

1行ずつの“読み下し”

private let friendAPI: any FriendAPIServiceProtocol
// 「FriendAPIServiceProtocol を満たす何らかのオブジェクトを、
// 外には見せず、初期化以降変更不可で保持する」

init(friendAPI: any FriendAPIServiceProtocol = FriendAPIService.shared) {
// 「初期化時に friendAPI を受け取る。省略されたら FriendAPIService.shared を使う」

self.friendAPI = friendAPI
self.friends = []

// 「受け取った API を保持し、friends を空にして開始する」
}

---

## シングルトン + クラス継承の書き方

```swift
class FriendAPIService: APIServiceBase {
    static let shared = FriendAPIService()

    private override init() {
        super.init()
    }
}
```

これは「シングルトンパターン」+「クラス継承」の典型的な書き方。3要素に分解する。

### 1. `class FriendAPIService: APIServiceBase`

クラス継承の宣言。

| 部分                     | 意味                                        |
| ------------------------ | ------------------------------------------- |
| `class FriendAPIService` | `FriendAPIService` という名前のクラスを定義 |
| `: APIServiceBase`       | `APIServiceBase` を親クラスとして継承       |

`APIServiceBase` は別ファイルにある「API クライアントの共通基盤クラス」。たとえば:

- `URLSession` の保持
- 認証トークンの付与
- 共通エラーハンドリング
- JSON のデコード

…といった「全 API サービスで共通する処理」を持っており、`FriendAPIService` はその上に「フレンド固有の API メソッド」を実装するという構図。

#### 親子関係のイメージ

```
APIServiceBase           ← 親クラス（共通機能）
  └── FriendAPIService   ← 子クラス（フレンド機能を追加）
  └── GroupAPIService    ← 同じく親を継承（別のサービス）
  └── UserAPIService
```

各サービスが共通の土台を継承することで、HTTP 通信ロジックを重複させずに済む。

### 2. `static let shared = FriendAPIService()`

シングルトンの宣言。

| 部分                   | 意味                                                      |
| ---------------------- | --------------------------------------------------------- |
| `static`               | インスタンスではなく**クラスそのものに紐づく**プロパティ  |
| `let`                  | 一度作ったら変更不可（再代入禁止）                        |
| `shared`               | プロパティ名（Swift 慣習でシングルトンは `shared`）       |
| `= FriendAPIService()` | 初期値として `FriendAPIService` のインスタンスを 1 つ生成 |

#### 実行時の挙動

アプリ起動後、初めて `FriendAPIService.shared` にアクセスされた瞬間に **1 回だけ** `FriendAPIService()` が呼ばれてインスタンスが作られる（Swift の `static let` は遅延初期化 + スレッドセーフ）。以降は何度アクセスしても同じインスタンスが返る。

```swift
let a = FriendAPIService.shared
let b = FriendAPIService.shared
// a と b は同じ実体（=== で比較すると true）
```

#### なぜシングルトン？

API クライアントは:

- 認証トークンや `URLSession` を内部で保持している
- 毎回作り直すとキャッシュや状態が失われる
- 複数箇所から同じ実体を使い回したい

ためアプリ全体で 1 つだけ存在させるのが自然。

### 3. `private override init() { super.init() }`

外部からの new 禁止 + 親の init 呼び出し。

```swift
private override init() {
    super.init()
}
```

3つの要素が組み合わさっている。

#### (a) `private`

通常 Swift のクラスは `let api = FriendAPIService()` のように外から自由にインスタンス化できる。

`init` を `private` にすると…

```swift
let api = FriendAPIService()  // ❌ コンパイルエラー: init は private
```

外部からは作れなくなる。`shared` 経由でしかアクセスできないようにしてシングルトンを強制するのが狙い。

#### (b) `override`

親クラス `APIServiceBase` がすでに `init()` を持っているため、子クラスでそれを上書きするには `override` を付ける必要がある（Swift のルール）。

つまり `APIServiceBase` 側にこういう init が存在しているはず:

```swift
class APIServiceBase {
    init() {
        // URLSession の準備など共通の初期化処理
    }
}
```

#### (c) `super.init()`

親クラスの初期化処理を明示的に呼び出す。これがないと:

- 親が持っているプロパティ（URLSession 等）の初期化が走らない
- そもそも Swift のコンパイラがエラーを出す（指定イニシャライザの規則）

`super.init()` を呼ぶことで「親の初期化 → 自分の初期化」という正しい順序が保証される。

### このパターンが嬉しい理由

| メリット                        | 内容                                                                    |
| ------------------------------- | ----------------------------------------------------------------------- |
| アプリ全体で同じ状態を共有      | 認証トークンなどが 1 箇所に集約される                                   |
| 誤って複数生成する事故を防げる  | `private init` で外部からの new を禁止                                  |
| 使う側が簡潔                    | `FriendAPIService.shared.getFriends(...)` だけで済む                    |
| 共通処理の重複を防げる          | 親クラス継承で HTTP 周りを使い回せる                                    |
| VM 側のデフォルト引数と相性良し | `init(friendAPI: ... = FriendAPIService.shared)` のようにそのまま流せる |

### 全体の流れ（VM のコードと繋げると）

```swift
// ① シングルトンが 1 つだけ作られる（最初のアクセス時）
FriendAPIService.shared

// ② VM の init で「省略時は shared を使う」と書いてある
init(friendAPI: any FriendAPIServiceProtocol = FriendAPIService.shared) { ... }

// ③ 結果、本番では:
let vm = FriendListViewModel()  // ← shared が刺さる

// ④ テストでは:
let vm = FriendListViewModel(friendAPI: MockFriendAPIService())  // ← モックを刺せる
```

この `shared` と `private init` のセットが、VM 側のデフォルト引数と組み合わさって「本番ではシングルトン、テストではモック」という運用を実現している。

### 一行でまとめると

> 親クラスを継承した API サービスを、外からは作れない形でシングルトン化している。

---
