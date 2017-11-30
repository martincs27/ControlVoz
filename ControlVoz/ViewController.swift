//
//  ViewController.swift
//  ControlVoz
//
//  Created by Mac Tecsup on 17/11/17.
//  Copyright © 2017 Tecsup. All rights reserved.
//

import UIKit
import Speech
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var comandos: [String] = ["prender", "apagar", "abrir", "cerrar"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func grabarButton(_ sender: Any) {
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
            switch authStatus {
            case .authorized:
                do {
                    try self.startRecording()
                } catch let error {
                    print("There was a problem starting recording: \(error.localizedDescription)")
                }
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Not available on this device")
            case .notDetermined:
                print("Not determined")
            }
        }
    }
    @IBAction func stop(_ sender: Any) {
        stopRecording()
    }
    func startRecording() throws{
        print("startRecording")
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        // 2
        node.removeTap(onBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024,
                        format: recordingFormat) { [unowned self]
                            (buffer, _) in
                            self.request.append(buffer)
        }
        
        // 3
        audioEngine.prepare()
        try audioEngine.start()
        recognitionTask = speechRecognizer?.recognitionTask(with: request) {
            [unowned self]
            (result, _) in
            if let transcription = result?.bestTranscription {
                print(transcription.formattedString)
                self.textView.text = transcription.formattedString
                for comando in self.comandos {
                    if transcription.formattedString.lowercased().range(of:comando) != nil {
                        self.stopRecording()
                        print(comando)
                    }
                }
            }
        }
    }
    func stopRecording() {
        print("stopRecording")
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
    
    func sendServer(comando: String){
        Alamofire.request("https://controlvoz-martincs27.c9users.io/action/show").responseJSON{ response in
            print("Result : \(response.result)")
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        }
    }

}

