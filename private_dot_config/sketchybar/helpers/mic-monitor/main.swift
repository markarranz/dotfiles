import Foundation
import CoreAudio
import CoreMediaIO

func log(_ message: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = formatter.string(from: Date())
    print("[\(timestamp)] \(message)")
    fflush(stdout)
}

final class MediaMonitor {
    private let sketchybarPath: String?
    private var audioInputDeviceIDs: [AudioDeviceID] = []
    private var cameraDeviceIDs: [CMIODeviceID] = []
    private var lastActive: UInt32?

    init() {
        sketchybarPath = MediaMonitor.resolveSketchybarPath()
        enableDALDevices()
    }

    func start() {
        audioInputDeviceIDs = discoverAudioInputDevices()
        cameraDeviceIDs = discoverCameraDevices()
        log("Discovered \(audioInputDeviceIDs.count) audio input device(s)")
        log("Discovered \(cameraDeviceIDs.count) camera device(s)")

        for deviceID in audioInputDeviceIDs {
            log("Registering audio listener for device \(deviceID)")
            registerAudioListener(for: deviceID)
        }

        for deviceID in cameraDeviceIDs {
            log("Registering camera listener for device \(deviceID)")
            registerCameraListener(for: deviceID)
        }

        emitCurrentActiveState()
    }

    private static func resolveSketchybarPath() -> String? {
        let candidates = [
            "/opt/homebrew/bin/sketchybar",
            "/usr/local/bin/sketchybar",
        ]
        for path in candidates where FileManager.default.fileExists(atPath: path) {
            return path
        }
        return nil
    }

    private func enableDALDevices() {
        var prop = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        var allow: UInt32 = 1
        let size = UInt32(MemoryLayout<UInt32>.size)
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &prop, 0, nil, size, &allow)
    }

    private func discoverAudioInputDevices() -> [AudioDeviceID] {
        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &addr, 0, nil, &dataSize) == noErr,
              dataSize > 0 else { return [] }

        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var ids = [AudioDeviceID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &addr, 0, nil, &dataSize, &ids) == noErr else { return [] }

        return ids.filter { hasAudioInputStreams(deviceID: $0) }
    }

    private func hasAudioInputStreams(deviceID: AudioDeviceID) -> Bool {
        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        return AudioObjectGetPropertyDataSize(deviceID, &addr, 0, nil, &size) == noErr && size > 0
    }

    private func discoverCameraDevices() -> [CMIODeviceID] {
        var addr = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        var dataSize: UInt32 = 0
        guard CMIOObjectGetPropertyDataSize(CMIOObjectID(kCMIOObjectSystemObject), &addr, 0, nil, &dataSize) == noErr,
              dataSize > 0 else { return [] }

        let count = Int(dataSize) / MemoryLayout<CMIODeviceID>.size
        var ids = [CMIODeviceID](repeating: 0, count: count)
        guard CMIOObjectGetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &addr, 0, nil, dataSize, &dataSize, &ids) == noErr else { return [] }

        return ids
    }

    private func registerAudioListener(for deviceID: AudioDeviceID) {
        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        guard AudioObjectHasProperty(deviceID, &addr) else { return }
        AudioObjectAddPropertyListenerBlock(deviceID, &addr, DispatchQueue.main) { [weak self] _, _ in
            self?.emitCurrentActiveState()
        }
    }

    private func registerCameraListener(for deviceID: CMIODeviceID) {
        var addr = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        guard CMIOObjectHasProperty(deviceID, &addr) else { return }
        // CMIOObjectAddPropertyListenerBlock has a different signature than AudioObject version
        let status = CMIOObjectAddPropertyListenerBlock(deviceID, &addr, DispatchQueue.main) { [weak self] _, _ in
            self?.emitCurrentActiveState()
        }
        if status != noErr {
            log("Failed to register camera listener for device \(deviceID): \(status)")
        }
    }

    private func isAudioDeviceRunning(deviceID: AudioDeviceID) -> Bool {
        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var isRunning: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        return AudioObjectGetPropertyData(deviceID, &addr, 0, nil, &size, &isRunning) == noErr && isRunning == 1
    }

    private func isCameraRunning(deviceID: CMIODeviceID) -> Bool {
        var addr = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        var isRunning: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        return CMIOObjectGetPropertyData(deviceID, &addr, 0, nil, size, &size, &isRunning) == noErr && isRunning == 1
    }

    private func currentActive() -> UInt32 {
        let audioActive = audioInputDeviceIDs.contains { isAudioDeviceRunning(deviceID: $0) }
        let cameraActive = cameraDeviceIDs.contains { isCameraRunning(deviceID: $0) }
        return (audioActive || cameraActive) ? 1 : 0
    }

    private func emitCurrentActiveState() {
        let active = currentActive()

        if active == lastActive {
            return
        }

        log("State changed: ACTIVE=\(active)")
        lastActive = active
        triggerSketchybar(active: active)
        writeStateFile(active: active)
    }

    private func writeStateFile(active: UInt32) {
        try? "\(active)".write(toFile: "/tmp/mic-monitor-state", atomically: true, encoding: .utf8)
    }

    private func triggerSketchybar(active: UInt32) {
        guard let sketchybarPath else {
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: sketchybarPath)
        process.arguments = ["--trigger", "mic_active_changed", "ACTIVE=\(active)"]

        do {
            try process.run()
            process.waitUntilExit()
            log("Triggered sketchybar: ACTIVE=\(active)")
        } catch {
            log("Failed to trigger sketchybar: \(error)")
        }
    }
}

let monitor = MediaMonitor()
monitor.start()
RunLoop.main.run()
