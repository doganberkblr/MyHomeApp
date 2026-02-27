import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Connection Status Indicator
                    ConnectionStatusView(isConnected: bluetoothManager.isConnected)
                        .padding(.top, 10)
                    
                    // Sensor Cards Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        
                        // Temperature Card
                        SensorCardView(
                            title: "Sıcaklık",
                            value: String(format: "%.1f °C", bluetoothManager.sensorData.temperature),
                            icon: "thermometer",
                            color: .orange
                        )
                        
                        // Humidity Card
                        SensorCardView(
                            title: "Nem",
                            value: String(format: "%.1f %%", bluetoothManager.sensorData.humidity),
                            icon: "humidity.fill",
                            color: .blue
                        )
                        
                        // Air Quality (MQ135) Card
                        SensorCardView(
                            title: "Hava Kalitesi",
                            value: bluetoothManager.sensorData.isAirClean ? "Temiz" : "Riskli",
                            icon: "aqi.medium",
                            color: bluetoothManager.sensorData.isAirClean ? .green : .red
                        )
                        
                        // Sound Level Card
                        SensorCardView(
                            title: "Ses Seviyesi",
                            value: bluetoothManager.sensorData.isQuiet ? "Sessiz" : "Gürültülü",
                            icon: bluetoothManager.sensorData.isQuiet ? "speaker.wave.1.fill" : "speaker.wave.3.fill",
                            color: bluetoothManager.sensorData.isQuiet ? .green : .orange
                        )
                        
                    }
                    .padding(.horizontal)
                    
                    // Pressure Card (Full Width)
                    SensorCardView(
                        title: "Hava Basıncı",
                        value: String(format: "%.0f hPa", bluetoothManager.sensorData.pressure),
                        icon: "barometer",
                        color: .purple
                    )
                    .padding(.horizontal)
                    
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Dashboard")
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        bluetoothManager.refreshConnection()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(BluetoothManager())
            .preferredColorScheme(.dark)
    }
}
