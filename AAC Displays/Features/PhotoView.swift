//
//  PhotoView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 21/07/2023.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    
    //MARK: - Properties
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State var backgroundColour: Color = Color(red: 62/255, green: 139/255, blue: 69/255)
    @State var rotationAmount = 180.0
    
    @State private var randomCircle = Int.random(in: 12...16)
    @State private var isAnimating = false
    
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0...randomCircle, id: \.self) { item in
                        Image("sunflower")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48, alignment: .center)
                            .clipShape(Circle())
                            .frame(width: randomSize(), height: randomSize(), alignment: .center)
                            .scaleEffect(isAnimating ? randomScale() : 1)
                            .position(
                                x: randomCoordinate(max: geometry.size.width),
                                y: randomCoordinate(max: geometry.size.height)
                            )
                            .animation(
                                Animation.interpolatingSpring(stiffness: 0.5, damping: 0.5)
                                    .repeatForever()
                                    .speed(randomSpeed())
                                    .delay(randomDelay()),
                                value: isAnimating
                            )
                            .onAppear {
                                isAnimating = true
                            }
                            
                        
                        
//                        Circle()
//                            .foregroundColor(.gray)
//                            .opacity(0.15)
//                            .frame(width: randomSize(), height: randomSize(), alignment: .center)
//                            .scaleEffect(isAnimating ? randomScale() : 1)
//                            .position(
//                                x: randomCoordinate(max: geometry.size.width),
//                                y: randomCoordinate(max: geometry.size.height)
//                            )
//                            .animation(
//                                Animation.interpolatingSpring(stiffness: 0.5, damping: 0.5)
//                                    .repeatForever()
//                                    .speed(randomSpeed())
//                                    .delay(randomDelay()),
//                                value: isAnimating
//                            )
//                            .onAppear {
//                                isAnimating = true
//                            }
                    }
                    
                    
                    
                    VStack {
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 400)
                                .rotationEffect(.degrees(rotationAmount))
                        }
                    
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColour)
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        
                        ColorPicker("", selection: $backgroundColour)
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Text("Choose photo")
                                    .foregroundStyle(.black)
                                    .font(.largeTitle)
                                    .padding()
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    // Retrieve selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                    }
                                }
                            }
                        
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
    }
    
    //MARK: - Functions
    // 1. Random co-ordinate
    func randomCoordinate(max: CGFloat) -> CGFloat {
        return CGFloat.random(in: 0...max)
    }
    
    // 2. Random size
    func randomSize() -> CGFloat {
        return CGFloat(Int.random(in: 10...400))
    }
    
    // 3. Random scale
    func randomScale() -> CGFloat {
        return CGFloat(Double.random(in: 0.1...4.0))
    }
    
    // 4. Random speed
    func randomSpeed() -> Double {
        return Double.random(in: 0.5...1.0)
    }
    
    // 5. Random delay
    func randomDelay() -> Double {
        return Double.random(in: 0...2)
    }
    
    
}


//MARK: - Preview
struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
    }
}


