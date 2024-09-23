//
//  DisplayView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 20/07/2023.
//

import SwiftUI
import AVFoundation

struct DisplayView: View {
    
    //MARK: - Properties
    @State var expression: String
    @State var backgroundColour: Color
    @State var rotationAmount = 180.0
    
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    @State var wordIndex = 0
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var timerRunning = false
    
    @State var symbols = ["figure.roll", "book.circle.fill"]
    @State var selectedSymbol = "figure.roll"
    
    @State var synthesizer = AVSpeechSynthesizer()
    
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .overlay {
                            Text(expression)
                                .padding(5)
                                .font(.system(size: 100))
                                .minimumScaleFactor(0.2)
                                .lineLimit(5)
                                .bold()
                                .rotationEffect(.degrees(rotationAmount))
                        }
                } else {
                    Text(expression)
                        .padding(10)
                        .font(.system(size: 100))
                        .minimumScaleFactor(0.2)
                        .lineLimit(4)
                        .bold()
                        .rotationEffect(.degrees(rotationAmount))
//                        .onReceive(timer) { input in
//                            iterateWordIndex(timerStarted: timerRunning)
//                        }
                        
                    
                    Image(systemName: "figure.roll")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .offset(y: 50)
                }

                    
            }
            .sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColour)
            .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        
                        Image(systemName: "camera.fill")
                            .resizable()
                            .onTapGesture {
                                print("Tapping for camera")
                                self.sourceType = .camera
                                self.isImagePickerDisplay.toggle()
                            }
                        
                        Spacer()
                        
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding()
                            .onTapGesture {
                                textToSpeech(spokenCommand: expression)
                            }
                        
                        
                        Spacer()
                        
                        ColorPicker("Colour:", selection: $backgroundColour)
                            .padding()
                            .font(.title2)
                            .bold()
                        
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
    func iterateWordIndex(timerStarted: Bool) {
        
        if timerStarted {
    
            let expressionArray = expression.components(separatedBy: " ")
            let arrayLength = expressionArray.count
            
//            print("Word Index \(wordIndex)", "Array length \(arrayLength)")
            
            if (wordIndex == arrayLength - 1) {
                wordIndex = 0
            } else {
                wordIndex += 1
            }
            
        }
    }
    
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
struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(expression: "I have had a stroke and aphasia.", backgroundColour: Color.white)
    }
}
