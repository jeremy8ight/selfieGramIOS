//
//  CaptureViewController.swift
//  Selfiegram
//
//  Created by Jeremy Barnes-Smith on 4/27/25.
//

import UIKit
import AVKit

class CaptureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillLayoutSubviews() {
           // keep the video preview and device orientations together
//           self.cameraPreview?.setCameraOrientation(currentVideoOrientation)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class PreviewView : UIView {
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    func setSession(_ session: AVCaptureSession) {
        //Ensure that we only ever do this once for this view
        guard self.previewLayer == nil else {
            NSLog("Warning: \(self.description) attemped to set its preview layer more than once. This is not allowed.")
            return
        }
        
        //Create a preview layer that gets its content from the provided capture session
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        //Fill the cotents of the layer, preserving the original aspect ratio
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //Add the preview layer to our layer
        self.layer.addSublayer(previewLayer)
        
        //Store a reference to the layer
        self.previewLayer = previewLayer
        
        //Ensure that the sublayer is laid out
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        previewLayer?.frame = self.bounds
    }
    
    //flag - look up this to make sure it works right
    func setCameraOrientation(_ orientation : AVCaptureDevice.RotationCoordinator) {
        previewLayer?.connection?.videoRotationAngle = orientation.videoRotationAngleForHorizonLevelPreview
    }
}
