import Foundation
import SwiftUI

struct StructFunc: View {
    // インスタンス化
    let increment: StructFuncSample = StructFuncSample(value: "struct")
    @State private var value: String = ""

    let restaurant: Restaurant = Restaurant()
    @State private var order: Order = Order(items: [], quantity: 0)
    @State private var dish: (any OrderAcceptable)?

    init() {
        StaticCounter.count = 10
    }

    var body: some View {
        Button {
            // 複数のメソッドで同じvalueを使い回せる
            value = increment.incrementedValue()
        } label: {
            Text("struct")
        }
        .padding()
        Button {
            // 毎回引数で値を渡す必要がある
            // 名前空間の汚染
            value = decrementedValue(value: "func")
        } label: {
            Text("func")
        }
        .padding()
        Text("値: \(value)")

        Text("------static var------")
            .padding()

        Group {
            let person1 = StructPerson(name: "Alice")
            let person2 = StructPerson(name: "Bob")
            Text("Person 1: \(person1.name)")
            Text("Person 2: \(person2.name)")
                .padding()
        }

        // インスタンス化しなくてもアクセス可能 :8で値をsetしている(しなかったら初期値の0)
        Text("Static Count: \(StaticCounter.count)")

        Text("------応用------")
            .padding()

        Button {
            order = Order(items: ["チキン", "サラダ"], quantity: 1)
            dish = restaurant.acceptOrder(type: Dish.self, order: order)
        } label: {
            Text("注文個数1個")
        }
        .padding()
        Button {
            order = Order(items: ["チキン", "サラダ"], quantity: 2)
            dish = restaurant.acceptOrder(type: Dish.self, order: order)
        } label: {
            Text("注文個数2個")
        }
        .padding()
        Button {
            order = Order(items: ["チキン", "サラダ"], quantity: 2)
            dish = restaurant.acceptOrder(type: Pasta.self, order: order)
        } label: {
            Text("パスタを注文")
        }
        .padding()

        if let dish {
            Text("注文された料理の材料: \(dish.ingredients.joined(separator: ", "))")
            Text("料理が正常に注文されました。")
        }
    }
}

struct StructFuncSample {
    let value: String

    // 機能(メソッド)
    func incrementedValue() -> String {
        return self.value
    }
}

func decrementedValue(value: String) -> String {
    return value
}

// Mark: static var
struct StructPerson {
    let name: String
}

struct StaticCounter {
    static var count: Int = 0
}

// Mark: 応用例
// プロトコル定義(レストランのルール)
protocol OrderAcceptable {
    static var orderRepresentation: OrderRepresentation<Self> { get }
    var ingredients: [String] { get }
}

// 注文表現(注文の受け方)
struct OrderRepresentation<T> {
    let handler: (Order) -> T

    init(handler: @escaping (Order) -> T) {
        self.handler = handler
    }
}

// 注文データ
struct Order {
    let items: [String]
    let quantity: Int
}

// 料理(実際のデータ構造)
struct Dish: OrderAcceptable {
    // データ(材料)
    let ingredients: [String]

    // 注文の受け方の定義(static = お店全体のルール)
    static var orderRepresentation: OrderRepresentation<Dish> {
        OrderRepresentation { order in
            switch order.quantity {
            case 1:
                // 注文内容に基づいて料理を作成
                return Dish(ingredients: order.items)
            case 2:
                // 注文内容に基づいて料理を作成
                return Dish(ingredients: order.items + order.items)
            default:
                // デフォルトの料理
                return Dish(ingredients: ["水"])
            }
        }
    }
}

struct Pasta: OrderAcceptable {
    let ingredients: [String]

    // コンストラクタ
    init(ingredients: [String]) {
        self.ingredients = ["パスタをおまけします\n"] + ingredients
    }

    static var orderRepresentation: OrderRepresentation<Pasta> {
        OrderRepresentation { order in
            Pasta(ingredients: order.items + ["パスタ"])
        }
    }
}

// レストランシステム
struct Restaurant {
    func acceptOrder<T: OrderAcceptable>(type: T.Type, order: Order) -> T? {
        let representation: OrderRepresentation<T> = T.orderRepresentation
        return representation.handler(order)
    }
}

#Preview {
    StructFunc()
}
