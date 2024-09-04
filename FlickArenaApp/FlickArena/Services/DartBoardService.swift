//
//  DartBoardService.swift
//  FlickArena
//
//  Created by Shane Chi on 2024/9/4.
//

import CoreBluetooth

final class DartBoardService: NSObject, ObservableObject {

    static let DEVICE_NAME = "DARTSLIVE HOME"
    static let CHANGE_PALYER_SIGNAL = 83

    @Published var bluetoothEnabled: Bool?
    @Published var dartBoardSignal: DartBoardSignal?

    private let centralManager: CBCentralManager
    private var dartBoard: CBPeripheral?

    init(centralManager: CBCentralManager) {
        self.centralManager = centralManager
        super.init()

        setUp()
    }
}

// MARK: - Private functions
extension DartBoardService {
    private func setUp() {
        centralManager.delegate = self
    }

    private func parseRawSignal(_ rawSignal: String) -> DartBoardSignal? {
        let startIndex = rawSignal.index(rawSignal.startIndex, offsetBy: 4)
        let endIndex = rawSignal.index(rawSignal.startIndex, offsetBy: 5)
        let hex = "\(rawSignal[startIndex...endIndex])"
        let signal = (Int(hex, radix: 16) ?? 0) - 1

        if signal == DartBoardService.CHANGE_PALYER_SIGNAL {
            return .changePlayer
        }

        guard signal >= 0, let scoreAreaType = DartBoardScoreAreaType(rawValue: signal / 20) else { return nil }
        let score = (signal % 20) + 1
        return .dartOn(score: score, type: scoreAreaType)
    }
}

// MARK: - CBCentralManagerDelegate
extension DartBoardService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            bluetoothEnabled = false
            return
        }
        bluetoothEnabled = true
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == DartBoardService.DEVICE_NAME {
            dartBoard = peripheral
            central.connect(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()

        dartBoard?.delegate = self
        dartBoard?.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        dartBoard = nil
    }
}

// MARK: - CBPeripheralDelegate
extension DartBoardService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = dartBoard?.services?.first {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach {
            peripheral.readValue(for: $0)
            peripheral.setNotifyValue(true, for: $0)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let rawSignal = characteristic.value?.hexEncodedString() else { return }
        dartBoardSignal = parseRawSignal(rawSignal)
    }
}
