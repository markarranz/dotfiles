import Foundation
import CoreAudio

final class MicMonitor {
    private let sketchybarPath: String?
    private var inputDeviceIDs: [AudioDeviceID] = []
    private var lastActive: UInt32?

    init() {
        sketchybarPath = MicMonitor.resolveSketchybarPath()
    }

    func start() {
        inputDeviceIDs = discoverInputDevices()

        for deviceID in inputDeviceIDs {
            registerListener(for: deviceID)
        }

        emitCurrentActiveState()
    }

    private static func resolveSketchybarPath() -> String? {
        let fileManager = FileManager.default
        let candidates = [
            "/opt/homebrew/bin/sketchybar",
            "/usr/local/bin/sketchybar",
        ]

        for path in candidates where fileManager.fileExists(atPath: path) {
            return path
        }

        return nil
    }

    private func discoverInputDevices() -> [AudioDeviceID] {
        var devicesAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        let sizeStatus = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            0,
            nil,
            &dataSize
        )

        guard sizeStatus == noErr, dataSize > 0 else {
            return []
        }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        let dataStatus = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )

        guard dataStatus == noErr else {
            return []
        }

        return deviceIDs.filter { hasInputStreams(deviceID: $0) }
    }

    private func hasInputStreams(deviceID: AudioDeviceID) -> Bool {
        var inputStreamsAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )

        var inputSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(
            deviceID,
            &inputStreamsAddress,
            0,
            nil,
            &inputSize
        )

        return status == noErr && inputSize > 0
    }

    private func registerListener(for deviceID: AudioDeviceID) {
        var listenAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        guard AudioObjectHasProperty(deviceID, &listenAddress) else {
            return
        }

        AudioObjectAddPropertyListenerBlock(deviceID, &listenAddress, DispatchQueue.main) { [weak self] _, _ in
            self?.emitCurrentActiveState()
        }
    }

    private func isDeviceRunning(deviceID: AudioDeviceID) -> Bool {
        var runningAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var isRunning: UInt32 = 0
        var dataSize = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &runningAddress,
            0,
            nil,
            &dataSize,
            &isRunning
        )

        return status == noErr && isRunning == 1
    }

    private func currentActive() -> UInt32 {
        let anyRunning = inputDeviceIDs.contains { isDeviceRunning(deviceID: $0) }
        return anyRunning ? 1 : 0
    }

    private func emitCurrentActiveState() {
        let active = currentActive()

        if active == lastActive {
            return
        }

        lastActive = active
        triggerSketchybar(active: active)
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
        } catch {
            return
        }
    }
}

let monitor = MicMonitor()
monitor.start()
RunLoop.main.run()
