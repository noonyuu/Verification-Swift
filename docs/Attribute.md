# アトリビュート

- [アトリビュート](#アトリビュート)
  - [@discardableResult](#discardableresult)

## @discardableResult

戻り値を捨てても警告を出さない
通常Swiftは戻り値があるのにそれを使わない呼び出しに対して警告を出す
「成功したかどうかだけみたい」「副作用だけ欲しい」というケースで戻り値を捨てたい時に使用

```swift
@discardableResult
func performLoading<T>(...) async -> T? { ... }
```

```swift
// 戻り値を使わないと警告
performLoading(...) // ⚠️  Result of call is unused
```

`@discardableResult`を付けると

```swift
performLoading(...) // ✅ 警告なし
let result = await performLoading(...) // ✅ 受け取ってもよい
```
