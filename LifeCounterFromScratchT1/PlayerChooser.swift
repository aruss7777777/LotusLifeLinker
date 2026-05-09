import SwiftUI
import UIKit

// MARK: - Multi-Touch Tracking

struct FingerTouch: Identifiable, Equatable {
    let id: ObjectIdentifier
    var location: CGPoint
}

class MultiTouchTrackingView: UIView {
    var onTouchesChanged: (([FingerTouch]) -> Void)?
    private var activeTouches: [UITouch: ObjectIdentifier] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches[touch] = ObjectIdentifier(touch)
        }
        reportTouches()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        reportTouches()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }
        reportTouches()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }
        reportTouches()
    }

    private func reportTouches() {
        let fingers = activeTouches.compactMap { (touch, id) -> FingerTouch? in
            let location = touch.location(in: self)
            return FingerTouch(id: id, location: location)
        }
        onTouchesChanged?(fingers)
    }
}

struct MultiTouchView: UIViewRepresentable {
    @Binding var fingers: [FingerTouch]

    func makeUIView(context: Context) -> MultiTouchTrackingView {
        let view = MultiTouchTrackingView()
        view.onTouchesChanged = { touches in
            DispatchQueue.main.async {
                self.fingers = touches
            }
        }
        return view
    }

    func updateUIView(_ uiView: MultiTouchTrackingView, context: Context) {}
}

// MARK: - Player Chooser View

enum ChooserPhase {
    case waiting       // "Place your fingers"
    case countdown     // Fingers are down, pulsing
    case chosen        // Winner selected
}

struct PlayerChooserView: View {
    var onDismiss: () -> Void

    @State private var fingers: [FingerTouch] = []
    @State private var phase: ChooserPhase = .waiting
    @State private var winnerId: ObjectIdentifier?
    @State private var pulseScale: CGFloat = 1.0
    @State private var countdownTimer: Timer?
    @State private var stableFingerCount: Int = 0
    @State private var stableStartDate: Date?

    private let requiredStableTime: TimeInterval = 1.5
    private let choosingDuration: TimeInterval = 2.5

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            MultiTouchView(fingers: $fingers)
                .ignoresSafeArea()

            // Lotus symbols at each finger
            ForEach(fingers) { finger in
                let isWinner = winnerId == finger.id
                let isEliminated = winnerId != nil && !isWinner

                Image("LotusSymbol")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .scaleEffect(isWinner ? 1.6 : pulseScale)
                    .opacity(isEliminated ? 0.0 : 1.0)
                    .shadow(
                        color: isWinner ? Color(red: 0.85, green: 0.7, blue: 0.25) : .white.opacity(0.4),
                        radius: isWinner ? 20 : 8
                    )
                    .position(finger.location)
                    .animation(.easeInOut(duration: 0.4), value: isWinner)
                    .animation(.easeInOut(duration: 0.5), value: isEliminated)
            }

            // Instruction text
            VStack {
                if phase == .waiting {
                    Text("Place your fingers")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .transition(.opacity)
                } else if phase == .countdown {
                    Text("Choosing...")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .transition(.opacity)
                } else if phase == .chosen {
                    Text("Chosen!")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.85, green: 0.7, blue: 0.25))
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.top, 60)
            .animation(.easeInOut, value: phase)
            .allowsHitTesting(false)

            // Close button
            if phase == .waiting || phase == .chosen {
                VStack {
                    Spacer()
                    Button {
                        cleanup()
                        onDismiss()
                    } label: {
                        Text(phase == .chosen ? "Done" : "Cancel")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .statusBarHidden(true)
        .onChange(of: fingers) { _, newFingers in
            handleFingersChanged(newFingers)
        }
        .onAppear {
            startPulse()
        }
        .onDisappear {
            cleanup()
        }
    }

    private func startPulse() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
    }

    private func handleFingersChanged(_ newFingers: [FingerTouch]) {
        guard phase != .chosen else { return }

        let count = newFingers.count

        if count < 2 {
            // Not enough fingers, reset
            if phase == .countdown {
                phase = .waiting
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
            stableFingerCount = 0
            stableStartDate = nil
            return
        }

        // Check if finger count changed
        if count != stableFingerCount {
            stableFingerCount = count
            stableStartDate = Date()

            if phase == .countdown {
                phase = .waiting
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
        }

        // Check if fingers have been stable long enough
        guard let startDate = stableStartDate else { return }
        let stableTime = Date().timeIntervalSince(startDate)

        if stableTime >= requiredStableTime && phase == .waiting {
            beginCountdown()
        }
    }

    private func beginCountdown() {
        phase = .countdown

        // Speed up the pulse
        pulseScale = 1.0
        withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }

        countdownTimer = Timer.scheduledTimer(withTimeInterval: choosingDuration, repeats: false) { _ in
            DispatchQueue.main.async {
                chooseWinner()
            }
        }
    }

    private func chooseWinner() {
        guard !fingers.isEmpty else {
            phase = .waiting
            return
        }

        let winner = fingers.randomElement()!
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            winnerId = winner.id
            phase = .chosen
            pulseScale = 1.0
        }
    }

    private func cleanup() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

#Preview {
    PlayerChooserView(onDismiss: {})
}
