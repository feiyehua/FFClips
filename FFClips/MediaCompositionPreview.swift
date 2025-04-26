//
/*******************************************************************************

        File name:     MediaCompositionPreview.swift
        Author:        FeiYehua

        Description:   Created for FFClips in 2025

        History:
                2025/4/26: File created.

********************************************************************************/

import AVFoundation
import SwiftUI
import AVKit

struct MediaCompositionPreview: View {
    let importedMediaItems: [ImportedMediaItem]
    private var player: AVPlayer?
    init(importedMediaItems: [ImportedMediaItem],player:AVPlayer?=nil) {
        self.importedMediaItems = importedMediaItems
        let playerItem = AVPlayerItem(
            asset: composeVideo(importedMediaItems: importedMediaItems)
        )
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.isMuted=false
        self.player?.volume=0.5
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话配置失败: \(error.localizedDescription)")
        }
    }
    var body: some View {
        VideoPlayer(player: player)
    }

}

func composeVideo(importedMediaItems: [ImportedMediaItem]) -> AVComposition {
    let composition = AVMutableComposition()
    let timescale: Int32 = 600
    // 创建视频轨道
    guard
        let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
    else { return composition}
    importedMediaItems.forEach { importedMediaItem in
        if importedMediaItem.type == .video {

            importedMediaItem.clips.forEach { clip in
                
                // 获取源视频资源（例如从相册选择）
                let videoAsset = AVURLAsset(url: importedMediaItem.url)

                // 提取源视频轨道
                guard
                    let sourceVideoTrack = videoAsset.tracks(
                        withMediaType: .video
                    )
                    .first
                else { return }

                do {
                    // 将源视频插入到合成轨道中
                    try videoTrack.insertTimeRange(
                        CMTimeRange(
                            start: CMTimeMakeWithSeconds(
                                clip.start,
                                preferredTimescale: timescale
                            ),
                            duration: CMTimeMakeWithSeconds(
                                clip.duration,
                                preferredTimescale: timescale
                            )
                        ),
                        of: sourceVideoTrack,
                        at: CMTimeMakeWithSeconds(
                            clip.position,
                            preferredTimescale: timescale
                        )
                    )
                } catch {
                    print("插入视频失败: \(error)")
                }
            }
        } else if importedMediaItem.type == .audio {
            importedMediaItem.clips.forEach { clip in
                // 创建视频轨道
                guard
                    let audioTrack = composition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: kCMPersistentTrackID_Invalid
                    )
                else { return }

                // 获取源视频资源（例如从相册选择）
                let audioAsset = AVURLAsset(url: importedMediaItem.url)

                // 提取源视频轨道
                guard
                    let sourceAudioTrack = audioAsset.tracks(
                        withMediaType: .audio
                    )
                    .first
                else { return }

                do {
                    // 将源视频插入到合成轨道中
                    try audioTrack.insertTimeRange(
                        CMTimeRange(
                            start: CMTimeMakeWithSeconds(
                                clip.start,
                                preferredTimescale: timescale
                            ),
                            duration: CMTimeMakeWithSeconds(
                                clip.duration,
                                preferredTimescale: timescale
                            )
                        ),
                        of: sourceAudioTrack,
                        at: CMTimeMakeWithSeconds(
                            clip.position,
                            preferredTimescale: timescale
                        )
                    )
                } catch {
                    print("插入音频失败: \(error)")
                }
            }
        }
    }
    return composition
}
#Preview {
    //    MediaCompositionPreview()
}
