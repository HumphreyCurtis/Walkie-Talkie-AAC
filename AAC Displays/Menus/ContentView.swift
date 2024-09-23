//
//  ContentView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 20/07/2023.
//

import SwiftUI
struct ContentView: View {
    
    //MARK: - Properties
    @State private var layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    //MARK: - Background
    var body: some View {
        NavigationStack {
                LazyVGrid(columns: layout, spacing: 20) {
                    NavigationLink {
                        MenuView()
                    } label: {
                        VStack {
                            Image(systemName: "paintbrush")
                                .symbolRenderingMode(.monochrome)
                                .resizable()
                                .padding(10)
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.blue)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(15)
                                .overlay {
                                    Text("Custom Badges")
                                        .fontWeight(.bold)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .foregroundColor(.blue)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal, 10)
                                        .background(.ultraThinMaterial)
                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                        .padding()
                                }
                           
                        }
                    }
                    
                    NavigationLink {
                        PhotoView()
                    } label: {
                        Image(systemName: "tortoise")
                            .resizable()
                            .padding(10)
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.blue)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(15)
                            .overlay {
                                Text("Slow Sunflower")
                                    .fontWeight(.bold)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 10)
                                    .background(.ultraThinMaterial)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .padding()
                            }
                    }
                    
                    NavigationLink {
                       AttentionView(expression: "COULD YOU PLEASE LET ME HAVE YOUR SEAT? MANY THANKS! :)")
                    } label: {
                        Image(systemName: "flame")
                            .resizable()
                            .padding(10)
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.blue)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(15)
                            .overlay {
                                Text("Grab Attention")
                                    .fontWeight(.bold)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 10)
                                    .background(.ultraThinMaterial)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .padding()
                            }
                    }
                    
                    NavigationLink {
                        DialogueView()
                    } label: {
                        Image(systemName: "rectangle.3.group.bubble.left.fill")
                            .resizable()
                            .padding(10)
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.blue)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(15)
                            .overlay {
                                Text("Symbol Speak")
                                    .fontWeight(.bold)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 10)
                                    .background(.ultraThinMaterial)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .padding()
                            }
                    }
                    
                    NavigationLink {
                        RecognitionView(classifier: ImageClassifier())
                    } label: {
                        Image(systemName: "photo.artframe")
                            .resizable()
                            .padding(10)
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.blue)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(15)
                            .overlay {
                                Text("Photo to Speech")
                                    .fontWeight(.bold)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 7)
                                    .background(.ultraThinMaterial)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .padding()
                            }
                    }
                    
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .padding(10)
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.blue)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(15)
                            .overlay {
                                Text("Search Assistant")
                                    .fontWeight(.bold)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 5)
                                    .background(.ultraThinMaterial)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .padding()
                            }
                        
                    }
            }
            .navigationTitle("AAC Badge Menu")
            .navigationBarTitleDisplayMode(.inline)
            .padding(20)
        }
    }
}

//MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
