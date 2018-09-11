//
//  ViewController.swift
//  HEARTBEAT
//
//  Created by Julian Lechuga Lopez on 21/6/18.
//  Copyright © 2018 Julian Lechuga Lopez. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate{
    @IBOutlet weak var planeDetected: UILabel!
    
    @IBOutlet weak var apiCall: UIButton!
    let itemsArray : [String] = ["cup", "vase", "boxing", "table"]
//    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
//    var selectedItem: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.configuration.planeDetection = .vertical
        self.sceneView.session.run(configuration)
//        self.itemsCollectionView.dataSource = self
//        self.itemsCollectionView.delegate = self
        self.sceneView.delegate = self
        self.registerGestureRecognizers()
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    func registerGestureRecognizers(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty{
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            print(sender.scale)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty{
            self.addItem(hitTestResult: hitTest.first!)
        }
    }
    
    @objc func rotate(sender: UILongPressGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        if !hitTest.isEmpty{
            let result = hitTest.first!
        if sender.state == .began{
            let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 3)
            let infiniteRotation = SCNAction.repeatForever(rotateAction)
            result.node.runAction(infiniteRotation)
            
        }
        else if sender.state == .ended{
            result.node.removeAllActions()
            
            }
        }
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
    
    func addItem(hitTestResult: ARHitTestResult){
//        if let selectedItem = self.selectedItem{
            let scene = SCNScene(named: "Models.scnassets/cup.scn")
            let node = (scene?.rootNode.childNode(withName: "cup", recursively: false))!
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x,thirdColumn.y,thirdColumn.z)
//            if selectedItem == "table" {
//                self.centerPivot(for: node)
//            }
            self.sceneView.scene.rootNode.addChildNode(node)
//        }
    }
    
    @IBAction func apiCall(_ sender: Any) {
        let node = self.createText(text: "Llamada realizada")
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    func createText(text: String) -> SCNNode{
        let textGeometry = SCNText(string: text, extrusionDepth: 0.15)
        //        textGeometry.alignmentMode = kCAAlignmentCenter
        textGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        textGeometry.firstMaterial?.specular.contents = UIColor.white
        textGeometry.firstMaterial?.isDoubleSided = true
        textGeometry.font = UIFont(name: "Futura", size: 0.15)
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.2,0.2,0.2)
        textNode.position = SCNVector3(0,0,-1)
        return textNode
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        cell.itemLabel.text = self.itemsArray[indexPath.row]
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        self.selectedItem = itemsArray[indexPath.row]
//        cell?.backgroundColor = UIColor.green
//    }
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.backgroundColor = UIColor.orange
//    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async{
            self.planeDetected.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.planeDetected.isHidden = true
            }
        }
        
    }
}
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
