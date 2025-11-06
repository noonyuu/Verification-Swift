import SwiftUI

struct WillSetDidSet: View {
    @State var new: String = "newValue"
    @State var old: String = "oldValue"
    @State var value: Int = 0 {
        willSet {
            new = "\(newValue)"
            print("Will set value to \(new)")
        }
        didSet {
            old = "\(oldValue)"
            print("Did set value from \(old) to \(value)")
        }
    }
    var body: some View {
        VStack {
            Text("Current value: \(value)")
            Button("Increment Value") {
                value += 1
            }

            Text("New value will be: \(new)")
            Text("Old value was: \(old)")
        }
    }
}

#Preview {
    WillSetDidSet()
}
