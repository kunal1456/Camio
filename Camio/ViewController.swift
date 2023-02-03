//
//  ViewController.swift
//  Camio
//
//  Created by Kunal-Goswami on 1/28/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    //capture Session
    var session : AVCaptureSession?
    //Photo Output
    let output = AVCapturePhotoOutput()
    //Video  Preview
    var previewLayer = AVCaptureVideoPreviewLayer()
    //Shutter Button
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var discardBtn: UIButton!
    @IBOutlet weak var myPreviewLayer: UIView!
    private let shutterbutton : UIButton={
        let button = UIButton(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 6
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .black
        discardBtn.isHidden = true
        discardBtn.setTitle("Discard", for: UIControl.State.normal)
        myPreviewLayer.backgroundColor = .red
        myPreviewLayer.layer.addSublayer(previewLayer)
        myPreviewLayer.addSubview(shutterbutton)
        //view.layer.addSublayer(previewLayer)
        //view.addSubview(shutterbutton)
        // Do any additional setup after loading the view.
        
        checkCameraPermission()
        shutterbutton.addTarget(self, action: #selector(didTapToTakePhoto), for: .touchUpInside)
    }
    
    @IBAction func clickDiscardBtn(_ sender: UIButton)
    {
//        for imgView in myPreviewLayer.subviews{
//           if imgView is UIImageView{
//               myPreviewLayer.subviews
//           }
//        }
        if  captureImageView.image != nil{
            captureImageView.image = nil;
            discardBtn.isHidden = true
        }
    
        DispatchQueue.global(qos: .background).async {
            self.session?.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = myPreviewLayer.bounds
        shutterbutton.center = CGPoint(x: myPreviewLayer.frame.size.width/2, y: myPreviewLayer.frame.size.height - 100)
    }
    private func checkCameraPermission()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            //request
            askCameraPermission()
            break
        case .restricted:
            print("restricted")
            alertCameraAccessNeeded()
            break
        case .denied:
            print("denied")
            alertCameraAccessNeeded()
            break
        case .authorized:
            setupCamera()
            break
        @unknown default :
            print("default")
            break
        }
    }
    
    private func alertCameraAccessNeeded()
    {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!

        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to make full use of this app.",
            preferredStyle: UIAlertController.Style.alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func askCameraPermission()
    {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else{
                print("not granted")
                return
            }
//                DispatchQueue.main.async {
                self?.setupCamera()
//                }
        }
    }
    
    private func setupCamera()
    {
         let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do{
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                DispatchQueue.global(qos: .background).async {
                    session.startRunning()
                }
                
                self.session = session
            }
            catch
            {
                print(error)
            }
        }
    }
    
    func stopScanning() {
            if session?.isRunning == true {
                session?.stopRunning()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if(self.session?.isRunning == false){
                self.previewLayer.removeFromSuperlayer()
                }
            }
        }

    
    @objc private func didTapToTakePhoto(){
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
   
}

extension ViewController : AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        
        if image != nil{
            discardBtn.isHidden = false
        }
        session?.stopRunning()
     
        if captureImageView != nil
        {
            captureImageView.image = image
            captureImageView.contentMode = .scaleAspectFill
            myPreviewLayer.addSubview(captureImageView)
        }
        else
        {
            print("ERROR")
        }
       
        
    }
    
}

