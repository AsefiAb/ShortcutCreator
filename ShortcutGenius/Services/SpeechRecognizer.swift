import Foundation
import Speech
import AVFoundation
import Observation

@Observable
@MainActor
final class SpeechRecognizer {
    enum AuthState {
        case unknown, authorized, denied, restricted
    }

    private(set) var transcript: String = ""
    private(set) var isRecording = false
    private(set) var authState: AuthState = .unknown

    private let recognizer = SFSpeechRecognizer(locale: .current)
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()

    func requestAuthorization() async {
        let speech = await withCheckedContinuation { (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        let mic = await AVAudioApplication.requestRecordPermission()

        switch speech {
        case .authorized where mic: authState = .authorized
        case .denied, .restricted: authState = .denied
        default: authState = mic ? .authorized : .denied
        }
    }

    func start() throws {
        guard authState == .authorized else { return }
        guard let recognizer, recognizer.isAvailable else { return }

        recognitionTask?.cancel()
        recognitionTask = nil

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
        transcript = ""

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result {
                Task { @MainActor in self?.transcript = result.bestTranscription.formattedString }
            }
            if error != nil || (result?.isFinal ?? false) {
                Task { @MainActor in self?.stop() }
            }
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
