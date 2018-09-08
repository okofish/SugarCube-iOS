//
//  ViewController.swift
//  SugarCube
//
//  Created by Jesse Friedman on 9/7/18.
//  Copyright © 2018 Jesse Friedman. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import StitchCore

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    lazy var stitchClient = Stitch.defaultAppClient!

    @IBOutlet var sceneView: ARSCNView!
    
    var currentBuffer: CVPixelBuffer?
    
    let visionQueue = DispatchQueue(label: "ws.jesse.SugarCube.serialVisionQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        self.currentBuffer = frame.capturedImage
        recognizeCurrentImage()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    lazy var classificationRequest: VNDetectBarcodesRequest = {
        let request = VNDetectBarcodesRequest() { (finishedRequest, error) in
            self.processClassifications(for: finishedRequest, error: error)
        }
        // Use CPU for Vision processing to ensure that there are adequate GPU resources for rendering.
        //request.usesCPUOnly = true
        
        return request
    }()
    
    func recognizeCurrentImage() {
        //let orientation = UIDevice.current.orientati as! CGImagePropertyOrientation
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!)
        visionQueue.async {
            do {
                try requestHandler.perform([self.classificationRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        if
            let results = request.results as? [VNBarcodeObservation],
            let observation = results.first,
            observation.payloadStringValue == nil
        {
            NutritionixAPI.getNutritionData(upc: observation.payloadStringValue!) { (err: Error?, data: Document?) in
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                
                guard err == nil else {
                    print(err)
                    return
                }
                
                print(data)
            }
        } else {
            // Release the pixel buffer when done, allowing the next buffer to be processed.
            defer { self.currentBuffer = nil }
        }
        
        /*DispatchQueue.main.async { [weak self] in
            self?.displayClassifierResults()
        }*/
    }
}
