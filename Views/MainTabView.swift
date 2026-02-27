import SwiftUI

struct MainTabView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
            
            SecurityView()
                .tabItem {
                    Label("Security", systemImage: "lock.shield.fill")
                }
            
            ControlView()
                .tabItem {
                    Label("Control", systemImage: "switch.2")
                }
        }
        .environmentObject(bluetoothManager)
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
