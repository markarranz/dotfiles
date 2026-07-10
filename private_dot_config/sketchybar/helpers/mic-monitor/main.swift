import CoreAudio
import Foundation

private let systemObjectID = AudioObjectID(kAudioObjectSystemObject)

func log(_ message: String) {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  let timestamp = formatter.string(from: Date())
  print("[\(timestamp)] \(message)")
  fflush(stdout)
}

final class MicMonitor {
  private struct ProcessListeners {
    let runningAddress: AudioObjectPropertyAddress
    let devicesAddress: AudioObjectPropertyAddress
    let runningListener: AudioObjectPropertyListenerBlock
    let devicesListener: AudioObjectPropertyListenerBlock
  }

  private let sketchybarPath: String?
  private let stateFileURL: URL
  private let callbackQueue = DispatchQueue(label: "com.user.mic-monitor.callbacks")
  private let publishQueue = DispatchQueue(label: "com.user.mic-monitor.publish")
  private var inputDeviceIDs: Set<AudioDeviceID> = []
  private var processObjectIDs: Set<AudioObjectID> = []
  private var processListeners: [AudioObjectID: ProcessListeners] = [:]
  private var lastActive: Bool?
  private var heartbeatTimer: DispatchSourceTimer?

  init() {
    sketchybarPath = Self.resolveSketchybarPath()
    stateFileURL = Self.resolveStateFileURL()
  }

  func start() {
    callbackQueue.sync {
      reconcileInputDevices()
      reconcileProcesses()
      log(
        "Monitoring \(inputDeviceIDs.count) audio input device(s) across \(processObjectIDs.count) process object(s)"
      )
      registerHardwareListeners()
      emitCurrentActiveState()
      startHeartbeat()
    }
  }

  private func registerHardwareListeners() {
    var deviceAddress = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    let deviceStatus = AudioObjectAddPropertyListenerBlock(
      systemObjectID,
      &deviceAddress,
      callbackQueue
    ) { [weak self] _, _ in
      self?.reconcileInputDevices()
    }
    if deviceStatus != noErr {
      log("Failed to register audio device listener: \(deviceStatus)")
    }

    var processAddress = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyProcessObjectList,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    let processStatus = AudioObjectAddPropertyListenerBlock(
      systemObjectID,
      &processAddress,
      callbackQueue
    ) { [weak self] _, _ in
      self?.reconcileProcesses()
    }
    if processStatus != noErr {
      log("Failed to register audio process listener: \(processStatus)")
    }
  }

  private func reconcileInputDevices() {
    let newDevices = Set(discoverInputDevices())
    let added = newDevices.subtracting(inputDeviceIDs)
    let removed = inputDeviceIDs.subtracting(newDevices)
    inputDeviceIDs = newDevices

    for deviceID in added {
      log("New audio input device discovered: \(deviceID)")
    }
    if !removed.isEmpty {
      log("Removed \(removed.count) audio input device(s)")
    }

    emitCurrentActiveState()
  }

  private func reconcileProcesses() {
    let newProcesses = Set(discoverProcessObjects())
    let added = newProcesses.subtracting(processObjectIDs)
    let removed = processObjectIDs.subtracting(newProcesses)
    processObjectIDs = newProcesses

    for processID in added {
      registerProcessListeners(for: processID)
    }
    if !removed.isEmpty {
      for processID in removed {
        unregisterProcessListeners(for: processID)
      }
      log("Removed \(removed.count) audio process object(s)")
    }

    emitCurrentActiveState()
  }

  private static func resolveSketchybarPath() -> String? {
    let candidates = [
      "/opt/homebrew/bin/sketchybar",
      "/usr/local/bin/sketchybar",
    ]
    for path in candidates where FileManager.default.isExecutableFile(atPath: path) {
      return path
    }
    log("SketchyBar executable not found in Homebrew prefixes")
    return nil
  }

  private static func resolveStateFileURL() -> URL {
    if let path = ProcessInfo.processInfo.environment["MIC_MONITOR_STATE_FILE"], !path.isEmpty {
      return URL(fileURLWithPath: path)
    }

    return FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/Caches/com.user.mic-monitor/state")
  }

  private func discoverInputDevices() -> [AudioDeviceID] {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDevices,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    return readObjectIDs(objectID: systemObjectID, address: &address)
      .filter { hasAudioInputStreams(deviceID: $0) }
  }

  private func discoverProcessObjects() -> [AudioObjectID] {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyProcessObjectList,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    return readObjectIDs(objectID: systemObjectID, address: &address)
  }

  private func readObjectIDs(
    objectID: AudioObjectID,
    address: inout AudioObjectPropertyAddress
  ) -> [AudioObjectID] {
    var dataSize: UInt32 = 0
    let sizeStatus = AudioObjectGetPropertyDataSize(objectID, &address, 0, nil, &dataSize)
    guard sizeStatus == noErr, dataSize > 0 else {
      if sizeStatus != noErr {
        log("Failed to read audio object list: \(sizeStatus)")
      }
      return []
    }

    let count = Int(dataSize) / MemoryLayout<AudioObjectID>.size
    var objectIDs = [AudioObjectID](repeating: 0, count: count)
    let dataStatus = AudioObjectGetPropertyData(
      objectID,
      &address,
      0,
      nil,
      &dataSize,
      &objectIDs
    )
    guard dataStatus == noErr else {
      log("Failed to read audio object data: \(dataStatus)")
      return []
    }

    return objectIDs
  }

  private func hasAudioInputStreams(deviceID: AudioDeviceID) -> Bool {
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyStreams,
      mScope: kAudioObjectPropertyScopeInput,
      mElement: kAudioObjectPropertyElementMain
    )
    var dataSize: UInt32 = 0
    return AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize) == noErr
      && dataSize > 0
  }

  private func registerProcessListeners(for processID: AudioObjectID) {
    guard processListeners[processID] == nil else { return }

    var runningAddress = AudioObjectPropertyAddress(
      mSelector: kAudioProcessPropertyIsRunningInput,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    let runningListener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
      self?.emitCurrentActiveState()
    }
    let runningStatus = AudioObjectAddPropertyListenerBlock(
      processID,
      &runningAddress,
      callbackQueue,
      runningListener
    )
    if runningStatus != noErr {
      log("Failed to register input activity listener for process \(processID): \(runningStatus)")
    }

    var devicesAddress = AudioObjectPropertyAddress(
      mSelector: kAudioProcessPropertyDevices,
      mScope: kAudioObjectPropertyScopeInput,
      mElement: kAudioObjectPropertyElementMain
    )
    let devicesListener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
      self?.emitCurrentActiveState()
    }
    let devicesStatus = AudioObjectAddPropertyListenerBlock(
      processID,
      &devicesAddress,
      callbackQueue,
      devicesListener
    )
    if devicesStatus != noErr {
      log("Failed to register input device listener for process \(processID): \(devicesStatus)")
    }

    guard runningStatus == noErr, devicesStatus == noErr else {
      if runningStatus == noErr {
        AudioObjectRemovePropertyListenerBlock(
          processID,
          &runningAddress,
          callbackQueue,
          runningListener
        )
      }
      if devicesStatus == noErr {
        AudioObjectRemovePropertyListenerBlock(
          processID,
          &devicesAddress,
          callbackQueue,
          devicesListener
        )
      }
      return
    }
    processListeners[processID] = ProcessListeners(
      runningAddress: runningAddress,
      devicesAddress: devicesAddress,
      runningListener: runningListener,
      devicesListener: devicesListener
    )
  }

  private func unregisterProcessListeners(for processID: AudioObjectID) {
    guard let listeners = processListeners.removeValue(forKey: processID) else { return }

    var runningAddress = listeners.runningAddress
    AudioObjectRemovePropertyListenerBlock(
      processID,
      &runningAddress,
      callbackQueue,
      listeners.runningListener
    )

    var devicesAddress = listeners.devicesAddress
    AudioObjectRemovePropertyListenerBlock(
      processID,
      &devicesAddress,
      callbackQueue,
      listeners.devicesListener
    )
  }

  private func isProcessUsingInput(_ processID: AudioObjectID) -> Bool {
    var runningAddress = AudioObjectPropertyAddress(
      mSelector: kAudioProcessPropertyIsRunningInput,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: kAudioObjectPropertyElementMain
    )
    var isRunning: UInt32 = 0
    var runningSize = UInt32(MemoryLayout<UInt32>.size)
    let runningStatus = AudioObjectGetPropertyData(
      processID,
      &runningAddress,
      0,
      nil,
      &runningSize,
      &isRunning
    )
    guard runningStatus == noErr, isRunning == 1 else { return false }

    var devicesAddress = AudioObjectPropertyAddress(
      mSelector: kAudioProcessPropertyDevices,
      mScope: kAudioObjectPropertyScopeInput,
      mElement: kAudioObjectPropertyElementMain
    )
    let processInputDevices = readObjectIDs(objectID: processID, address: &devicesAddress)
    return processInputDevices.contains { inputDeviceIDs.contains($0) }
  }

  private func currentActive() -> Bool {
    processObjectIDs.contains { isProcessUsingInput($0) }
  }

  private func emitCurrentActiveState() {
    let active = currentActive()
    writeStateFile(active: active)

    guard active != lastActive else { return }
    lastActive = active
    log("State changed: ACTIVE=\(active ? 1 : 0)")
    publishState(active: active)
  }

  private func startHeartbeat() {
    let timer = DispatchSource.makeTimerSource(queue: callbackQueue)
    timer.schedule(deadline: .now() + .seconds(5), repeating: .seconds(5))
    timer.setEventHandler { [weak self] in
      self?.emitCurrentActiveState()
    }
    timer.resume()
    heartbeatTimer = timer
  }

  private func writeStateFile(active: Bool) {
    let directoryURL = stateFileURL.deletingLastPathComponent()
    do {
      try FileManager.default.createDirectory(
        at: directoryURL,
        withIntermediateDirectories: true,
        attributes: nil
      )
      let timestamp = Int(Date().timeIntervalSince1970)
      try "\(active ? 1 : 0) \(timestamp)\n".write(
        to: stateFileURL,
        atomically: true,
        encoding: .utf8
      )
    } catch {
      log("Failed to write state file: \(error.localizedDescription)")
    }
  }

  private func publishState(active: Bool) {
    publishQueue.async { [weak self] in
      self?.triggerSketchybar(active: active)
    }
  }

  private func triggerSketchybar(active: Bool) {
    guard let sketchybarPath else { return }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: sketchybarPath)
    process.arguments = [
      "--trigger",
      "mic_active_changed",
      "ACTIVE=\(active ? 1 : 0)",
    ]

    do {
      try process.run()
      process.waitUntilExit()
      guard process.terminationStatus == 0 else {
        log("SketchyBar trigger exited with status \(process.terminationStatus)")
        return
      }
      log("Triggered SketchyBar: ACTIVE=\(active ? 1 : 0)")
    } catch {
      log("Failed to trigger SketchyBar: \(error.localizedDescription)")
    }
  }
}

let monitor = MicMonitor()
monitor.start()
RunLoop.main.run()
