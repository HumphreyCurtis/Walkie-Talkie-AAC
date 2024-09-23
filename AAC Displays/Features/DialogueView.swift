//
//  DialogueView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 19/08/2023.
//

import SwiftUI

struct DialogueView: View {
    
    //MARK: - Properties
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State var rotationAmount = 180.0
    
    //MARK: - Body
    var body: some View {
        VStack {
            Text(speechRecognizer.transcript)
                .padding()
                .foregroundStyle(.black)
            
            Spacer()
            
            Text(speechRecognizer.latestWord)
                .padding()
                .font(.system(size: 80))
                .minimumScaleFactor(0.2)
                .lineLimit(1)
                .padding()
                .rotationEffect(.degrees(rotationAmount))
                .foregroundStyle(.black)
            
            Spacer()
            
            Image(checkImageDatset(latestWord: speechRecognizer.latestWord))
                .resizable()
                .scaledToFit()
                .padding()
                .rotationEffect(.degrees(rotationAmount))
            
            
            Spacer()
            
            Button(action: {
                if !isRecording {
                    speechRecognizer.transcribe()
                } else {
                    speechRecognizer.stopTranscribing()
                }
                isRecording.toggle()
            }){
                Text(isRecording ? "Stop" : "Record")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(isRecording ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
    
    //MARK: - Functions
    func checkImageDatset(latestWord: String) -> String {
        let lowerCaseWord = latestWord.lowercased()
        
        if UIImage(named: lowerCaseWord) != nil {
            return lowerCaseWord
        }
        
        return ""
    }
}

//MARK: - Preview
struct DialogueView_Previews: PreviewProvider {
    static var previews: some View {
        DialogueView()
    }
}
