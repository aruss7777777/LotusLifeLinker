import SwiftUI
import UIKit

// MARK: - Multi-Touch Tracking

struct FingerTouch: Identifiable, Equatable {
    let id: ObjectIdentifier
    var location: CGPoint
}

class MultiTouchTrackingView: UIView {
    var onTouchesChanged: (([FingerTouch]) -> Void)?
    var onTouchLimitWarning: (() -> Void)?
    var onSlowDownWarning: (() -> Void)?
    private var activeTouchIds: [UITouch: ObjectIdentifier] = [:]
    private var cancelResetWorkItem: DispatchWorkItem?
    private var recentTouchStartTimes: [Date] = []
    private var hasShownTouchLimitWarning = false
    private var hasShownSlowDownWarning = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        isExclusiveTouch = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelResetWorkItem?.cancel()
        removeInactiveTouches()
        recordTouchStart(count: touches.count)
        addTouches(touches)
        addLiveTouches(from: event)
        warnIfTouchLimitReached(activeTouchThreshold: 6)
        reportTouches()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        addLiveTouches(from: event)
        reportTouches()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouches(touches)
        addLiveTouches(from: event)
        reportTouches()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        addLiveTouches(from: event)
        if activeTouchIds.count >= 5 {
            warnIfTouchLimitReached(activeTouchThreshold: 5)
        } else {
            warnIfTouchesWereTooFast()
        }
        reportTouches(includingRecentlyCancelled: true)
        scheduleCancelCleanup()
    }

    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        reportTouches()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            cancelResetWorkItem?.cancel()
            activeTouchIds.removeAll()
            onTouchesChanged?([])
        }
    }

    private func addTouches(_ touches: Set<UITouch>) {
        for touch in touches where touch.phase != .ended && touch.phase != .cancelled {
            activeTouchIds[touch, default: ObjectIdentifier(touch)] = ObjectIdentifier(touch)
        }
    }

    private func removeTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            activeTouchIds.removeValue(forKey: touch)
        }
    }

    private func addLiveTouches(from event: UIEvent?) {
        guard let allTouches = event?.allTouches else { return }
        addTouches(allTouches)
    }

    private func recordTouchStart(count: Int) {
        let now = Date()
        recentTouchStartTimes.append(contentsOf: Array(repeating: now, count: count))
        recentTouchStartTimes = recentTouchStartTimes.filter { now.timeIntervalSince($0) <= 0.22 }

        if count >= 4 || recentTouchStartTimes.count >= 4 {
            warnIfTouchesWereTooFast()
        }
    }

    private func warnIfTouchesWereTooFast() {
        guard !hasShownSlowDownWarning else { return }
        hasShownSlowDownWarning = true
        DispatchQueue.main.async { [weak self] in
            self?.onSlowDownWarning?()
        }
    }

    private func warnIfTouchLimitReached(activeTouchThreshold: Int) {
        guard !hasShownTouchLimitWarning, activeTouchIds.count >= activeTouchThreshold else { return }
        hasShownTouchLimitWarning = true
        DispatchQueue.main.async { [weak self] in
            self?.onTouchLimitWarning?()
        }
    }

    private func scheduleCancelCleanup() {
        cancelResetWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.removeInactiveTouches()
            self?.reportTouches()
        }
        cancelResetWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: workItem)
    }

    private func removeInactiveTouches() {
        activeTouchIds = activeTouchIds.filter { touch, _ in
            touch.phase != .ended && touch.phase != .cancelled
        }
    }

    private func reportTouches(includingRecentlyCancelled: Bool = false) {
        let liveTouches = Set(activeTouchIds.keys).filter { touch in
            if includingRecentlyCancelled {
                return touch.phase != .ended
            }
            return touch.phase != .ended && touch.phase != .cancelled
        }
        if !includingRecentlyCancelled {
            activeTouchIds = activeTouchIds.filter { liveTouches.contains($0.key) }
        }

        let fingers = liveTouches.compactMap { touch -> FingerTouch? in
            guard let id = activeTouchIds[touch] else { return nil }
            return FingerTouch(id: id, location: touch.location(in: self))
        }
        .sorted { first, second in
            if first.location.y == second.location.y {
                return first.location.x < second.location.x
            }
            return first.location.y < second.location.y
        }

        onTouchesChanged?(fingers)
    }
}

struct MultiTouchView: UIViewRepresentable {
    @Binding var fingers: [FingerTouch]
    var onTouchLimitWarning: () -> Void
    var onSlowDownWarning: () -> Void

    func makeUIView(context: Context) -> MultiTouchTrackingView {
        let view = MultiTouchTrackingView()
        view.onTouchesChanged = { touches in
            DispatchQueue.main.async {
                self.fingers = touches
            }
        }
        view.onTouchLimitWarning = {
            DispatchQueue.main.async {
                onTouchLimitWarning()
            }
        }
        view.onSlowDownWarning = {
            DispatchQueue.main.async {
                onSlowDownWarning()
            }
        }
        return view
    }

    func updateUIView(_ uiView: MultiTouchTrackingView, context: Context) {
        uiView.onTouchLimitWarning = {
            DispatchQueue.main.async {
                onTouchLimitWarning()
            }
        }
        uiView.onSlowDownWarning = {
            DispatchQueue.main.async {
                onSlowDownWarning()
            }
        }
    }
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
    @State private var stabilityTimer: Timer?
    @State private var countdownTimer: Timer?
    @State private var stableFingerCount: Int = 0
    @State private var stableStartDate: Date?
    @State private var chooserWarningMessage = ""
    @State private var showingChooserWarning = false

    private let requiredStableTime: TimeInterval = 1.0
    private let stabilityCheckInterval: TimeInterval = 0.1
    private let choosingDuration: TimeInterval = 2.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            MultiTouchView(
                fingers: $fingers,
                onTouchLimitWarning: {
                    showWarning("This device only supports five fingers at once")
                },
                onSlowDownWarning: {
                    showWarning("Please place fingers slowly.")
                }
            )
            .ignoresSafeArea()

            // Lotus symbols at each finger
            ForEach(fingers) { finger in
                let isWinner = winnerId == finger.id
                let isEliminated = winnerId != nil && !isWinner

                Image("LotusSymbol")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 76, height: 76)
                    .clipShape(Circle())
                    .scaleEffect(isWinner ? 1.6 : pulseScale)
                    .opacity(isEliminated ? 0.0 : 1.0)
                    .shadow(
                        color: isWinner ? Color(red: 0.85, green: 0.7, blue: 0.25) : .white.opacity(0.4),
                        radius: isWinner ? 20 : 8
                    )
                    .position(finger.location)
                    .allowsHitTesting(false)
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
        .ignoresSafeArea()
        .statusBarHidden(true)
        .alert(chooserWarningMessage, isPresented: $showingChooserWarning) {
            Button("OK", role: .cancel) {}
        }
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

    private func showWarning(_ message: String) {
        chooserWarningMessage = message
        showingChooserWarning = true
    }

    private func handleFingersChanged(_ newFingers: [FingerTouch]) {
        if phase == .chosen {
            guard newFingers.isEmpty else { return }
            resetChoosingState()
            return
        }

        let count = newFingers.count

        guard count >= 2 else {
            resetChoosingState()
            return
        }

        if count != stableFingerCount {
            stableFingerCount = count
            stableStartDate = Date()

            if phase == .countdown {
                phase = .waiting
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
        }

        startStabilityTimerIfNeeded()
    }

    private func startStabilityTimerIfNeeded() {
        guard stabilityTimer == nil else { return }

        let timer = Timer(timeInterval: stabilityCheckInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                updateStableFingerState()
            }
        }
        stabilityTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func updateStableFingerState() {
        guard phase == .waiting else { return }

        guard fingers.count >= 2 else {
            resetChoosingState()
            return
        }

        if stableFingerCount != fingers.count || stableStartDate == nil {
            stableFingerCount = fingers.count
            stableStartDate = Date()
            return
        }

        guard let stableStartDate else { return }
        if Date().timeIntervalSince(stableStartDate) >= requiredStableTime {
            beginCountdown()
        }
    }

    private func beginCountdown() {
        guard phase == .waiting, fingers.count >= 2 else { return }

        phase = .countdown
        stabilityTimer?.invalidate()
        stabilityTimer = nil

        // Speed up the pulse once the chooser is locked in.
        pulseScale = 1.0
        withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }

        countdownTimer?.invalidate()
        let timer = Timer(timeInterval: choosingDuration, repeats: false) { _ in
            DispatchQueue.main.async {
                chooseWinner()
            }
        }
        countdownTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func chooseWinner() {
        guard phase == .countdown else { return }
        guard fingers.count >= 2 else {
            resetChoosingState()
            return
        }

        let winner = fingers.randomElement()!
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            winnerId = winner.id
            phase = .chosen
            pulseScale = 1.0
        }
    }

    private func resetChoosingState() {
        if phase == .countdown || phase == .chosen {
            phase = .waiting
        }
        winnerId = nil
        stableFingerCount = 0
        stableStartDate = nil
        stabilityTimer?.invalidate()
        stabilityTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func cleanup() {
        stabilityTimer?.invalidate()
        stabilityTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

#Preview {
    PlayerChooserView(onDismiss: {})
}
