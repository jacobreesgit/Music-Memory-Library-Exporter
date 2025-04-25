import SwiftUI

// MARK: - Gradient Definitions
struct AppGradients {
    static let primary = LinearGradient(
        colors: [Color(hex: "4776E6"), Color(hex: "8E54E9")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondary = LinearGradient(
        colors: [Color(hex: "00CDAC"), Color(hex: "8DDA65")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accent = LinearGradient(
        colors: [Color(hex: "FF512F"), Color(hex: "F09819")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var isWide: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 15)
            .padding(.horizontal, isWide ? 60 : 30)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppGradients.primary)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    // Highlight effect when pressed
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.3))
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
            .frame(maxWidth: isWide ? .infinity : nil)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(Color(hex: "4776E6"))
            .padding(.vertical, 12)
            .padding(.horizontal, 25)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "4776E6").opacity(0.3), lineWidth: 1)
                    
                    // Highlight effect when pressed
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "4776E6").opacity(0.1))
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
    }
}

// MARK: - Stats Item
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

// MARK: - Song List Item
struct SongListItem: View {
    let song: Song
    
    var body: some View {
        HStack(spacing: 16) {
            // Album artwork placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(
                        colors: [Color(hex: "e0e0e0"), Color(hex: "f5f5f5")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                Image(systemName: "music.note")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "8E54E9"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(song.artist) • \(song.album)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(song.playCount > 0 ? Color(hex: "4776E6") : Color.gray)
                    
                    Text("\(song.playCount) plays")
                        .font(.caption)
                        .foregroundColor(song.playCount > 0 ? Color(hex: "4776E6") : Color.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Header View
struct GradientHeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient
            Rectangle()
                .fill(AppGradients.primary)
                .frame(height: 230)
                .edgesIgnoringSafeArea(.top)
            
            // Music note decorations
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .offset(x: -130, y: 40)
                
                Image(systemName: "music.note")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.5))
                    .offset(x: -130, y: 40)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .offset(x: 120, y: 20)
                
                Image(systemName: "music.quarternote.3")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.5))
                    .offset(x: 120, y: 20)
            }
            
            // Content
            VStack {
                Spacer().frame(height: 60)
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color(hex: "4776E6"))
            
            Text("Loading your music...")
                .font(.headline)
                .foregroundColor(Color(hex: "4776E6"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.95))
    }
}

// MARK: - No Permission View
struct NoPermissionView: View {
    let requestPermission: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(AppGradients.primary)
                    .frame(width: 110, height: 110)
                
                Image(systemName: "music.note.list")
                    .font(.system(size: 46))
                    .foregroundColor(.white)
            }
            
            // Text
            VStack(spacing: 16) {
                Text("Music Library Access")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("This app needs permission to access your music library to export play counts and statistics.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Button
            Button(action: requestPermission) {
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                    Text("Grant Permission")
                }
            }
            .buttonStyle(PrimaryButtonStyle(isWide: true))
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

// MARK: - Export Options Sheet
struct ExportOptionsSheet: View {
    @Binding var selectedFormat: ExportFormat
    let exportAction: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header image
                ZStack {
                    Circle()
                        .fill(AppGradients.primary)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                Text("Export Options")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose a format to export your music play count data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    // JSON option
                    Button {
                        selectedFormat = .json
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.title3)
                            
                            Text("JSON Format")
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedFormat == .json {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "4776E6"))
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedFormat == .json ? Color(hex: "4776E6").opacity(0.1) : Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                    }
                    .foregroundColor(.primary)
                    
                    // CSV option
                    Button {
                        selectedFormat = .csv
                    } label: {
                        HStack {
                            Image(systemName: "tablecells")
                                .font(.title3)
                            
                            Text("CSV Format")
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedFormat == .csv {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "4776E6"))
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedFormat == .csv ? Color(hex: "4776E6").opacity(0.1) : Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Export button
                Button {
                    dismiss()
                    exportAction()
                } label: {
                    Text("Export Now")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(isWide: true))
                .padding(.horizontal)
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
