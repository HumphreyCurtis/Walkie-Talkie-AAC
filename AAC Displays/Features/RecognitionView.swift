//
//  RecognitionView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 21/08/2023.
//

import SwiftUI

struct RecognitionView: View {
    
    //MARK: - Properties
    @State var isPresenting: Bool = false
    @State var uiImage: UIImage?
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @ObservedObject var classifier: ImageClassifier
    
    //MARK: - Body
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "photo")
                    .onTapGesture {
                        isPresenting = true
                        sourceType = .photoLibrary
                    }
                
                Spacer()
                
                Image(systemName: "camera")
                    .onTapGesture {
                        isPresenting = true
                        sourceType = .camera
                    }
            }
            .font(.title)
            .foregroundColor(.blue)
            
            Rectangle()
                .strokeBorder()
                .foregroundColor(.black)
                .overlay(
                    Group {
                        if uiImage != nil {
                            Image(uiImage: uiImage!)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                )
            
            
            VStack{
                Button(action: {
                    if uiImage != nil {
                        classifier.detect(uiImage: uiImage!)
                    }
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title)
                }

                
                Group {
                    if let imageClass = classifier.imageClass {
                        HStack{
                            Text("Image categories:")
                                .font(.caption)
                            Text(imageClass)
                                .bold()
                        }
                    } else {
                        HStack {
                            Text("Image categories: N/A")
                                .font(.caption)
                        }
                    }
                
                }
                .font(.subheadline)
                .padding(3)
                
            }
        }
        .sheet(isPresented: self.$isPresenting){
            ImagePickerView(selectedImage: self.$uiImage, sourceType: self.$sourceType)
                .onDisappear{
                    if uiImage != nil {
                        classifier.detect(uiImage: uiImage!)
                    }
                }
            
        }
        .padding()
    }
}

//MARK: - Preview
struct RecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        RecognitionView(classifier: ImageClassifier())
    }
}
