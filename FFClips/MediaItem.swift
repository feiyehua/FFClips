//
/*******************************************************************************

        File name:     MediaItem.swift
        Author:        FeiYehua

        Description:   Created for FFClips in 2025

        History:
                2025/4/19: File created.

********************************************************************************/

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct MediaItem: Identifiable {
    let id = UUID()
    let thumbnail: UIImage
    let url: URL?
    let type: MediaType

    enum MediaType {
        case image, video
    }
}

struct MediaPickerView: View {
    @State var selectedItems: [PhotosPickerItem] = []
    @State private var mediaItems = [MediaItem]()
    @State private var showImportMenu = false
    @State private var selectedPicker: PickerType?
    @State private var showPhotoPicker = false
    @State private var showFilerPicker = false
//    var handlePickedPDF: (URL) -> Void
    
    enum PickerType {
        case photoLibrary, files
    }

    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        NavigationView {
            ScrollView {
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
                                    ? Image(systemName: "play.circle.fill")
                                        .foregroundColor(.white) : nil
                            )
                    }
                }
            }
            .navigationTitle("Media Gallery")
            .toolbar {
                Menu {
                    Button(action: {
                        showPhotoPicker.toggle()
                    }) {
                        Label(
                            "Select from photo library",
                            systemImage: "photo.badge.plus.fill"
                        )
                    }
                    Button(action: {
                        showFilerPicker.toggle()
                    }) {
                        Label(
                            "Select from files",
                            systemImage: "folder.badge.plus"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedItems,
            matching: .images
        )
        .fileImporter(
            isPresented: $showFilerPicker,
            allowedContentTypes: [.image,.mp3,.video],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let files):
                files.forEach { file in
                    // gain access to the directory
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    // access the directory URL
                    // (read templates in the directory, make a bookmark, etc.)
//                    handlePickedPDF(file)
                    print(file.absoluteString)
                    // release access
                    file.stopAccessingSecurityScopedResource()
                }
            case .failure(let error):
                // handle error
                print(error)
            }
        }

    }
}

// MARK: - Photo Library Picker
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var mediaItems: [MediaItem]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .any(of: [.videos, .images])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker

        init(parent: PhotoLibraryPicker) {
            self.parent = parent
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            picker.dismiss(animated: true)

            for result in results {
                let itemProvider = result.itemProvider

                if itemProvider.hasItemConformingToTypeIdentifier(
                    UTType.image.identifier
                ) {
                    loadImage(from: itemProvider)
                } else if itemProvider.hasItemConformingToTypeIdentifier(
                    UTType.movie.identifier
                ) {
                    loadVideo(from: itemProvider)
                }
            }
        }

        private func loadImage(from itemProvider: NSItemProvider) {
            itemProvider.loadObject(ofClass: UIImage.self) {
                [weak self] object, error in
                if let image = object as? UIImage {
                    let mediaItem = MediaItem(
                        thumbnail: image,
                        url: nil,
                        type: .image
                    )
                    DispatchQueue.main.async {
                        self?.parent.mediaItems.append(mediaItem)
                    }
                }
            }
        }

        private func loadVideo(from itemProvider: NSItemProvider) {
            itemProvider.loadFileRepresentation(
                forTypeIdentifier: UTType.movie.identifier
            ) { [weak self] url, error in
                guard let url = url else { return }

                // Generate thumbnail
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
                        self?.parent.mediaItems.append(mediaItem)
                    }
                } catch {
                    print("Error generating thumbnail: \(error)")
                }
            }
        }
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var mediaItems: [MediaItem]

    func makeUIViewController(context: Context)
        -> UIDocumentPickerViewController
    {
        let types: [UTType] = [.image, .movie]
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: types
        )
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(
            _ controller: UIDocumentPickerViewController,
            didPickDocumentsAt urls: [URL]
        ) {
            for url in urls {
                if url.isImage {
                    loadImage(from: url)
                } else if url.isVideo {
                    loadVideo(from: url)
                }
            }
        }

        private func loadImage(from url: URL) {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    let mediaItem = MediaItem(
                        thumbnail: image,
                        url: url,
                        type: .image
                    )
                    DispatchQueue.main.async {
                        self.parent.mediaItems.append(mediaItem)
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }

        private func loadVideo(from url: URL) {
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
                    self.parent.mediaItems.append(mediaItem)
                }
            } catch {
                print("Error generating thumbnail: \(error)")
            }
        }
    }
}

// MARK: - Extensions
extension URL {
    var isImage: Bool {
        let imageTypes = ["jpg", "jpeg", "png", "gif", "heic"]
        return imageTypes.contains(self.pathExtension.lowercased())
    }

    var isVideo: Bool {
        let videoTypes = ["mov", "mp4", "avi", "m4v"]
        return videoTypes.contains(self.pathExtension.lowercased())
    }
}

extension MediaPickerView.PickerType: Identifiable {
    var id: Self { self }
}

#Preview {
    MediaPickerView()
}
