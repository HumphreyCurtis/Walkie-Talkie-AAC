//
//  MenuView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 21/07/2023.
//

import SwiftUI

struct MenuView: View {
    
//    @State private var pages = ["Stroke"]
//    @State private var pageExpression: [String : String] = ["Stroke" : "I have had a stroke."]
//    @State private var pageBackground: [String : Color] = ["Stroke" : Color.yellow]
   //MARK: - Properties
    @State private var pages: [Page] = [Page]()
    @State private var searchText = ""
   
    //MARK: - Body
    var body: some View {
        NavigationView {
            List {
                if pages.count >= 1 {
                    ForEach(0..<pages.count, id: \.self) { i in
                        NavigationLink(destination: DisplayView(expression: pages[i].pageExpression, backgroundColour: Color.red))
                        {
                            HStack {
                                Text(pages[i].pageExpression)
                                    .padding(.leading, 5)
                                    .bold(true)
                            }
                        }
                        
                    }
                    .onDelete(perform: delete)
                    
                }
                
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: EditView()) {
                        Text("Add")
                            .font(.title2)
                            .bold()
                    }
                }
            }
            .navigationTitle("Your AAC Displays")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                load()
            }
        
        }
    }
    
    //MARK: - Functions
    func delete(at offsets: IndexSet) {
        pages.remove(atOffsets: offsets)
        save()
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    
    func save() {
        do {
            print(pages)
            let data = try JSONEncoder().encode(pages)
            let url = getDocumentDirectory().appendingPathComponent("aacPages")
            try data.write(to: url)
            
        } catch {
            print("Saving data has failed!")
        }
    }
    
    
    func load() {
        DispatchQueue.main.async {
            do {
                let url = getDocumentDirectory().appendingPathComponent("aacPages")
                let data = try Data(contentsOf: url)
                pages = try JSONDecoder().decode([Page].self, from: data)
                print(pages)
                
            } catch {
                print("Not loading")
                // Do nothing -- if all notes deleted or no notes yet
            }
        }
    }
    

}

//MARK: - Preview
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
