import SwiftUI
import AppKit

public struct CollapsedTabView: View {
    @ObservedObject var windowManager: WindowManager

    public init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }

    public var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.18)) {
                        windowManager.expandPanel()
                    }
                }) {
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color.primary.opacity(windowManager.isHovered ? 0.6 : 0.35))
                            .frame(width: 14, height: 3)

                        if windowManager.isHovered {
                            Text("Nook")
                                .font(.geist(10, weight: .semibold))
                                .foregroundColor(Color.primary.opacity(0.85))
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(height: windowManager.isHovered ? 22 : 14)
                    .background(
                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow, state: .active)
                            .overlay(
                                Color.primary.opacity(windowManager.isHovered ? 0.08 : 0.04)
                            )
                    )
                    .clipShape(
                        CustomCornerShape(corners: [.topRight], radius: 7)
                    )
                    .overlay(
                        CustomCornerShape(corners: [.topRight], radius: 7)
                            .stroke(Color.primary.opacity(windowManager.isHovered ? 0.15 : 0.08), lineWidth: 0.75)
                    )
                    .shadow(color: Color.black.opacity(windowManager.isHovered ? 0.18 : 0.08), radius: windowManager.isHovered ? 4 : 2, x: 1, y: -1)
                }
                .buttonStyle(PlainButtonStyle())
                .offset(y: windowManager.isHovered ? 0 : 4)
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
        .animation(.easeOut(duration: 0.15), value: windowManager.isHovered)
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
