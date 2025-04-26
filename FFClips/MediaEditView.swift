//
/*******************************************************************************

        File name:     MediaEditView.swift
        Author:        FeiYehua

        Description:   Created for FFClips in 2025

        History:
                2025/4/25: File created.

********************************************************************************/

import AVKit
import SwiftUI

struct MediaEditView: View {
    @Binding var mediaItems: [MediaItem]
    @State private var importedMediaItems: [ImportedMediaItem] = []
    @State private var selectedItem: MediaItem? = nil
    @State private var currentTime: Double = 0
    var body: some View {
        GeometryReader { proxy in
            VStack {
                MediaTimelineView(currentTime: $currentTime,importedMediaItems: $importedMediaItems)
                MediaLibrary(
                    mediaItems: $mediaItems,
                    selectedItem: $selectedItem
                )
                .onChange(
                    of: selectedItem,
                    {
                        let _importedMediaItem = ImportedMediaItem(
                            url: selectedItem!.url,
                            type: selectedItem!.type,
                            clips: [
                                Clip(
                                    isSelected: false,
                                    position: 0.0,
                                    start: 0.0,
                                    duration: selectedItem!.duration,
                                )
                            ]
                        )
                        importedMediaItems.append(_importedMediaItem)
                    }
                )
                .frame(height: proxy.size.height / 3)
            }

        }
    }
}
