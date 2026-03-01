#!/usr/bin/env swift
// Creates the "BH + Mic Input" aggregate audio device on macOS.
// Combines BlackHole 2ch (virtual loopback) + built-in microphone so Tuple
// can stream TTS audio to remote participants via ~/.tuple/triggers/.
// run_once_: chezmoi runs this exactly once per machine.

#if canImport(CoreAudio)
import CoreAudio
import Foundation

let DEVICE_NAME = "BH + Mic Input"
let DEVICE_UID  = "com.dotfiles.bh-mic-input"

// ---------------------------------------------------------------------------
// Helper: get a String property from an AudioObject
// ---------------------------------------------------------------------------
func getStringProperty(_ objectID: AudioObjectID,
                        _ selector: AudioObjectPropertySelector) -> String? {
    var addr = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope:    kAudioObjectPropertyScopeGlobal,
        mElement:  kAudioObjectPropertyElementMain
    )
    var cfStr: Unmanaged<CFString>? = nil
    var size = UInt32(MemoryLayout<Unmanaged<CFString>>.size)
    let status = AudioObjectGetPropertyData(objectID, &addr, 0, nil, &size, &cfStr)
    guard status == noErr, let s = cfStr else { return nil }
    return s.takeRetainedValue() as String
}

// ---------------------------------------------------------------------------
// Helper: get all AudioDeviceIDs
// ---------------------------------------------------------------------------
func allDeviceIDs() -> [AudioObjectID] {
    var addr = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope:    kAudioObjectPropertyScopeGlobal,
        mElement:  kAudioObjectPropertyElementMain
    )
    var size: UInt32 = 0
    let sysObj = AudioObjectID(kAudioObjectSystemObject)
    guard AudioObjectGetPropertyDataSize(sysObj, &addr, 0, nil, &size) == noErr else { return [] }
    let count = Int(size) / MemoryLayout<AudioObjectID>.size
    var ids = [AudioObjectID](repeating: 0, count: count)
    guard AudioObjectGetPropertyData(sysObj, &addr, 0, nil, &size, &ids) == noErr else { return [] }
    return ids
}

// ---------------------------------------------------------------------------
// 1. Check if device already exists
// ---------------------------------------------------------------------------
for id in allDeviceIDs() {
    if let name = getStringProperty(id, kAudioObjectPropertyName), name == DEVICE_NAME {
        print("[audio-setup] \"\(DEVICE_NAME)\" already exists, skipping")
        exit(0)
    }
}

// ---------------------------------------------------------------------------
// 2. Find BlackHole 2ch UID
// ---------------------------------------------------------------------------
var blackholeUID: String? = nil
for id in allDeviceIDs() {
    if let name = getStringProperty(id, kAudioObjectPropertyName), name == "BlackHole 2ch" {
        blackholeUID = getStringProperty(id, kAudioDevicePropertyDeviceUID)
        break
    }
}
guard let bhUID = blackholeUID else {
    print("[audio-setup] ERROR: BlackHole 2ch not found — install it first")
    exit(1)
}

// ---------------------------------------------------------------------------
// 3. Find built-in microphone UID
// ---------------------------------------------------------------------------
let micNames = ["MacBook Pro Microphone", "MacBook Air Microphone", "Built-in Microphone"]
var micUID: String? = nil

outer: for id in allDeviceIDs() {
    if let name = getStringProperty(id, kAudioObjectPropertyName) {
        for candidate in micNames {
            if name == candidate {
                micUID = getStringProperty(id, kAudioDevicePropertyDeviceUID)
                break outer
            }
        }
    }
}

// Fall back to default input device
if micUID == nil {
    var addr = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope:    kAudioObjectPropertyScopeGlobal,
        mElement:  kAudioObjectPropertyElementMain
    )
    var defaultID: AudioObjectID = AudioObjectID(kAudioObjectUnknown)
    var size = UInt32(MemoryLayout<AudioObjectID>.size)
    if AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &addr,
                                   0, nil, &size, &defaultID) == noErr,
       defaultID != AudioObjectID(kAudioObjectUnknown) {
        micUID = getStringProperty(defaultID, kAudioDevicePropertyDeviceUID)
    }
}

guard let mUID = micUID else {
    print("[audio-setup] ERROR: could not find a microphone device")
    exit(1)
}

// ---------------------------------------------------------------------------
// 4. Find CoreAudio plugin by enumerating all plugins
// ---------------------------------------------------------------------------
var pluginListAddr = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyPlugInList,
    mScope:    kAudioObjectPropertyScopeGlobal,
    mElement:  kAudioObjectPropertyElementMain
)
let sysObj = AudioObjectID(kAudioObjectSystemObject)
var pluginsSize: UInt32 = 0
AudioObjectGetPropertyDataSize(sysObj, &pluginListAddr, 0, nil, &pluginsSize)
let pluginCount = Int(pluginsSize) / MemoryLayout<AudioObjectID>.size
var pluginIDs = [AudioObjectID](repeating: 0, count: pluginCount)
AudioObjectGetPropertyData(sysObj, &pluginListAddr, 0, nil, &pluginsSize, &pluginIDs)

var pluginID: AudioObjectID = AudioObjectID(kAudioObjectUnknown)
for id in pluginIDs {
    if let bundle = getStringProperty(id, kAudioPlugInPropertyBundleID),
       bundle == "com.apple.audio.CoreAudio" {
        pluginID = id
        break
    }
}
guard pluginID != AudioObjectID(kAudioObjectUnknown) else {
    print("[audio-setup] ERROR: could not find CoreAudio plugin")
    exit(1)
}

// ---------------------------------------------------------------------------
// 5. Create the aggregate device
// ---------------------------------------------------------------------------
let subDevices: [[String: Any]] = [
    [kAudioSubDeviceUIDKey as String: bhUID],
    [kAudioSubDeviceUIDKey as String: mUID],
]
let aggregateDesc: [String: Any] = [
    kAudioAggregateDeviceNameKey as String:            DEVICE_NAME,
    kAudioAggregateDeviceUIDKey as String:             DEVICE_UID,
    kAudioAggregateDeviceIsPrivateKey as String:       0,
    kAudioAggregateDeviceIsStackedKey as String:       0,
    kAudioAggregateDeviceMasterSubDeviceKey as String: mUID,
    kAudioAggregateDeviceSubDeviceListKey as String:   subDevices,
]
let cfDict = aggregateDesc as CFDictionary

var createAddr = AudioObjectPropertyAddress(
    mSelector: kAudioPlugInCreateAggregateDevice,
    mScope:    kAudioObjectPropertyScopeGlobal,
    mElement:  kAudioObjectPropertyElementMain
)
var newDeviceID: AudioObjectID = AudioObjectID(kAudioObjectUnknown)
var newDeviceSize = UInt32(MemoryLayout<AudioObjectID>.size)

let createStatus = withUnsafePointer(to: cfDict) { qualPtr in
    AudioObjectGetPropertyData(pluginID, &createAddr,
                               UInt32(MemoryLayout<CFDictionary>.size), qualPtr,
                               &newDeviceSize, &newDeviceID)
}

if createStatus == noErr && newDeviceID != AudioObjectID(kAudioObjectUnknown) {
    print("[audio-setup] Created \"\(DEVICE_NAME)\" (id=\(newDeviceID))")
    print("[audio-setup]   BlackHole 2ch uid: \(bhUID)")
    print("[audio-setup]   Microphone uid:    \(mUID)")
} else {
    print("[audio-setup] ERROR: failed to create aggregate device (status \(createStatus))")
    exit(1)
}

#else
// Non-Apple platform — CoreAudio not available, nothing to do.
#endif
