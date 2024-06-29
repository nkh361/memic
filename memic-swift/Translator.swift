//
//  Translator.swift
//  memic-swift
//
//  Created by nate on 6/27/24.
//

import SwiftUI
import AVFoundation
import Speech

struct Translator: View {
    @State private var userInput: String = ""
    @State private var selectedLanguage: String = "English"
    @State private var translatedText: String = "Translation will appear here"
    @State private var isRecording = false
    @State private var showingAlert = false
    
    let languages = ["English", "Spanish", "French", "German", "Chinese"]
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    let audioEngine = AVAudioEngine()
    
    @State private var request: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    
    var body: some View {
        VStack {
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding()
                    Text("user")
                        .font(.title)
                }
                .padding(.leading)
                
                HStack {
                    TextField("Enter something", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) {
                            language in Text(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        }
                        else {
                            Task {
                                await startRecording()
                            }
                        }
                    }) {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.largeTitle)
                            .padding()
                            .background(isRecording ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding()
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Translated Text")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text(translatedText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Spacer()
                
                NavigationLink(destination: ContentView()) {
                    Text("go back to landing")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("microphone access denied"),
                message: Text("please enable access in settings"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            SFSpeechRecognizer.requestAuthorization {
                authStatus in switch authStatus {
                case .authorized:
                    print("authorized speech recognition")
                case .denied, .restricted, .notDetermined:
                    DispatchQueue.main.async {
                        self.showingAlert = true
                    }
                @unknown default:
                    fatalError("unknown authorization status")
                }
            }
        }
    }
    
    func startRecording() async {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            // let inputNode = audioEngine.inputNode; else { fatalError("Audio enginer has no input node") }
            guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { fatalError("Speech recognizer is not available") }
            
            self.request = request
            self.recognitionTask = speechRecognizer.recognitionTask(with: request) {
                result, error in DispatchQueue.main.async {
                    if let result = result {
                        self.userInput = result.bestTranscription.formattedString
                    }
                    
                    if error != nil || result?.isFinal == true {
                        self.audioEngine.stop()
                        self.audioEngine.inputNode.removeTap(onBus: 0)
                        self.request = nil
                        self.recognitionTask = nil
                        self.isRecording = false
                    }
                }
            }
            
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
                request.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        }
        catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        request?.endAudio()
        isRecording = false
    }
}

struct Translator_Previews: PreviewProvider {
    static var previews: some View {
        Translator()
    }
}
