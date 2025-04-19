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
    var body: some View {
        MediaPickerView()
    }
}

#Preview {
    ContentView()
}
