# AnyObject

AnyObjectはクラス(参照型)であることを意味する

## 基本

Swiftの型は大きく2種類

| 種類   | 例          | 特徴                         |
| ------ | ----------- | ---------------------------- |
| 値型   | struct,enum | 代入・引数渡しでコピーされる |
| 参照型 | class       | 同じ実態を共有する           |

AnyObjectはこの型は参照型に限るという制約を表す

`class Cat {}`
`struct Dog {}`

`let a: AnyObject = Cat() // OK`
`let b: AnyObject = Dog() // コンパイルエラー: structはAnyObjectではない`

## Protocol Foo: AnyObject の意味

```swift
protocol FriendApiServiceProtocol: AnyObject {
  ...
}
```

これは「このプロトコルに準拠できるのはclassのみ」という制約をつけている
structやenumではこのプロトコルに準拠できない

class 限定にする必要性

1. weekを使える
   week参照はclassにしか使えない
   VMやマネージャ系でAPIサービスをweekで持って循環参照を避けたい場合プロトコル型のプロパティにweekをつける必要がある

   ```swift
   // ANyObject制約があるからこう書ける
   week var apiService: FriendAPIServiceProtocol?
   ```

   AnyObject制約がないとコンパイラは「このプロトコルはstructも準拠できるかも」と考えるためweekを許可しない

2. 同一性(identity)の比較ができる

   === 演算子はclassインスタンス同士でしか使えない
   `if serviceA === serviceB {...}`// 同じ実体か

3. ミュータブルな共有状態の意図を明示する
   - APIサービスのようなシングルトン的にあちこちで共有して、内部でキャッシュや認証トークンを保持するものは参照型である方が自然

   - AnyObjectはその意図をプロトコル側で宣言する
