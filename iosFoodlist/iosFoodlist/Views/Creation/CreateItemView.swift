//
//  CreateItemView.swift
//  iosFoodlist
//
//  Created by Sarah Klocke on 12.07.22.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI
import sharedFoodlist

struct CreateItemView: View {
    var itemService: ItemService
    
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
                        itemService.createItem(name: self.name, description: self.description) { result, error in
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
                    Text("Gegenstand anlegen")
                }
            }
        }
    }
}

struct CreateItemView_Previews: PreviewProvider {
    static let storageUnitService = StorageUnitService()
    static let shelfService = storageUnitService.createShelfService(storageUnitId: 2)
    static let itemService = shelfService.createItemService(shelfId: 2)
    
    static var previews: some View {
        CreateItemView(itemService: itemService)
    }
}
