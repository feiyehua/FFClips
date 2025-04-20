////
//    /*******************************************************************************
//            
//            File name:     MediaClip.swift
//            Author:        FeiYehua
//            
//            Description:   Created for FFClips in 2025
//            
//            History:
//                    2025/4/20: File created.
//            
//    ********************************************************************************/
//    
//
//
//import SwiftUI
//import AVKit
//
//// 媒体剪辑数据模型
//struct MediaClip: Identifiable {
//    let id = UUID()
//    let url: URL
//    var thumbnail: UIImage?
//    var duration: Double
//    var isInTimeline = false
//}
//
//
//// 主视图
//struct VideoEditorView: View {
//    @State private var mediaClips: [MediaClip]
//    @State private var timelineClips: [MediaClip] = []
//    @State private var selectedClip: MediaClip?
//    @State private var player: AVPlayer?
//    
//    init(mediaURLs: [URL]) {
//        _mediaClips = State(initialValue: mediaURLs.map { url in
//            MediaClip(url: url, thumbnail: nil, duration: 0)
//        })
//        
//        // 异步加载媒体元数据
//        loadMediaMetadata()
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // 视频预览区域
//            PreviewPlayerView(player: $player)
//                .frame(height: 300)
//                .background(Color.black)
//            
//            // 时间轴区域
//            TimelineView(clips: $timelineClips) { clip in
//                selectClip(clip)
//            }
//            .frame(height: 120)
//            .background(Color(.systemGray6))
//            
//            // 媒体库区域
//            MediaLibraryView(clips: $mediaClips) { clip in
//                addToTimeline(clip)
//            }
//            .frame(height: 160)
//            
//            Spacer()
//        }
//        .onAppear(perform: setupPlayer)
//    }
//    
//    private func loadMediaMetadata() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            for index in mediaClips.indices {
//                let asset = AVAsset(url: mediaClips[index].url)
//                let duration = asset.duration.seconds
//                
//                // 生成缩略图
//                let generator = AVAssetImageGenerator(asset: asset)
//                generator.appliesPreferredTrackTransform = true
//                let time = CMTime(seconds: 0, preferredTimescale: 600)
//                
//                if let image = try? generator.copyCGImage(at: time, actualTime: nil) {
//                    let thumbnail = UIImage(cgImage: image)
//                    
//                    DispatchQueue.main.async {
//                        mediaClips[index].thumbnail = thumbnail
//                        mediaClips[index].duration = duration
//                    }
//                }
//            }
//        }
//    }
//    
//    private func setupPlayer() {
//        // 初始化播放器逻辑
//    }
//    
//    private func addToTimeline(_ clip: MediaClip) {
//        var newClip = clip
//        newClip.isInTimeline = true
//        timelineClips.append(newClip)
//    }
//    
//    private func selectClip(_ clip: MediaClip) {
//        selectedClip = clip
//        player = AVPlayer(url: clip.url)
//        player?.play()
//    }
//}
//
//// 预览播放器组件
//struct PreviewPlayerView: UIViewControllerRepresentable {
//    @Binding var player: AVPlayer?
//    
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let controller = AVPlayerViewController()
//        controller.player = player
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        uiViewController.player = player
//    }
//}
//
//// 时间轴组件
//struct TimelineView: View {
//    @Binding var clips: [MediaClip]
//    let onSelect: (MediaClip) -> Void
//    
//    var body: some View {
//        ScrollView(.horizontal) {
//            HStack(spacing: 4) {
//                ForEach(clips) { clip in
//                    TimelineClipView(clip: clip)
//                        .onTapGesture { onSelect(clip) }
//                        .dragable { clip }
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//// 媒体库组件
//struct MediaLibraryView: View {
//    @Binding var clips: [MediaClip]
//    let onAdd: (MediaClip) -> Void
//    
//    var body: some View {
//        ScrollView(.horizontal) {
//            HStack(spacing: 10) {
//                ForEach(clips) { clip in
//                    if !clip.isInTimeline {
//                        MediaThumbnailView(clip: clip)
//                            .onTapGesture { onAdd(clip) }
//                    }
//                }
//            }
//            .padding()
//        }
//        .background(Color(.systemBackground))
//    }
//}
//
//// 时间轴剪辑视图
//struct TimelineClipView: View {
//    let clip: MediaClip
//    
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            if let thumbnail = clip.thumbnail {
//                Image(uiImage: thumbnail)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 80, height: 80)
//                    .cornerRadius(8)
//            } else {
//                ProgressView()
//                    .frame(width: 80, height: 80)
//            }
//            
//            Text(timeString(clip.duration))
//                .font(.caption)
//                .foregroundColor(.white)
//                .padding(4)
//                .background(Color.black.opacity(0.7))
//                .cornerRadius(4)
//        }
//    }
//    
//    private func timeString(_ seconds: Double) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .positional
//        formatter.allowedUnits = [.minute, .second]
//        return formatter.string(from: seconds) ?? "0:00"
//    }
//}
//
//// 媒体缩略图视图
//struct MediaThumbnailView: View {
//    let clip: MediaClip
//    
//    var body: some View {
//        VStack {
//            if let thumbnail = clip.thumbnail {
//                Image(uiImage: thumbnail)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 100)
//                    .cornerRadius(8)
//            } else {
//                ProgressView()
//                    .frame(width: 100, height: 100)
//            }
//        }
//    }
//}
//
//// 拖拽修饰符
//extension View {
//    func dragable<T: Transferable>(_ data: @escaping () -> T) -> some View {
//        self.modifier(DragModifier(data: data))
//    }
//}
//
//struct DragModifier<T: Transferable>: ViewModifier {
//    let data: () -> T
//    
//    func body(content: Content) -> some View {
//        content
//            .onDrag { NSItemProvider(object: data()) }
//    }
//}
//
//// 使用示例
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let urls = [
//            URL(string: "file:///video1.mp4")!,
//            URL(string: "file:///video2.mp4")!,
//            URL(string: "file:///video3.mp4")!
//        ]
//        VideoEditorView(mediaURLs: urls)
//    }
//}
