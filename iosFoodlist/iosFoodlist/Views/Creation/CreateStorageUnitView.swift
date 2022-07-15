//
//  CreateStorageUnitView.swift
//  iosFoodlist
//
//  Created by Sarah Klocke on 11.07.22.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI
import sharedFoodlist

struct CreateStorageUnitView: View {
    var storageUnitService: StorageUnitService
    
    @Environment(\.dismiss) var dismiss
    
    @State var name = ""
    @State var description = ""
    @State var storageType = StorageType.shelf
    @State var errorMessage = ""
    @State var formInvalid = false
    
    func validateForm() -> Bool {
        if (name.count > 25) {
            errorMessage = "Der Regalname darf maximal 25 Zeichen lang sein."
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
                
                Picker("Typ", selection: $storageType) {
                    Text("Regal").tag(StorageType.shelf)
                    Text("Kühlschrank").tag(StorageType.refrigerator)
                    Text("Tiefkühlschrank").tag(StorageType.freezer)
                }
                .pickerStyle(.segmented)
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
                        storageUnitService.createStorageUnit(name: self.name, description: self.description, storageType: self.storageType) { result, error in
                            if result != nil {
                                dismiss()
                            } else {
                                self.errorMessage = error!.localizedDescription.trimmingCharacters(in: CharacterSet.init(charactersIn: "\""))
                                self.formInvalid = true
                            }
                        }
                    }
                } label: {
                    Text("Regal anlegen")
                }
            }
        }
        .navigationTitle("Neues Regal anlegen")
        .alert(errorMessage, isPresented: $formInvalid) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct CreateStorageUnitView_Previews: PreviewProvider {
    static let storageUnitService = StorageUnitService()
    
    static var previews: some View {
        CreateStorageUnitView(storageUnitService: storageUnitService)
    }
}
