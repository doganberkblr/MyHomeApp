import Foundation
import CoreBluetooth
import SwiftUI
import Combine
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isConnected: Bool = false
    @Published var sensorData: SensorData = SensorData()
    
    private var centralManager: CBCentralManager!
    private var myPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    
    private let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    private let readCharacteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    private let writeCharacteristicUUID = CBUUID(string: "8c30650d-d4fa-4b53-aa2e-0dcfba126cb6")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - CoreBluetooth Central Manager Delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is On. Scanning...")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            print("Bluetooth is not available.")
            DispatchQueue.main.async {
                self.isConnected = false
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown Device")")
        myPeripheral = peripheral
        myPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Device")")
        DispatchQueue.main.async {
            self.isConnected = true
        }
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Device")")
        DispatchQueue.main.async {
            self.isConnected = false
        }
        // Auto-reconnect
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    // MARK: - App Actions
    
    func refreshConnection() {
        print("Refreshing connection...")
        if let peripheral = myPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    // MARK: - CoreBluetooth Peripheral Delegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([readCharacteristicUUID, writeCharacteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == readCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == writeCharacteristicUUID {
                writeCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == readCharacteristicUUID, let data = characteristic.value {
            parseSensorData(data: data)
        }
    }
    
    // MARK: - Data Parsing
    private func parseSensorData(data: Data) {
        // Assuming comma-separated data from ESP32: "Temp,Hum,AirCleanState,QuietState,MotionState"
        // Example: "24.5,45.0,1,0,1,1013.25" -> clean air(1), not quiet(0), motion detected(1), pressure(1013.25)
        if let dataString = String(data: data, encoding: .utf8) {
            let components = dataString.components(separatedBy: ",")
            if components.count >= 6 {
                DispatchQueue.main.async {
                    self.sensorData.temperature = Double(components[0]) ?? 0.0
                    self.sensorData.humidity = Double(components[1]) ?? 0.0
                    self.sensorData.isAirClean = (components[2] == "1")
                    self.sensorData.isQuiet = (components[3] == "1")
                    self.sensorData.motionDetected = (components[4] == "1")
                    self.sensorData.pressure = Double(components[5]) ?? 0.0
                }
            }
        }
    }
    
    // MARK: - Control Commands
    
    func updateLedColor(color: Color) {
        guard let characteristic = writeCharacteristic, let peripheral = myPeripheral else { return }
        
        // Convert SwiftUI Color to RGB (using UIColor for iOS)
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        let command = "LED:\(r),\(g),\(b)"
        if let data = command.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    func setBuzzerState(isOn: Bool) {
        guard let characteristic = writeCharacteristic, let peripheral = myPeripheral else { return }
        
        let command = isOn ? "BUZ:1" : "BUZ:0"
        if let data = command.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    func setAlarmSystem(isActive: Bool) {
        guard let characteristic = writeCharacteristic, let peripheral = myPeripheral else { return }
        
        // Send alarm configuration
        let command = isActive ? "ALM:1" : "ALM:0"
        if let data = command.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
}
