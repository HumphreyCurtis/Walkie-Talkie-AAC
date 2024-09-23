//
//  MenuView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 21/07/2023.
//

import SwiftUI

struct MenuViewOld: View {
    
    @State private var pages = ["Stroke"]
    @State private var pageExpression: [String : String] = ["Stroke" : "I have had a stroke."]
    @State private var pageBackground: [String : Color] = ["Stroke" : Color.yellow]
    
    @State private var pagesData: [Page] = [Page]()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(pages, id: \.self) { page in
                    NavigationLink {
                        DisplayView(expression: pageExpression[page]!, backgroundColour: pageBackground[page]!)
                    } label: {
                        Text(page)
                    }
                }
                .onDelete(perform: delete(at:))
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: EditView()) {
                        Text("Add")
                            .font(.title2)
                            .bold()
                    }
                    NavigationLink(destination: SearchView()) {
                        Text("Search")
                            .font(.title2)
                            .bold()
                    }
                }
            }
            .navigationTitle("AAC Displays")
            .navigationBarTitleDisplayMode(.inline)
        
        }
    }
    
    func delete(at offsets: IndexSet) {
        pages.remove(atOffsets: offsets)
    }
}

struct MenuViewOld_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
