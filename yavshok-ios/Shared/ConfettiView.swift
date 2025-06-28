import SwiftUI

// MARK: - Custom Confetti Animation for iOS 15+
struct ConfettiView: View {
    @State private var animate = false
    @State private var xSpeed = Double.random(in: 0.7...2)
    @State private var zSpeed = Double.random(in: 1...2)
    @State private var anchor = CGFloat.random(in: 0...1).rounded()
    
    var body: some View {
        Rectangle()
            .fill([Color.orange, Color.green, Color.blue, Color.red, Color.yellow, Color.purple].randomElement() ?? Color.green)
            .frame(width: 20, height: 20)
            .onAppear(perform: { animate = true })
            .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 1, y: 0, z: 0))
            .animation(Animation.linear(duration: xSpeed).repeatForever(autoreverses: false), value: animate)
            .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 0, y: 0, z: 1), anchor: UnitPoint(x: anchor, y: anchor))
            .animation(Animation.linear(duration: zSpeed).repeatForever(autoreverses: false), value: animate)
    }
}

// MARK: - Confetti Container
struct ConfettiContainerView: View {
    var count: Int = 50
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { _ in
                ConfettiView()
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? CGFloat.random(in: -50...UIScreen.main.bounds.height) : -50
                    )
                    .opacity(animate ? Double.random(in: 0.4...1.0) : 0)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                animate = true
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

// MARK: - Confetti Display Modifier
struct DisplayConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    @State private var opacity = 1.0
    
    private let animationTime = 3.0
    private let fadeTime = 2.0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                isActive ? 
                ConfettiContainerView()
                    .opacity(opacity)
                    .allowsHitTesting(false)
                : nil
            )
            .onChange(of: isActive) { newValue in
                if newValue {
                    opacity = 1.0
                    handleAnimationSequence()
                }
            }
    }
    
    private func handleAnimationSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
            withAnimation(.easeOut(duration: fadeTime)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeTime) {
                isActive = false
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func displayConfetti(isActive: Binding<Bool>) -> some View {
        self.modifier(DisplayConfettiModifier(isActive: isActive))
    }
} 