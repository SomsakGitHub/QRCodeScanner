//
//  SpecificAreaVC.swift
//  QRCodeScanner
//
//  Created by somsak on 10/5/2564 BE.
//

import UIKit
import AVFoundation

class SpecificAreaVC: UIViewController {
    
    @IBOutlet var qrScanSpecificView: QRScanSpecificView!
    @IBOutlet weak var qrScanView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    let session = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    let output = AVCaptureMetadataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true

        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            self.session.addInput(input)
        } catch  {
            print("erroe")
        }
        
        self.session.addOutput(self.output)
        
        self.output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        self.view.bringSubviewToFront(self.qrScanView)
        
        self.session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.session.stopRunning()
    }
    
    @IBAction func popView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SpecificAreaVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first{
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            let qrCodeObject = previewLayer.transformedMetadataObject(for: metadataObject as! AVMetadataMachineReadableCodeObject)
            
            if self.qrScanSpecificView.focusView.frame.contains((qrCodeObject!.bounds)) {
                
                if readableObject.stringValue != nil {
                    messageLabel.text = readableObject.stringValue
                }
                
                session.stopRunning()
            }
        }
    }
}

class QRScanSpecificView: UIView {
    
    @IBOutlet weak var focusView: UIView!
}
