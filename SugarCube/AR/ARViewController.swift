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
    
    let sugarDensity = 0.630119 // cm3/g
    let sodiumDensity = 2.0538
    
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
        let scene = SCNScene(named: "art.scnassets/SugarSalt.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // 1 meter -> 1 centimeter
        //sceneView.scene.rootNode.scale = [0.01, 0.01, 0.01]
        //sceneView.scene.rootNode.simdScale = [0.01, 0.01, 0.01]
        
        setSugarWeightInGrams(value: nil)
        setSodiumWeightInGrams(value: nil)
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
    

    // Override to create and configure nodes for anchors added to the view's session.
    /*func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }*/

    
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        print("Got tap")
        if sender.state == .ended {
            let hitResults = sceneView.hitTest(sender.location(in: sceneView), types: [.estimatedHorizontalPlane])
            if hitResults.count > 0 {
                let targetHit = hitResults[0]
                
                guard let rowNode = sceneView.scene.rootNode.childNode(withName: "RowNode", recursively: true) else {
                    print("Could not find row node")
                    return
                }
                
                rowNode.simdWorldTransform = targetHit.worldTransform
                rowNode.simdScale = [0.1, 0.1, 0.1]
            } else {
                print("Could not find any hits")
            }
        }
    }
    
    func setSugarWeightInGrams(value: Double?) {
        guard let sugarNode = sceneView.scene.rootNode.childNode(withName: "SugarGroup", recursively: true) else {
            print("Could not find sugar node")
            return
        }
        
        guard value != nil else {
            print("Sugar value is nil; hiding")
            sugarNode.isHidden = true
            return
        }
        let volume = value! * sugarDensity // cm3
        let sideLength = cbrt(volume) // cm
        let scaleMultiplier = Float(sideLength / 100)
        sugarNode.simdScale = [scaleMultiplier, scaleMultiplier, scaleMultiplier]
        sugarNode.isHidden = false
        print("Sugar set to " + String(sideLength) + "cm/side")
    }
    
    func setSodiumWeightInGrams(value: Double?) {
        guard let saltNode = sceneView.scene.rootNode.childNode(withName: "SaltGroup", recursively: true) else {
            print("Could not find salt node")
            return
        }
        
        guard value != nil else {
            print("Sodium value is nil; hiding")
            saltNode.isHidden = true
            return
        }
        let volume = value! * sodiumDensity // cm3
        let sideLength = cbrt(volume) // cm
        let scaleMultiplier = Float(sideLength / 100)
        saltNode.simdScale = [scaleMultiplier, scaleMultiplier, scaleMultiplier]
        saltNode.isHidden = false
        print("Salt set to " + String(sideLength) + "cm/side")
    }
    
    
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
        request.usesCPUOnly = true
        
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
            observation.payloadStringValue != nil
        {
            NutritionixAPI.getNutritionData(upc: observation.payloadStringValue!, testMode: true) { (err: Error?, optFood: Document?) in
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                
                guard err == nil, let food = optFood else {
                    print(err)
                    return
                }
                
                print(food)
                
                self.setSugarWeightInGrams(value: food["nf_sugars"] as? Double)
                
                self.setSodiumWeightInGrams(value: food["nf_sodium"] as? Double)
                
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
