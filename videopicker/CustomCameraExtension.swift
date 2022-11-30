//
//  CustomCameraExtension.swift
//  videopicker
//
//  Created by Angel Dev on 11/30/22.
//

import UIKit
import MobileCoreServices
import DKImagePickerController

open class CustomCameraExtension: DKImageBaseExtension, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
    
    open override func perform(with extraInfo: [AnyHashable : Any]) {
        guard let didFinishCapturingImage = extraInfo["didFinishCapturingImage"] as? ((UIImage, [AnyHashable : Any]?) -> Void)
            , let didFinishCapturingVideo = extraInfo["didFinishCapturingVideo"] as? ((URL) -> Void)
            , let didCancel = extraInfo["didCancel"] as? (() -> Void) else { return }

        self.didFinishCapturingImage = didFinishCapturingImage
        self.didFinishCapturingVideo = didFinishCapturingVideo
        self.didCancel = didCancel
        
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.videoQuality = .typeHigh
        camera.sourceType = .camera
        camera.mediaTypes = [kUTTypeMovie as String]//[kUTTypeImage as String, kUTTypeMovie as String]
        
        self.context.imagePickerController.present(camera)
    }
    
    open override func finish() {
        self.context.imagePickerController.dismiss(animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[.mediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            let metadata = info[.mediaMetadata] as! [AnyHashable : Any]
            
            let image = info[.originalImage] as! UIImage
            self.didFinishCapturingImage?(image, metadata)
        } else if mediaType == kUTTypeMovie as String {
            let videoURL = info[.mediaURL] as! URL
            self.didFinishCapturingVideo?(videoURL)
        }
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.didCancel?()
    }
}
