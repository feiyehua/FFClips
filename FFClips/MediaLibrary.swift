//
/*******************************************************************************

        File name:     MediaLibrary.swift
        Author:        FeiYehua

        Description:   Created for FFClips in 2025

        History:
                2025/4/20: File created.

********************************************************************************/
import SwiftUI
import AVKit

struct MediaLibrary: View {
    @Binding var mediaItems:[MediaItem]
    @Binding var selectedItem:MediaItem?
    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(mediaItems) { item in
                Image(uiImage: item.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity
                    )
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        item.type == .video
                            ? Image(
                                systemName: "play.circle.fill"
                            )
                            .foregroundColor(.white) : nil
                    )
                    .onTapGesture(perform: {
                        selectedItem = item
                    })
            }
        }
    }
}
