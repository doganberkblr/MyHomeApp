import SwiftUI

struct ControlView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var ledColor: Color = .white
    @State private var isBuzzerOn: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bağlantı Durumu")) {
                    ConnectionStatusView(isConnected: bluetoothManager.isConnected)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Aydınlatma Kontrolü"), footer: Text("ESP32 üzerindeki RGB LED'in rengini değiştirir.")) {
                    ColorPicker("Oda Rengi", selection: $ledColor)
                        .onChange(of: ledColor) { newColor in
                            bluetoothManager.updateLedColor(color: newColor)
                        }
                        .padding(.vertical, 8)
                        
                    Button(action: {
                        ledColor = .black
                        bluetoothManager.updateLedColor(color: .black)
                    }) {
                        HStack {
                            Image(systemName: "lightbulb.slash")
                            Text("Aydınlatmayı Kapat")
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Yüksek Sesli İkaz (Buzzer)"), footer: Text("Acil bir durumda evdeki buzzer'ı öttürebilir veya susturabilirsiniz.")) {
                    Button(action: {
                        isBuzzerOn.toggle()
                        bluetoothManager.setBuzzerState(isOn: isBuzzerOn)
                        
                        // Let device haptic feedback play
                        let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                        impactMed.impactOccurred()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: isBuzzerOn ? "bell.slash.fill" : "bell.fill")
                                .font(.title3)
                            Text(isBuzzerOn ? "Buzzer'ı Sustur" : "Acil Durum Çal")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(isBuzzerOn ? Color.orange : Color.red)
                        .cornerRadius(12)
                    }
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Control Panel")
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

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
            .environmentObject(BluetoothManager())
            .preferredColorScheme(.dark)
    }
}
