import SwiftUI

struct ConnectionStatusView: View {
    var isConnected: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            Text(isConnected ? "Bağlı (Connected)" : "Bağlantı Bekleniyor...")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isConnected ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill((isConnected ? Color.green : Color.red).opacity(0.15))
        )
    }
}

struct ConnectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStatusView(isConnected: true)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
