//
//  Classifier.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 5/31/22.
//

import CoreML
import Vision
import CoreImage

struct Classifier {
    
//    private(set) var category: String?
//    private(set) var results: String?
    private(set) var results: String?
    private(set) var confidence: Float?
    private var confidenceString: String = ""
    
    mutating func detect(ciImage: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model)
        else {
            return
        }
        
        let request = VNCoreMLRequest(model: model)
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try? handler.perform([request])
        
        guard let results = request.results as? [VNClassificationObservation] else {

            return
        }
        
        
        if let firstResult = results.first {
            self.confidence = firstResult.confidence
        
            self.confidenceString = NSString(format: "%.3f", self.confidence!) as String
            
            self.results = firstResult.identifier
            
            self.results!.append("\nmodel confidence: \(self.confidenceString)")
            
//            self.results!.append(" with confidence: \(self.confidence!)")
//            self.results!.append("\(self.confidence!)")
//            print(self.results)
//            print(self.confidence)
           
        }
        
//        if let confidenceResult = results.first {
//            self.confidence = confidenceResult.confidence
//            self.results?.append(confidenceResult)
//            print(self.confidence)
//            print(self.results)
//        }
        
    }
    
}

