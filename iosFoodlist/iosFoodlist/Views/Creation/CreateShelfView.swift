//
//  CreateShelfView.swift
//  iosFoodlist
//
//  Created by Sarah Klocke on 12.07.22.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI
import sharedFoodlist

struct CreateShelfView: View {
    var shelfService: ShelfService
    
    @Environment(\.dismiss) var dismiss
    
    @State var name = ""
    @State var description = ""
    @State var errorMessage = ""
    @State var formInvalid = false
    
    func validateForm() -> Bool {
        if (name.count > 25) {
            errorMessage = "Der Names des Fachs darf maximal 25 Zeichen lang sein."
            return false
        }
        
        errorMessage = ""
        return true
    }
    
    var body: some View {
        Form {
            Section {
                VStack {
                    TextField("Name", text: $name)
                }
            } header: {
                Text("GENERAL")
            }
            
            Section {
                TextEditor(text: $description)
            } header: {
                Text("DESCRIPTION")
            }
            
            Section {
                Button {
                    self.formInvalid = !validateForm()
                    
                    if (!self.formInvalid) {
                        shelfService.createShelf(name: self.name, description: self.description) { result, error in
                            if result != nil {
                                DispatchQueue.main.async {
                                    dismiss()
                                }
                            } else {
                                self.errorMessage = error!.localizedDescription.trimmingCharacters(in: CharacterSet.init(charactersIn: "\""))
                                self.formInvalid = true
                            }
                        }
                    }
                } label: {
                    Text("Fach anlegen")
                }
            }
        }
    }
}

struct CreateShelfView_Previews: PreviewProvider {
    static let storageUnitService = StorageUnitService()
    static let shelfService = storageUnitService.createShelfService(storageUnitId: 2)
    
    static var previews: some View {
        CreateShelfView(shelfService: shelfService)
    }
}
