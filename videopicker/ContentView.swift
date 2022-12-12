//
//  ContentView.swift
//  videopicker
//
//  Created by Angel Dev on 11/30/22.
//

import SwiftUI
import MobileCoreServices
import DKImagePickerController
import Photos
import AVKit


struct ContentView: View {
    
    @State var isShowPicker = false
    @State var imageImBlackBox = UIImage()
    @State var assets = [DKAsset]()
    @State var videoUrl = URL(string: "https://swiftanytime-content.s3.ap-south-1.amazonaws.com/SwiftUI-Beginner/Video-Player/iMacAdvertisement.mp4")!
//    @State var player = AVPlayer(url: URL(string: "https://swiftanytime-content.s3.ap-south-1.amazonaws.com/SwiftUI-Beginner/Video-Player/iMacAdvertisement.mp4")!)
    @State var player = AVPlayer()
    @State var isPlaying: Bool = false

    
    func addObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notif in
            player.seek(to: .zero)
            player.play()
        }
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self,  name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    var body: some View {
        VStack {

            if assets.count > 0 {
//                VideoPlayer(player: player)
                VideoPlayer(player: AVPlayer(url: videoUrl))
                    .frame(width: 400, height: 300, alignment: .center)
                    .onAppear {
//                        player = AVPlayer(url: videoUrl)
//                        player.seek(to: .zero)
//                        player.play()
                        print("videoUrl====>" + videoUrl.absoluteString)
                    }
//                    .onAppear {addObserver()}
//                    .onDisappear {removeObserver()}
            }

            
            Button {
                print("button click")
                isShowPicker.toggle()
            } label: {
                Text("Select video")
                    .font(.system(size: 32))
            }
            .padding([.top], 15)

        }
        .padding()
        .fullScreenCover(isPresented: $isShowPicker) {
            DKVideoPickerView(isPresented: $isShowPicker, selectedAssets: $assets, videoUrl: $videoUrl)
        }
//        .sheet(isPresented: $isShowPicker) {
////            VideoPickerView(isPresented: $isShowPicker, selectedImage: $imageImBlackBox)
//            DKVideoPickerView(isPresented: $isShowPicker, selectedAssets: $assets)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct DKVideoPickerView: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    @Binding var selectedAssets: [DKAsset]
    @Binding var videoUrl: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DKVideoPickerView>) -> UIViewController {
        let backgroundColor = UIColor.systemBackground
        let titleColor = UIColor.tintColor
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.backgroundColor = backgroundColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
//        let groupDataManagerConfiguration = DKImageGroupDataManagerConfiguration()
//        groupDataManagerConfiguration.fetchLimit = 10
//        groupDataManagerConfiguration.assetGroupTypes = [.smartAlbumUserLibrary]
//        let groupDataManager = DKImageGroupDataManager(configuration: groupDataManagerConfiguration)
//        let controller = DKImagePickerController(groupDataManager: groupDataManager)
        
        
        let controller = DKImagePickerController()
//        controller.delegate = context.coordinator
        controller.assetType = .allVideos
        controller.sourceType = .both
        controller.showsCancelButton = true
//        controller.allowSwipeToSelect = true
//        controller.allowSelectAll = true
        controller.singleSelect = true
        DKImageExtensionController.registerExtension(extensionClass: CustomCameraExtension.self, for: .camera)
        controller.exportStatusChanged = { status in
            switch status {
            case .exporting:
                print("exporting")
            case .none:
                print("none")
            }
        }
        
        controller.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            assets[0].fetchAVAsset { (avAsset, info) in
                if let videoUrl = avAsset as? AVURLAsset {
                    print("url: \(videoUrl.url)")
                    self.videoUrl = videoUrl.url
                    selectedAssets = assets
                }
            }
        }
        
        return controller
    }
    
//    func makeCoordinator() -> DKVideoPickerView.Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        let parent: DKVideoPickerView
//        init(parent: DKVideoPickerView) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let selectedImage = info[.originalImage] as? UIImage {
//                print(selectedImage)
////                parent.selectedAssets = selectedImage
//            }
//
//            self.parent.isPresented = false
//        }
//    }
    
    func updateUIViewController(_ uiViewController: DKVideoPickerView.UIViewControllerType, context: UIViewControllerRepresentableContext<DKVideoPickerView>) {
        //
    }
}

struct VideoPickerView: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPickerView>) -> UIViewController {
        let controller = UIImagePickerController()
        controller.videoQuality = .typeHigh
        controller.sourceType = .photoLibrary
        controller.mediaTypes = [kUTTypeMovie as String]//[kUTTypeImage as String, kUTTypeMovie as String]
        
        return controller
    }
    
    func makeCoordinator() -> VideoPickerView.Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPickerView
        init(parent: VideoPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                print(selectedImage)
                parent.selectedImage = selectedImage
            }
            
            self.parent.isPresented = false
        }
    }
    
    func updateUIViewController(_ uiViewController: VideoPickerView.UIViewControllerType, context: UIViewControllerRepresentableContext<VideoPickerView>) {
        //
    }
}

struct DummyView: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<DummyView>) -> UIButton {
        let button = UIButton()
        button.setTitle("BUMMY", for: .normal)
        button.backgroundColor = .red
        return button
    }
    
    func updateUIView(_ uiView: DummyView.UIViewType, context: UIViewRepresentableContext<DummyView>) {
        
    }
}
