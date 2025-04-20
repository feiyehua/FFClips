//
/*******************************************************************************

        File name:     MediaItem.swift
        Author:        FeiYehua

        Description:   Created for FFClips in 2025

        History:
                2025/4/19: File created.

********************************************************************************/

import AVKit
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct MediaItem: Identifiable {
    let id = UUID()
    let thumbnail: UIImage
    let url: URL
    let type: MediaType

    enum MediaType {
        case image, video
    }
}

struct MediaPickerView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var mediaItems = [MediaItem]()
    @State private var showImportMenu = false
    @State private var selectedPicker: PickerType?
    @State private var showPhotoPicker = false
    @State private var showFilerPicker = false
    @State private var selectedItem: MediaItem?
    // MARK: - getURL
    func getURL(
        item: PhotosPickerItem,
        completionHandler: @escaping (_ result: Result<URL, Error>) -> Void
    ) {
        // Step 1: Load as Data object.
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let contentType = item.supportedContentTypes.first {
                    // Step 2: make the URL file name and a get a file extention.
                    let url = getDocumentsDirectory().appendingPathComponent(
                        "\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")"
                    )
                    if let data = data {
                        do {
                            // Step 3: write to temp App file directory and return in completionHandler
                            try data.write(to: url)
                            completionHandler(.success(url))
                        } catch {
                            completionHandler(.failure(error))
                        }
                    }
                }
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }

    /// from: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    func loadFromURL(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                let mediaItem = MediaItem(
                    thumbnail: image,
                    url: url,
                    type: .image
                )
                DispatchQueue.main.async {
                    mediaItems.append(mediaItem)
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }

        // 使用和照片库相同的缩略图生成逻辑
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try generator.copyCGImage(
                at: CMTime(seconds: 0, preferredTimescale: 60),
                actualTime: nil
            )
            let thumbnail = UIImage(cgImage: cgImage)

            let mediaItem = MediaItem(
                thumbnail: thumbnail,
                url: url,
                type: .video
            )
            DispatchQueue.main.async {
                mediaItems.append(mediaItem)
            }
        } catch {
            print("Error generating thumbnail: \(error)")
        }
    }

    enum PickerType {
        case photoLibrary, files
    }


    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                VStack {
                    HStack {
                        if let noneEmptySelectedItem = selectedItem {
                            switch noneEmptySelectedItem.type {
                            case .image:
                                Image(uiImage: noneEmptySelectedItem.thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                            case .video:
                                let videoUrl = noneEmptySelectedItem.url
                                VideoPlayer(
                                    player: AVPlayer(
                                        url: videoUrl
                                    )
                                )

                            }
                        } else {
                            VStack {
                                Image(systemName: "questionmark.folder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                                Text("Select a image or video to preview")
                            }
                        }
                    }
                    .frame(height: proxy.size.height / 3)
                    MediaLibrary(mediaItems:$mediaItems,selectedItem:$selectedItem)
                    .navigationTitle("Media Gallery")
                    .toolbar(content: {
                        ToolbarItem(placement: .topBarLeading) {
                            Menu {
                                Button(action: {
                                    showPhotoPicker.toggle()
                                }) {
                                    Label(
                                        "From photo library",
                                        systemImage: "photo.badge.plus.fill"
                                    )
                                }
                                Button(action: {
                                    showFilerPicker.toggle()
                                }) {
                                    Label(
                                        "From files",
                                        systemImage: "folder.badge.plus"
                                    )
                                }
                            } label: {
                                Image(systemName: "rectangle.stack.badge.plus")
                                    .font(.title2)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    })
                }
                .photosPicker(
                    isPresented: $showPhotoPicker,
                    selection: $selectedItems
                )
                .onChange(of: selectedItems) {
                    Task {
                        for item in selectedItems {
                            getURL(item: item) { result in
                                switch result {
                                case .success(let url):
                                    print(url)
                                    loadFromURL(url: url)

                                case .failure(_):
                                    print("fail to read media url")
                                }
                            }
                        }
                    }
                }
                .fileImporter(
                    isPresented: $showFilerPicker,
                    allowedContentTypes: [.image, .mp3, .video],
                    allowsMultipleSelection: true
                ) { result in
                    switch result {
                    case .success(let files):
                        files.forEach { file in
                            print(file.absoluteString)
                            loadFromURL(url: file.absoluteURL)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

#Preview {
    MediaPickerView()
}
