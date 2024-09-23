//
//  ImageClassification.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 5/31/22.
//

import SwiftUI

class ImageClassifier: ObservableObject {
    
    @Published private var classifier = Classifier()
    
    @Published var imageClassificationText = ""
    
    var imageClass: String? {
        classifier.results
    }
    
//    var imageConfidence: Float? {
//        classifier.confidence
//    }
//    func returnResultsString() {
//        imageClassificationText = ("Classification: \(classifier.results) - Confidence: \(classifier.confidence)")
//        print(imageClassificationText)
//    }
    

        
    // MARK: Intent(s)
    func detect(uiImage: UIImage) {
        guard let ciImage = CIImage (image: uiImage) else { return }
        classifier.detect(ciImage: ciImage)
        
    }
        
}
