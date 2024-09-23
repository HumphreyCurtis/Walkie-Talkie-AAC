//
//  AttentionView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 18/08/2023.
//

import SwiftUI
import AVFoundation

struct AttentionView: View {
   
    //MARK: - Properties
    @State var expression: String
    
    @State var wordIndex = 0
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var timerRunning = false
    @State var rotationAmount = 180.0
    
    @State var animateGradient = false
    @State var blackOut = false
    
    @State var synthesizer = AVSpeechSynthesizer()
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                if (blackOut == false) {
                    LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .hueRotation(.degrees(animateGradient ? 45 : 0))
                        .ignoresSafeArea()
                        .onAppear {
                            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                                animateGradient.toggle()
                            }
                        }
                }
                
                VStack {
                    Text(expressionWord(wordIndex: wordIndex))
                        .padding(10)
                        .font(.system(size: 250))
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.2)
                        .lineLimit(4)
                        .bold()
                        .onReceive(timer) { input in
                            iterateWordIndex(timerStarted: timerRunning)
                        }
                        .onTapGesture {
                            textToSpeech(spokenCommand: expression)
                        }
                    
                    Image(systemName: "chair.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.black)
                        .padding()
                    
                }
                .rotationEffect(.degrees(self.rotationAmount))
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                   
                    Image(systemName: "sunset.fill")
                        .resizable()
                        .onTapGesture {
                            blackOut.toggle()
                        }
                    
                    Spacer()
                    
//                    Image(systemName: "flashlight.on.fill")
//                        .resizable()
//                        .onTapGesture {
//                            toggleFlash()
//                        }
                    
                    Spacer()
                    
                    Image(systemName: "rotate.right.fill")
                        .resizable()
                        .onTapGesture {
                            if (rotationAmount == 360.0) {
                                rotationAmount = 0.0
                            } else {
                                rotationAmount += 90.0
                            }
                        }
                }
                
            }
        }
            

    }

    //MARK: - Functions
    func animationSetup() {

        // create the gradient layer
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.red.cgColor, UIColor.green.cgColor]
        gradient.locations =  [0.0, 0.25]

        // set up the animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.25]
        animation.toValue = [0.75, 1.0]
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity

        // add the animation to the gradient
        gradient.add(animation, forKey: nil)
    }
    
    func iterateWordIndex(timerStarted: Bool) {
    
        let expressionArray = expression.components(separatedBy: " ")
        let arrayLength = expressionArray.count
            
//        print("Word Index \(wordIndex)", "Array length \(arrayLength)")
            
        if (wordIndex == arrayLength - 1) {
            wordIndex = 0
        } else {
            wordIndex += 1
        }

    }
    
    
//    private func toggleFlash() {
//
//        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
//            return
//        }
//
//        let stimageout = AVCapturePhotoOutput()
////        let settings = AVCapturePhotoSettings()
//
//        let settings = getSettings(camera: device, flashMode: flashMode)
//
//        stimageout.capturePhoto(with: settings, delegate: self)
//    }
//
//    private func getSettings(camera: AVCaptureDevice, flashMode: AVCaptureDevice.FlashMode) -> AVCapturePhotoSettings {
//        let settings = AVCapturePhotoSettings()
//
//        if camera.hasFlash {
//            settings.flashMode = flashMode
//        }
//        settings.livePhotoVideoCodecType = .jpeg
//
//        return settings
//    }
//
//    func toggleTorch(on: Bool) {
//
//        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
//            return
//        }
//
//        guard device.hasTorch else {
//            print("Torch isn't available");
//            return
//        }
//
//        do {
//            try device.lockForConfiguration()
//
//            if on == true {
//                device.torchMode = .on
//                device.flashMode = .on
//            } else {
//                device.torchMode = .off
//            }
//
//            torchOn.toggle()
//            device.unlockForConfiguration()
//
//        } catch {
//            print("Torch can't be used")
//        }
//    }
    

    
    func expressionWord(wordIndex: Int) -> String {
        let expressionArray = expression.components(separatedBy: " ")
        return expressionArray[wordIndex]
    }
    
    func textToSpeech(spokenCommand: String) {
        
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: spokenCommand)
        let voice = AVSpeechSynthesisVoice(language: "en-GB")
        
        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        // Assign the voice to the utterance.
        utterance.voice = voice
        
        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
    
}

//MARK: - Preview
struct AttentionView_Previews: PreviewProvider {
    static var previews: some View {
        AttentionView(expression: "Could you please let me have your seat? :)")
    }
}
