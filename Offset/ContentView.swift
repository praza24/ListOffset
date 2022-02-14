import SwiftUI

struct ContentView: View {
    @State private var buttonEnabled = false
    @State private var buttonMinY: CGFloat = .zero
    
    var body: some View {
//        NavigationView { buttonMinY not calculated when inside a NavigationView
            VStack(spacing: 0) {
                List {
                    Section(footer: footerView()) {
                        ForEach((0...50), id:\.self) { number in
                            Text("\(number)")
                        }
                    }
                }.listStyle(.insetGrouped)
                    .navigationTitle(Text("Preference Offset"))
                

                Button(action: { print("Enabled")},
                       label: {
                    Text(buttonEnabled ? "Enabled" : "Disabled")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(buttonEnabled ? .blue : .red)
                })
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .frame(width: 0, height: 0, alignment: .top)
                                .onAppear {
                                    buttonMinY = proxy.frame(in: CoordinateSpace.named("list")).minY
                                    print("ButtonMinY: \(buttonMinY)")
                                }
                        }
                    )
            }
            .coordinateSpace(name: "list")
            .onPreferenceChange(OffsetPreferenceKey.self) { invisibleFooter in
                
                // +40 due to extra padding from List
                if invisibleFooter <= buttonMinY + 40, invisibleFooter != 0 {
                    buttonEnabled = true
                }
                print("Footer value is: \(invisibleFooter)")
            }
        //}
    }
}

@ViewBuilder
func footerView() -> some View {
    GeometryReader { proxy in
        Color.clear
            .frame(width: 0, height: 0, alignment: .bottom)
            .preference(key: OffsetPreferenceKey.self,
                        value: proxy.frame(in: CoordinateSpace.named("list")).minY)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
