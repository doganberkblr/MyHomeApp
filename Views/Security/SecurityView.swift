import SwiftUI

struct SecurityView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var isAlarmActive: Bool = false
    @State private var isPulsing: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ConnectionStatusView(isConnected: bluetoothManager.isConnected)
                    .padding(.top, 10)
                
                Spacer()
                
                // Security Status Indicator
                ZStack {
                    Circle()
                        .fill(bluetoothManager.sensorData.motionDetected ? Color.red.opacity(isPulsing ? 0.5 : 0.15) : Color.green.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .scaleEffect(bluetoothManager.sensorData.motionDetected && isPulsing ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear {
                            isPulsing = true
                        }
                    
                    Circle()
                        .stroke(bluetoothManager.sensorData.motionDetected ? Color.red : Color.green, lineWidth: 6)
                        .frame(width: 250, height: 250)
                    
                    VStack(spacing: 12) {
                        Image(systemName: bluetoothManager.sensorData.motionDetected ? "figure.walk.motion" : "checkmark.shield.fill")
                            .font(.system(size: 64))
                            .foregroundColor(bluetoothManager.sensorData.motionDetected ? .red : .green)
                        
                        Text(bluetoothManager.sensorData.motionDetected ? "HAREKET\nALGILANDI!" : "ODA\nGÜVENLİ")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(bluetoothManager.sensorData.motionDetected ? .red : .green)
                    }
                }
                .padding(.bottom, 60)
                
                // Alarm Toggle
                VStack(spacing: 20) {
                    Text("Alarm Sistemi")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Toggle("", isOn: $isAlarmActive)
                        .labelsHidden()
                        .scaleEffect(1.3)
                        .onChange(of: isAlarmActive) { newValue in
                            bluetoothManager.setAlarmSystem(isActive: newValue)
                        }
                    
                    Text(isAlarmActive ? "Aktif" : "Devre Dışı")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Security")
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

struct SecurityView_Previews: PreviewProvider {
    static var previews: some View {
        SecurityView()
            .environmentObject(BluetoothManager())
            .preferredColorScheme(.dark)
    }
}
