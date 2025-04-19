//
    /*******************************************************************************
            
            File name:     ContentView.swift
            Author:        FeiYehua
            
            Description:   Created for FFClips in 2025
            
            History:
                    2025/4/18: File created.
            
    ********************************************************************************/
    

//import SwiftUI
//import PhotosUI
//
//struct ContentView: View {
//    @State var selectedItems: [PhotosPickerItem] = []
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//        PhotosSelector(selectedItems: $selectedItems)
//    }
//}
//
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()

    var body: some View {
        NavigationStack {
            MediaPickerView()
            ScrollView {
                LazyVStack {
                    ForEach(0..<selectedImages.count, id: \.self) { i in
                        selectedImages[i]
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                }
            }
            .toolbar {
                PhotosPicker("Select images", selection: $selectedItems, matching: .images)
            }
            .onChange(of: selectedItems) {
                Task {
                    selectedImages.removeAll()

                    for item in selectedItems {
                        if let image = try? await item.loadTransferable(type: Image.self) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
