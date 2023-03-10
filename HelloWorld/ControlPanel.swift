//
//  ContentView.swift
//  HelloWorld
//
//  Created by Ben on 2022/5/29.
//

import SwiftUI
import MediaPlayer

struct ControlPanel: View {
    @State private var count = 0
    @State var isDark = false
    @State var immersed = false
    
    
//    struct LightDarkSwitcher: View {
//
//        var body: some View {
//            Button(role: .none) {
//                isDark = !isDark
//            } label: {
//                Text("Reset").frame(width: 150)
//            }.font(.title).buttonStyle(.bordered).buttonBorderShape(.capsule)
//                .controlSize(.large)
//        }
//    }

    struct TimerView: View {
        @State private var timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
        @State private var countNum = 0.0
        @State private var running = false
        var body: some View {
            VStack(spacing: 50) {
                Text("\(String(format: "%.02f", countNum))").fontWeight(.bold)
                    .font(.system(size: 60).monospacedDigit())
                    .bold()
                    .onReceive(timer) { _ in
                        if !running {
                            return
                        }
                        if countNum > 0 {
                            countNum += 0.01
                        } else if countNum == 0 {
                            countNum += 1
                        }
                    }

                if running {
                    Button(role: .none) {
                        running = !running
                    } label: {
                        Image(systemName: "pause.fill")
                        Text("Pause").frame(width: 150)
                    }.font(.title).buttonStyle(.borderedProminent).buttonBorderShape(.capsule)
                        .tint(.orange)
                        .minimumScaleFactor(0.3)
                        .controlSize(.large)
                } else {
                    HStack {
                        Button(role: .none) {
                            running = !running
                        } label: {
                            Image(systemName: "play.fill")
                            if countNum != 0.0 {
                                Text("Resume").frame(width: 100).lineLimit(1)
                            } else {
                                Text("Start").frame(width: 150).lineLimit(1)
                            }
                        }.font(.title).buttonStyle(.borderedProminent).buttonBorderShape(.capsule)
                            .controlSize(.large)
                            .minimumScaleFactor(0.3)
                            .tint(countNum == 0.0 ?.blue : .green)

                        if countNum != 0.0 {
                            Button(role: .none) {
                                running = false
                                countNum = 0.0
                            } label: {
                                Image(systemName: "stop.fill")
                                Text("Stop").frame(width: 100).lineLimit(1)
                            }.font(.title).buttonStyle(.borderedProminent).buttonBorderShape(.capsule)
                                .tint(.red)
                                .minimumScaleFactor(0.3)
                                .controlSize(.large)
                        }
                    }
                }
            }.animation(.easeInOut(duration: 0.5), value: 1).transition(.slide)
        }
    }
    
    struct TimeDateView : View {
        func currentDate() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy. MM. dd"
            let datetime = formatter.string(from: Date())
            return datetime
        }
        @State private var timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
        @State private var curTime = ""
        @State private var isPortrait: Bool = (UIScreen.main.bounds.height > UIScreen.main.bounds.width) // ?????????????????????????????????
        private let orientationPublisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)

        func currentTime() -> String {
            let formatter = DateFormatter()
            //        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:
            formatter.dateFormat = "HH mm ss"
            let datetime = formatter.string(from: Date())
            return datetime
        }
        
        var body: some View {
            ZStack() {
                // ????????????
                Text(currentDate())
                    .font(.system(size: 20))
                    .fontWeight(.light)
                    .foregroundColor(Color.gray)
                    .offset(y: -100)
                
                // ????????????
                Text(curTime)
                    .font(.system(size: isPortrait ? 90 : 160)
                        .monospacedDigit()
                    )
                    .fontWeight(.ultraLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .shadow(color: Color.gray.opacity(0.2), radius: 0.1, x: 1, y : 1)
                    .foregroundColor(Color("AccentColor"))
//                    .foregroundColor(Color.blue)
                //                .textFieldStyle(.automatic)
                //                .border(.green, width: 1.0)
                //                .bold()
                    .onReceive(timer) { _ in
                        curTime = currentTime()
                    }
                    .onReceive(orientationPublisher) { _ in
                        switch UIDevice.current.orientation {
                        case .portrait:
                            self.isPortrait = true
                        case .landscapeLeft, .landscapeRight:
                            self.isPortrait = false
                        default:
                            break
                        }
                    }
            }
        }
    }

    
    struct BatteryView : View {
        var body: some View {
            Text("Battery:" + String(getBattery()))
                .font(.system(size: 20))
                .fontWeight(.light)
                .foregroundColor(Color.gray)
                .monospacedDigit()
        }
        
        func getBattery() -> Int {
            //??????isBatteryMonitoringEnabled
            UIDevice.current.isBatteryMonitoringEnabled = true
         
            //???????????????????????????Float??????????????????0-1???????????????100??????????????????????????????
            let batterylevel = Int(UIDevice.current.batteryLevel * 100)
            
            //????????????????????????
            return batterylevel
        }
    }
    
    // ??????????????????
    struct VolumeView : View {
        var body: some View {
            HStack {
                // ??????-
                Button(role: .none) {
                    MPVolumeView.setVolume(false)
                } label: {
                    Image(systemName : "volume.1.fill")
                }.padding(40)
                // ??????+
                Button(role: .none) {
                    MPVolumeView.setVolume(true)
                } label: {
                    Image(systemName : "volume.3.fill")
                }
            }
            .font(.system(size: 40))
            .shadow(color: Color.gray.opacity(0.2), radius: 0.1, x: 1.5, y : 1.5)
            .controlSize(.large)
            
        }
    }
    

    

    var body: some View {
        // ??????????????????????????????"\(Date())"

        ZStack(alignment : .bottomTrailing) {
            // ??????????????????
            TabView {
                // ??????????????????
                TimeDateView().frame(maxWidth: .infinity, maxHeight: .infinity)
                // ???????????????
                TimerView()
                
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // ????????????
            BatteryView().frame(maxWidth: .infinity, maxHeight: .infinity).offset(x: 0, y: 130)
            
            
            if (!immersed) {
                // ??????????????????
                VolumeView().offset(x: -100, y: -100)
                
                // ???????????????
                Button(role: .none) {
                    isDark = !isDark
                } label: {
                    if (isDark) {
                        Image(systemName : "sun.max.circle.fill").tint(Color.orange)
                    } else {
                        Image(systemName : "moon.circle.fill")
                    }
                }
                .font(.system(size: 50))
                .offset(x: -30, y: -30)
                .shadow(color: Color.gray.opacity(0.2), radius: 0.1, x: 1.5, y : 1.5)
                //                .border(Color.red)
                //                .buttonStyle(.bordered)
                //                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
        }
        .edgesIgnoringSafeArea(.all) // ??????????????????
        .background(Color(.secondarySystemFill))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .animation(.easeInOut(duration: 1), value: count)
        .animation(.easeInOut(duration: 0.5), value: 1).transition(.scale)
        .preferredColorScheme(isDark ?.dark : .light)
        .statusBar(hidden: immersed ? true: false)
        .onTapGesture {
            immersed = !immersed
        }
        .animation(.easeInOut(duration: 0.5), value: 1).transition(.scale)
    }
}

struct ContentView_Previews1: PreviewProvider {
    static var previews: some View {
        ControlPanel()
    }
}

//Update system volume
extension MPVolumeView {
    
    static func setVolume(_ isRaise: Bool) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            if (isRaise) {
                slider?.value +=  0.1
            } else {
                slider?.value -=  0.1
            }
        }
    }
}
