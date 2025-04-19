//
    /*******************************************************************************
            
            File name:     PhotosSelector.swift
            Author:        FeiYehua
            
            Description:   Created for FFClips in 2025
            
            History:
                    2025/4/18: File created.
            
    ********************************************************************************/
    


//
    /*******************************************************************************
            
            File name:     PhotosSelector.swift
            Author:        FeiYehua
            
            Description:   Created for FFClips in 2025
            
            History:
                    2025/4/18: File created.
            
    ********************************************************************************/
    


import SwiftUI
import PhotosUI


struct PhotosSelector: View {
    @Binding var selectedItems: [PhotosPickerItem]


    var body: some View {
        PhotosPicker(selection: $selectedItems,
                     matching: .any(of: [.bursts,.cinematicVideos,.depthEffectPhotos,.images,.livePhotos,.panoramas,.screenRecordings,.screenshots,.slomoVideos,.timelapseVideos,.videos])) {
//                    Image(systemName: "photo.on.rectangle.angled")
//            Button()
            Button("Select Multiple Photos"){}
        }
                     .photosPickerStyle(.inline)
    }
}

