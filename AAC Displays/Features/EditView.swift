//
//  EditView.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 21/07/2023.
//

import SwiftUI

struct EditView: View {
    
    //MARK: - Properties
    @State private var pages: [Page] = [Page]()
    @State var enteredText: String = ""

    
    //MARK: - Body
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center) {
                
                Spacer()
                
                TextField("Enter text", text: $enteredText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 80))
                    .minimumScaleFactor(0.2)
                    .bold()
                    .submitLabel(.done)
                    .onSubmit {
                        print("Added text")
                    }
                
                Spacer()
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Button {
                        saveSelection(backgroundColour: "backgroundColour", enteredText: enteredText)
                    } label: {
                        Text("Save")
                    }
                    .font(.title2)
                    .bold()
                    
                }
            }
            .navigationTitle("Badge Edit View")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                load()
            }
        }
    }
    
    //MARK: - Functions
    func saveSelection(backgroundColour: String, enteredText: String) {
        print(backgroundColour, enteredText)
        
        let page = Page(id: UUID(), pageExpression: enteredText, backgroundColour: "backgroundColour")
        print(page)
        
        pages.append(page)
        print(pages)
        
        save()
        
        self.enteredText = ""

    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    
    func save() {
        do {
            print("")
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
                // Do nothing -- if all notes deleted or no notes yet
            }
        }
    }
    
}

//MARK: - Preview

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
