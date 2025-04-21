////
//    /*******************************************************************************
//
//            File name:     MediaTimeLine.swift
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
//import SwiftUI
//
//struct MediaTimeLine: View {
//    @State private var totalTime=60.0
//    @Binding var addedMediaItems:[MediaItem]
//    var body: some View {
////        ScrollView(.horizontal)
////        {
//            GeometryReader { proxy in
//                VStack
//                {
////                    HStack{
//////                        for i in stride(from:0.0,to:totalTime,by:1.0)
//////                        {
//////                            Rectangle()
//////                                .color(.black)
//////                        }
////                    }
//                    ForEach(addedMediaItems){item in
//                        Rectangle()
//                            .fill(.blue)
//                            .frame(width: 12.0/totalTime*proxy.size.width)
//                            .cornerRadius(5)
//                    }
//                }
//            }
////        }
//
//    }
//}
//
//#Preview {
////    MediaTimeLine()
//}

import SwiftUI

struct MediaTimelineView: View {
    @State private var totalDuration: Double = 60
    @State private var currentTime: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var scrollOffset: CGFloat = 0
    @State private var clips: [Clip] = [
        Clip(position: 10, duration: 5),
        Clip(position: 30, duration: 8),
    ]
    @State private var loc: CGFloat?
    @State private var xloc: CGFloat = 0

    private let playheadWidth: CGFloat = 2
    private let timelineHeight: CGFloat = 80

    private func timeString(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack {
            Text(timeString(currentTime))
                .font(.headline)
                .padding()
                .frame(height: 50)
            GeometryReader { proxy in
                ZStack {
                    VStack {
                        HStack(spacing: 0) {
                            ForEach(0..<Int(totalDuration)) { second in
                                VStack(spacing: 2) {
                                    Rectangle()
                                        .frame(
                                            width: 1,
                                            height: second % 5 == 0 ? 20 : 10
                                        )
                                        .foregroundColor(.gray)

                                    if second % 5 == 0 {
                                        Text("\(second)")
                                            .font(.system(size: 6))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 10 * scale)
                            }
                        }
                        .padding()
                        ScrollView(.vertical) {
                            VStack(spacing: 20) {
                                ForEach(clips) { clip in
                                    //                                Text("hello")
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.blue)
                                        .frame(
                                            width: clip.duration * 10 * scale,
                                            height: 10
                                        )
                                        .position(
                                            x: clip.position * 10 * scale + clip
                                                .duration * 10 * scale / 2 + 5,
                                            y: 5
                                        )
                                }
                            }
                        }
                        .frame(height: proxy.size.height-50)

                    }
                    .position(
                        x: xloc + totalDuration * 10 * 0.5 * scale + 0.5
                            * proxy.size.width - 5,
                        y: proxy.size.height
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                xloc =
                                    xloc
                                    + (value.location.x - value.startLocation.x)
                                    * 0.15 * scale
                                if xloc < -totalDuration * 10 * scale {
                                    xloc = -totalDuration * 10 * scale
                                }
                                if xloc > 0 {
                                    xloc = 0
                                }
                            }
                    )
                }
                .frame(
                    width: totalDuration * 10,
                    alignment: .center
                )
                
            }
            ZStack {

                // 固定播放头
                VStack {
                    Rectangle()
                        .frame(
                            width: playheadWidth
                        )
                        .frame(maxHeight: .infinity)
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        //        .frame(height: timelineHeight)
        //        .padding(.horizontal, 20)
    }
}

// MARK: - 视频片段组件
struct ClipView: View {
    let clip: Clip
    @Binding var scale: CGFloat
    let totalDuration: Double

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.blue)
                .frame(
                    width: CGFloat(clip.duration) * 50 * scale,
                    height: 40
                )
                .overlay(
                    Text("Clip \(clip.id)")
                        .font(.caption)
                        .foregroundColor(.white)
                )
                .offset(x: CGFloat(clip.position) * 50 * scale)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    // 实现片段拖拽逻辑
                }
        )
    }
}

// MARK: - 控制面板
struct ControlPanel: View {
    @Binding var currentTime: Double
    @Binding var scale: CGFloat
    let totalDuration: Double

    var body: some View {
        VStack {
            Slider(value: $currentTime, in: 0...totalDuration)
                .padding(.horizontal)

            HStack {
                Text("缩放: \(scale, specifier: "%.1f")x")
                Slider(value: $scale, in: 0.5...3.0)
                    .frame(width: 200)
            }
            .padding()
        }
    }
}

// MARK: - 数据模型
struct Clip: Identifiable {
    let id = UUID()
    var position: Double  // 起始时间（秒）
    var duration: Double  // 持续时间（秒）
}

// MARK: - 预览
struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        MediaTimelineView()
    }
}
