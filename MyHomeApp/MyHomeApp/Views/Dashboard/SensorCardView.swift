import SwiftUI

struct SensorCardView: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

struct SensorCardView_Previews: PreviewProvider {
    static var previews: some View {
        SensorCardView(title: "Sıcaklık", value: "24.5 °C", icon: "thermometer", color: .orange)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
    }
}
