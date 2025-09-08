import SwiftUI

@available(iOS 13.0, *)
public struct LucideIcon: View {
    let icon: Lucide.Icon
    let size: CGFloat
    
    public init(_ icon: Lucide.Icon, size: CGFloat = 24.0) {
        self.icon = icon
        self.size = size
    }

    public var body: some View {
        Text(icon.rawValue)
            .font(Lucide.font(ofSize: size))
    }
}

// MARK: - Previews

@available(iOS 13.0, *)
struct LucideIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            LucideIcon(.activity)
            
            LucideIcon(.airVent, size: 48)
                .foregroundColor(.blue)

            HStack {
                LucideIcon(.shieldCheck, size: 22)
                Text("Secure")
            }
            .font(.title)
            .foregroundColor(.green)
            
            Button(action: { print("Button tapped") }) {
                HStack {
                    LucideIcon(.logOut, size: 18)
                    Text("Sign Out")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
