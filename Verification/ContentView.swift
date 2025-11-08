import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var capturedImage: UIImage?

    var body: some View {
        VStack {
            NavigationStack {
                NavigationLink("機能など", destination: function)
                NavigationLink("構文周り", destination: syntax)
            }
        }
    }

    var function: some View {
        VStack {
            NavigationStack {
                NavigationLink("カメラ", destination: CameraView(image: $capturedImage))
                NavigationLink("シート", destination: SettingsSheetView())
            }
        }
    }

    var syntax: some View {
        VStack {
            NavigationStack {
                NavigationLink("willSet/didSet", destination: WillSetDidSet())
                NavigationLink("StructとFuncの違い", destination: StructFunc())
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
