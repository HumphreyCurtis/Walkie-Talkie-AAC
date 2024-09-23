//
//  SearchView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 21/07/2023.
//

import SwiftUI
import AVFoundation

struct SearchView: View {
   
    //MARK: - Properties
    @State private var enteredText: String = ""
    @State var rotationAmount = 180.0
    @State private var showWebView = false
    @State private var googleQuery = "https://www.google.com/search?q="
    @State private var youtubeQuery = "https://www.youtube.com"
    @State private var wikipediaQuery = "https://en.wikipedia.org/wiki/"
    @State private var googleImagesQuery = "https://www.google.com/search?tbm=isch&q="
    @State private var oxfordDictionaryQuery = "https://www.oed.com/search/dictionary/?scope=Entries&q="
    
    @State var synthesizer = AVSpeechSynthesizer()
    
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image(systemName: "video")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            performSearch(constructedString: youtubeQuery)
                        }
                    
                    Spacer()
                    
                    Image(systemName: "text.book.closed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            var query = oxfordDictionaryQuery + enteredText
                            query = removeWhitespacesFromString(masterString: query)
                            performSearch(constructedString: query)
                        }
                    
                    Spacer()
                    
                    Image(systemName: "w.square")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            var query = wikipediaQuery + enteredText
                            query = removeWhitespacesFromString(masterString: query)
                            performSearch(constructedString: query)
                        }
                }
                .padding()
                
                Spacer()
                
                TextField("Enter Text", text: $enteredText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 80))
                    .minimumScaleFactor(0.2)
                    .submitLabel(.done)
                
                Spacer()
                
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Image(systemName: "mic.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            print(enteredText)
                            textToSpeech(spokenCommand: enteredText)
                        }
                    
                    Spacer()
                    
                    Image(systemName: "globe.europe.africa.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            var query = googleQuery + enteredText
                            query = removeWhitespacesFromString(masterString: query)
                            performSearch(constructedString: query)
                        }
                    
                    Spacer()
                    
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            var query = googleImagesQuery + enteredText
                            query = removeWhitespacesFromString(masterString: query)
                            performSearch(constructedString: query)
                        }
                    
                }
            }
        }
        
    }
    
    //MARK: - Functions
    func removeWhitespacesFromString(masterString: String) -> String {
        
        let chr = masterString.components(separatedBy: .whitespaces)
        let resString = chr.joined()
        
        return resString
    }
    
    func performSearch(constructedString: String) {
        
        if let url = URL(string: constructedString) {
            UIApplication.shared.open(url)
        }
        
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
        
        // Retrieve the British English voice.
        //        if isFemale {
        //            voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact")
        //        }
        
        // let allVoices = AVSpeechSynthesisVoice.speechVoices()
        // print(allVoices)
        
        // Assign the voice to the utterance.
        utterance.voice = voice
        
        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
    
}

//MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
