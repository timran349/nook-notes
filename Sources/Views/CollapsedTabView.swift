import SwiftUI
import AppKit

public struct CollapsedTabView: View {
    @ObservedObject var windowManager: WindowManager
    @State private var isPressed: Bool = false

    public init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }

    public var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.82)) {
                        windowManager.expandPanel()
                    }
                }) {
                    HStack(spacing: 6) {
                        // Animated pill indicator bar
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: windowManager.isHovered
                                        ? [Color.accentColor, Color.primary.opacity(0.85)]
                                        : [Color.primary.opacity(0.4), Color.primary.opacity(0.25)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: windowManager.isHovered ? 16 : 12, height: 3.5)
                            .scaleEffect(windowManager.isHovered ? 1.05 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: windowManager.isHovered)

                        if windowManager.isHovered {
                            Text("Nook")
                                .font(.geist(10, weight: .semibold))
                                .foregroundColor(Color.primary.opacity(0.9))
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal, 11)
                    .frame(height: windowManager.isHovered ? 24 : 14)
                    .background(
                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow, state: .active)
                            .overlay(
                                Color.primary.opacity(windowManager.isHovered ? 0.1 : 0.04)
                            )
                    )
                    .clipShape(
                        CustomCornerShape(corners: [.topRight], radius: 8)
                    )
                    .overlay(
                        CustomCornerShape(corners: [.topRight], radius: 8)
                            .stroke(
                                windowManager.isHovered
                                    ? Color.accentColor.opacity(0.4)
                                    : Color.primary.opacity(0.08),
                                lineWidth: 0.75
                            )
                    )
                    .shadow(
                        color: windowManager.isHovered ? Color.accentColor.opacity(0.2) : Color.black.opacity(0.1),
                        radius: windowManager.isHovered ? 6 : 2,
                        x: windowManager.isHovered ? 2 : 1,
                        y: windowManager.isHovered ? -2 : -1
                    )
                    .scaleEffect(isPressed ? 0.95 : (windowManager.isHovered ? 1.02 : 1.0))
                }
                .buttonStyle(PlainButtonStyle())
                .offset(y: windowManager.isHovered ? 0 : 4)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
                .contextMenu {
                    Button(action: {
                        windowManager.expandPanel()
                    }) {
                        Label("Open Nook Notes", systemImage: "arrow.up.left.and.arrow.down.right")
                    }

                    Button(action: {
                        windowManager.expandPanel()
                        windowManager.isSettingsPresented = true
                    }) {
                        Label("Settings...", systemImage: "gearshape")
                    }

                    Divider()

                    Button(role: .destructive, action: {
                        NSApp.terminate(nil)
                    }) {
                        Label("Quit Nook Notes", systemImage: "power")
                    }
                }

                Spacer()
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: windowManager.isHovered)
    }
}

// Shape helper for specific rounded corners
struct CustomCornerShape: Shape {
    var corners: RectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tr = corners.contains(.topRight) ? radius : 0
        let tl = corners.contains(.topLeft) ? radius : 0
        let br = corners.contains(.bottomRight) ? radius : 0
        let bl = corners.contains(.bottomLeft) ? radius : 0

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 {
            path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        }

        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        }

        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct RectCorner: OptionSet {
    let rawValue: Int
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}
