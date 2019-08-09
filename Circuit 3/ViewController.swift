//
//  ViewController.swift
//  Circuit 3
//
//  Created by Maher Bhavsar on 06/07/19.
//  Copyright © 2019 Seven Dots. All rights reserved.
//



import UIKit
import SceneKit
import ARKit
//import iosMath

class ViewController: UIViewController, ARSCNViewDelegate {

    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var planeDetectedLabel: UILabel!
    
    @IBOutlet weak var tutorialButton: UIButton!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBAction func onClickPlayButton(_ sender: Any) {
        tutorialButton.isHidden = true
        playButton.isHidden = true
        mode = "Play"
        
        planeDetectedLabel.isHidden = false
        planeDetectedLabel.text = "Detecting Plane"


        //sceneView.session.pause()
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        

    }
    
    @IBAction func onClickTutorialButton(_ sender: Any) {
        tutorialButton.isHidden = true
        playButton.isHidden = true
        mode = "Tutorial"
        
        planeDetectedLabel.isHidden = false
        planeDetectedLabel.text = "Detecting Plane"
        
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
        sceneView.scene.rootNode.removeAllAudioPlayers()
        sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: audioDetectingPlane))

    }
    
    @IBAction func onClickHomeButton(_ sender: Any) {
        //sceneView.scene.rootNode.childNode(withName: "Resistor", recursively: false)?.removeFromParentNode()
        
        sceneView.scene.rootNode.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        
        tutorialButton.isHidden = false
        playButton.isHidden = false
        parentCircuitPresent = false
        mode = "Home"
    }

    let mapToSignificantNumbers = [ UIColor.black, UIColor.brown, UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue,UIColor.purple , UIColor.gray,UIColor.white]
    
    let mapToString = ["capacitorCircle1", "capacitorCircle2", "capacitorCircle3", "capacitorCircle4", "inductorCircle1", "inductorCircle2", "inductorCircle3", "inductorCircle4", "batteryCircle1", "batteryCircle2", "batteryCircle3", "batteryCircle4", "batteryCircle5", "batteryCircle6", "batteryCircle7", "batteryCircle8"]
    let mapToPower = [ "mega", "kilo", "", "mili", "nano", "micro", "pico", "femto"]
    
    var mapToValues = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    let mapToElement = ["Capacitor", "Inductor", "Battery"]
    var mapToElementValues = [0,0,0,0] as [Int]
    
    let colorName = ["black", "brown", "red", "orange", "yellow", "green", "blue", "purple", "gray", "white"]
    
    var parentCircuitPresent = false

    
    var selectedCircle : String?
    var capacitorValue : Int = 0
    
    var rememberPosition = SCNVector3(x: 0, y: 0, z: 0)
    var selectedElement : String?
    
    
    var isOpen : Bool = false
    var isOpenFromCylinder : String? //Name of Cylinder for Cylinder check -> createCylinderTiles
    var isOpenFromCylinderTile : String? //Name of Band colorCode Tiles check -> func colorCode
    var resistorValue : Int64 = 0 //To find total resistance

    var mode : String = "🏡"
    
    var audioTapScreen : SCNAudioSource!
    var audioDetectingPlane : SCNAudioSource!
    var audioTapResistor : SCNAudioSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        sceneView.showsStatistics = true
        planeDetectedLabel.isHidden = true
        //planeDetectedLabel.text = "Scanning Horizontal Plane"
        
        
        //loading Audio
        audioTapScreen = SCNAudioSource(fileNamed: "TapScreen_1.mp3")
        audioTapScreen.load()
        
        audioTapResistor = SCNAudioSource(fileNamed: "TapResistor_1.mp3")
        audioTapResistor.load()
        
        audioDetectingPlane = SCNAudioSource(fileNamed: "DetectingPlane_1.mp3")
        audioDetectingPlane.load()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        //configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        //initialSetup (startVector: SCNVector3(0,0, -0.1))
        addGestures()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Initial SetUp
    
    func initialSetup (startVector: SCNVector3) {

        createTextNode(textvalue: "Tutorial", textNodeName: "tutorialText", textParentName: "tutorialTextParent", textPlaneName: "tutorialTextPlane", startVector: SCNVector3(x: 0, y: 0.02, z: -0.1), textParentParent: sceneView.scene.rootNode, eulerAngle: SCNVector3(0,0,0))
        
        createTextNode(textvalue: "Play", textNodeName: "playText", textParentName: "playTextParent", textPlaneName: "playTextPlane", startVector: SCNVector3(x: 0, y: 0, z: -0.1), textParentParent: sceneView.scene.rootNode, eulerAngle: SCNVector3(0,0,0))
        
    }
    
    func createTextNode (textvalue: String, textNodeName: String, textParentName: String, textPlaneName: String, startVector: SCNVector3, textParentParent: SCNNode, eulerAngle: SCNVector3) {
        let textParent = SCNNode()
        textParent.name = textParentName
        textParent.position = startVector + SCNVector3(x: 0 , y: 0, z: 0)
        textParent.eulerAngles = eulerAngle
        
        
        print("create text node called")
        
        let plane = SCNPlane(width: 0.15, height: 0.01)
        
        let textPlane = SCNNode(geometry: plane)
        //textPlane.eulerAngles = eulerAngle
        textPlane.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        textPlane.geometry?.firstMaterial?.isDoubleSided = true
        
        textPlane.opacity = 0.7
        textPlane.name = textPlaneName
        
        
        
        textParent.addChildNode(textPlane)
        
        let textGeometry = SCNText(string: textvalue, extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 9)
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        textNode.opacity = 1
        // scale down the size of the text
        textNode.simdScale = SIMD3(repeating: 0.0005)
        //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
        textNode.centerAlign()
        textNode.name = textNodeName
        //textNode.eulerAngles = eulerAngle
        textParent.addChildNode(textNode)
        
        textParentParent.addChildNode(textParent)
    }
    
    
    
    
    
    
    //MARK: - Gesture Code
    
    
    
    func addGestures () {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func pan (sender: UIPanGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let location = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(location)
        for hitTestResult in hitTest {
            print(hitTestResult.node.name as Any)
            if hitTestResult.node.name == "circleTile" {
                print("Velocity x",sender.velocity(in: sceneView).x)
                print("Velocity y",sender.velocity(in: sceneView).y)
                let velocity = -sender.velocity(in: sceneView).y / 1000
                let action2 = SCNAction.rotateBy(x: 0, y: CGFloat(velocity) , z: 0, duration: 0.5)
                let node = sceneView.scene.rootNode.childNode(withName: "circle", recursively: true)
                node?.runAction(action2)
                break
            }
        }
    }
    
    @objc func tapped (sender: UITapGestureRecognizer) {
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        
        //MARK: - Home Mode
        if mode == "Home" {

            
            return
        }
        
        //MARK: - Tutorial Mode
        if mode == "Tutorial" {
            if parentCircuitPresent == false {
                let hitTest = scene.hitTest(location, types: .existingPlaneUsingExtent)
                
                if hitTest.first != nil {
                    planeDetectedLabel.isHidden = true
                    let elementR = SCNScene(named: "art.scnassets/Resistor.scn")
                    let resistor = elementR?.rootNode.childNode(withName: "Resistor", recursively: false)
                    let transform = hitTest.first!.worldTransform
                    let planeXposition = transform.columns.3.x
                    let planeYposition = transform.columns.3.y
                    let planeZposition = transform.columns.3.z
                    resistor?.position  = SCNVector3(planeXposition, planeYposition, planeZposition)
                    scene.scene.rootNode.addChildNode(resistor!)
                    
                    parentCircuitPresent = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.planeDetectedLabel.isHidden = true
                        self.sceneView.scene.rootNode.removeAllAudioPlayers()
                        self.sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: self.audioTapResistor))
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.planeDetectedLabel.isHidden = true
                        //self.sceneView.scene.rootNode.removeAllAudioPlayers()
                        
                    }
                }
            } else {
                let hitTest = scene.hitTest(location)
                for hitTestResult in hitTest {
                    print(hitTestResult.node.name as Any)
                    
                    var name = ""
                    name = hitTestResult.node.name ?? "noName"
                    
                    if name == "" {
                        name = "noName"
                    }
                    if name == "Resistor" || name == "Band_1" || name == "Band_2" || name == "Band_3" || name == "Band_4" {
                        destroyColorCode()
                        destroyCylinderTiles()
                        
                        print("inside Resistor")
                        rememberPosition = hitTestResult.worldCoordinates.self
                        
                        createCylinderTiles(startVector: hitTestResult.worldCoordinates.self)
                        break
                    }
                    else if name == "band1" || name == "band2" || name == "band3" || name == "band4" {
                        
                        destroyColorCode()
                        setColorCode( startVector: hitTestResult.worldCoordinates.self)
                        
                        print(hitTestResult.node.name as Any)
                        isOpenFromCylinderTile = hitTestResult.node.name
                        switch name {
                        case "band1":
                            isOpenFromCylinder = "Band_1"
                        case "band2":
                            isOpenFromCylinder = "Band_2"
                        case "band3":
                            isOpenFromCylinder = "Band_3"
                        case "band4":
                            isOpenFromCylinder = "Band_4"
                        default:
                            isOpenFromCylinder = "None"
                        }
                        isOpen = true
                    }
                    else if colorName.contains(name) {
                        print("inside ", name)
                        print("inside open from cylinder", isOpenFromCylinder as Any)
                        print("inside open from cylinder tile", isOpenFromCylinderTile as Any)
                        
                        let nodeCylinder = sceneView.scene.rootNode.childNode(withName: isOpenFromCylinder!, recursively: true)
                        print(nodeCylinder as Any)
                        nodeCylinder?.geometry?.firstMaterial?.diffuse.contents = mapToSignificantNumbers[colorName.firstIndex(of: name)!]
                        print("", nodeCylinder!.name as Any)
                        let getcylinder1 = sceneView.scene.rootNode.childNode(withName: "Band_1", recursively: true)
                        let color1 = getcylinder1?.geometry?.firstMaterial?.diffuse.contents
                        let getcylinder2 = sceneView.scene.rootNode.childNode(withName: "Band_2", recursively: true)
                        let color2 = getcylinder2?.geometry?.firstMaterial?.diffuse.contents
                        let getcylinder3 = sceneView.scene.rootNode.childNode(withName: "Band_3", recursively: true)
                        let color3 = getcylinder3?.geometry?.firstMaterial?.diffuse.contents
                        let getcylinder4 = sceneView.scene.rootNode.childNode(withName: "Band_4", recursively: true)
                        let color4 = getcylinder4?.geometry?.firstMaterial?.diffuse.contents
                        
                        print(color1 as Any)
                        print(color2 as Any)
                        print(color3 as Any)
                        print(color4 as Any)
                        
                        destroyColorCode()
                        destroyCylinderTiles()
                        
                        createCylinderTiles(startVector: rememberPosition)
                        print("created cylinder tiles")
                    }
                    
                }
            }
            
            return
        }
        //MARK: - Play Mode
        if mode == "Play" {
            if parentCircuitPresent == false {
                let hitTest = scene.hitTest(location, types: .existingPlaneUsingExtent)
                if hitTest.first != nil {
                    planeDetectedLabel.isHidden = true
                    addParentCircuit(hitTestResult: (hitTest.first!))
                    //addResult(hitTestResult: (hitTest.first!))
                }
            } else {
                let hitTest = scene.hitTest(location)
                for hitTestResult in hitTest {
                    print(hitTestResult.node.name as Any)
                    
                    var name = ""
                    name = hitTestResult.node.name ?? "noName"
                    
                    if name == "" {
                        name = "noName"
                    }
                    
                    if name == "Capacitor" || name == "Inductor"  {
                        destroyCapacitorCircleTiles()
                        destroyCapacitorTiles ()
                        
                        selectedElement = name
                        rememberPosition = hitTestResult.worldCoordinates.self
                        createCapacitorTiles (element: selectedElement! , startVector: rememberPosition)
                        
                        
                        print(rememberPosition)
                    }
                    else if name == "Battery" {
                        destroyCapacitorCircleTiles()
                        destroyCapacitorTiles ()
                        
                        selectedElement = name
                        rememberPosition = hitTestResult.worldCoordinates.self
                        createCapacitorTiles (element: selectedElement!, startVector: rememberPosition)
                        
                        //createCapacitorTiles( element: selectedElement!, startVector: rememberPosition + SCNVector3(x: 0.02, y: 0, z: 0))
                        
                    }
                    else if mapToString.contains(name) == true {
                        hitCapacitorTiles(tileName: name, hitTestResult: hitTestResult)
                    }
                    else if name == "circleTile" {
                        destroyCapacitorTiles()
                        destroyCapacitorCircleTiles()
                        let number = mapToSignificantNumbers.firstIndex(of: hitTestResult.node.geometry?.firstMaterial?.diffuse.contents as! UIColor )
                        print(number as Any)
                        
                        let selectedCircleIndex = mapToString.firstIndex(of: selectedCircle!)
                        print ("Circle Index", selectedCircleIndex as Any)
                        
                        mapToValues[selectedCircleIndex!] = number!
                        print(mapToValues)
                        
                        createCapacitorTiles (element : selectedElement! , startVector: rememberPosition)
                    }
                    else if name == "Resistor" || name == "Band_1" || name == "Band_2" || name == "Band_3" || name == "Band_4" {
                        destroyColorCode()
                        destroyCylinderTiles()
                        
                        print("inside Resistor")
                        rememberPosition = hitTestResult.worldCoordinates.self
                        
                        createCylinderTiles(startVector: hitTestResult.worldCoordinates.self)
                        break
                    }
                    else if name == "band1" || name == "band2" || name == "band3" || name == "band4" {
                        
                        destroyColorCode()
                        setColorCode( startVector: hitTestResult.worldCoordinates.self)
                        
                        print(hitTestResult.node.name as Any)
                        isOpenFromCylinderTile = hitTestResult.node.name
                        switch name {
                        case "band1":
                            isOpenFromCylinder = "Band_1"
                        case "band2":
                            isOpenFromCylinder = "Band_2"
                        case "band3":
                            isOpenFromCylinder = "Band_3"
                        case "band4":
                            isOpenFromCylinder = "Band_4"
                        default:
                            isOpenFromCylinder = "None"
                        }
                        isOpen = true
                    }
                    else if colorName.contains(name) {
                        print("inside ", name)
                        print("inside open from cylinder", isOpenFromCylinder as Any)
                        print("inside open from cylinder tile", isOpenFromCylinderTile as Any)
                        
                        let nodeCylinder = sceneView.scene.rootNode.childNode(withName: isOpenFromCylinder!, recursively: true)
                        print(nodeCylinder as Any)
                        nodeCylinder?.geometry?.firstMaterial?.diffuse.contents = mapToSignificantNumbers[colorName.firstIndex(of: name)!]
                        print("", nodeCylinder!.name as Any)
                        let getcylinder1 = sceneView.scene.rootNode.childNode(withName: "Band_1", recursively: true)
                        let color1 = getcylinder1?.geometry?.firstMaterial?.diffuse.contents
                        let getcylinder2 = sceneView.scene.rootNode.childNode(withName: "Band_2", recursively: true)
                        let color2 = getcylinder2?.geometry?.firstMaterial?.diffuse.contents
                        let getcylinder3 = sceneView.scene.rootNode.childNode(withName: "Band_3", recursively: true)
                        let color3 = getcylinder3?.geometry?.firstMaterial?.diffuse.contents
                        let getcylinder4 = sceneView.scene.rootNode.childNode(withName: "Band_4", recursively: true)
                        let color4 = getcylinder4?.geometry?.firstMaterial?.diffuse.contents
                        
                        print(color1 as Any)
                        print(color2 as Any)
                        print(color3 as Any)
                        print(color4 as Any)

                        destroyColorCode()
                        destroyCylinderTiles()
                        
                        createCylinderTiles(startVector: rememberPosition)
                        print("created cylinder tiles")
                    }
                    else {
                        destroyCapacitorTiles()
                        destroyCapacitorCircleTiles()
                        destroyColorCode()
                        destroyCylinderTiles()
                    }
                }
            }
        }
    }
    
    //MARK: - Add Parent Circuit
    
    func addParentCircuit (hitTestResult : ARHitTestResult) {
        
        let scene6 = SCNScene(named: "art.scnassets/LCR3.scn")
        let node6 = scene6?.rootNode.childNode(withName: "ParentNode", recursively: false)
        let transform = hitTestResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        node6?.position  = SCNVector3(planeXposition, planeYposition, planeZposition)
        node6!.name = "parentCircuit"
        
        print(node6?.childNode(withName: "Ok", recursively: true)?.geometry?.firstMaterial?.diffuse.contents as Any)
        
        sceneView.scene.rootNode.addChildNode(node6!)
        
        addResult(position: sceneView.scene.rootNode.childNode(withName: "parentCircuit", recursively: false)!.position)
        parentCircuitPresent = true
    }
    
    func addResult (position : SCNVector3) {
        //let scene6 = SCNScene(named: "art.scnassets/LCR3.scn")
        //let node6 = scene6?.rootNode.childNode(withName: "ParentNode", recursively: false)
        let node6 = SCNNode()
        node6.position  = position + SCNVector3(x: 0, y: 0.1, z: 0)
        node6.name = "resultCircuit"
        //node6.position = SCNVector3(x: 0, y: 0, z: 0)
        sceneView.scene.rootNode.addChildNode(node6)
        
        print("add Result called")
        
//        let yourLabel: MTMathUILabel = MTMathUILabel()
//        yourLabel.latex = "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"
//        yourLabel.sizeToFit()
//        let label = yourLabel.textInputContextIdentifier
        
        var result : Float = Float(mapToElementValues[0] * mapToElementValues[1])
        
        if result == 0 {
            createTextNode(textvalue: "Resonant Frequency (1/√(LC)) = ∞ radians per second", textNodeName: "NaturalFrequency", textParentName: "NaturalFrequencyParent", textPlaneName: "NaturalFrequencyPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: -0.03), textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
            print("create text node")
        } else {
            result = sqrt(result)
            result = 1 / result
            createTextNode(textvalue: "Resonant Frequency (Wo = 1/√(LC)) = " + String(result) + "radians per second", textNodeName: "NaturalFrequency", textParentName: "NaturalFrequencyParent", textPlaneName: "NaturalFrequencyPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: -0.03) , textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
        }
        
        if mapToElementValues[1] == 0 {
            createTextNode(textvalue: "Bandwidth ( ∆f = R/(2πL)) = 0 Hz", textNodeName: "Bandwidth", textParentName: "BandwidthParent", textPlaneName: "BandwidthPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: -0.02) , textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
        } else {
            var bandWidth : Float = ( Float(2 * mapToElementValues[1]))
            bandWidth = bandWidth * Float(22/7)
            bandWidth = Float(resistorValue) * (1/bandWidth)
            createTextNode(textvalue: "Bandwidth ( ∆f = R/(2πL)) = " + String(bandWidth) + " Hz", textNodeName: "Bandwidth", textParentName: "BandwidthParent", textPlaneName: "BandwidthPlane", startVector: node6.position + SCNVector3(x:0, y: 0, z: -0.02), textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
        }
        
        createTextNode(textvalue: "Reactive Impedence (R) = " + String(resistorValue) + " Ω", textNodeName: "R", textParentName: "RParent", textPlaneName: "RPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: 0), textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
        
        let xl : Float = Float(2 * mapToElementValues[1] * (22/7) * mapToElementValues[3])
        createTextNode(textvalue: "Inductive Impedence ( XL = 2πwL) = " + String(xl) + " Ω", textNodeName: "II", textParentName: "IIParent", textPlaneName: "IIPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: 0.01), textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))

        
        var xc : Float
        if mapToElementValues[0] == 0 || mapToElementValues[3] == 0 {
            createTextNode(textvalue: "Capacitive Impedence ( XC = 1/(2πwC)) = ∞ Ω", textNodeName: "CI", textParentName: "CIParent", textPlaneName: "CIPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: 0.02) , textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
            
            createTextNode(textvalue: "Total Series Impedence ( Z = √( (R*R) + (XL*XL - XC*XC))) = ∞ Ω", textNodeName: "CI", textParentName: "CIParent", textPlaneName: "CIPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: 0.03) , textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))

        } else {
            xc = Float(2 * mapToElementValues[0] * (22/7) * mapToElementValues[3])
            xc = 1 * (1 / xc)
            createTextNode(textvalue: "Capacitive Impedence ( XC = 1/(2πwC)) = " + String(xc) + " Ω", textNodeName: "CI", textParentName: "CIParent", textPlaneName: "CIPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: 0.02) , textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
            
            var z : Float = (xl - xc) * (xl - xc)
            z = z + Float((resistorValue * resistorValue))
            z = sqrt(z)
            
            createTextNode(textvalue: "Total Series Impedence ( Z = √( (R*R) + (XL-XC)(XL-XC))) = " + String(z) + " Ω", textNodeName: "Z", textParentName: "ZParent", textPlaneName: "ZPlane", startVector: node6.position + SCNVector3(x: 0, y: 0, z: 0.03) , textParentParent: node6, eulerAngle: SCNVector3(-90.degreesToradians,0,0))
        }

        
        
    }
    

    // MARK: - resistor Code
    
    func destroyCylinderTiles() {
        let masterCylinderTiles = sceneView.scene.rootNode.childNode(withName: "masterCylinderTiles", recursively: true)
        masterCylinderTiles?.removeFromParentNode()
    }
    
    func createCylinderTiles( startVector: SCNVector3)  {
        let getcylinder1 = sceneView.scene.rootNode.childNode(withName: "Band_1", recursively: true)
        let color1 = getcylinder1?.geometry?.firstMaterial?.diffuse.contents
        let getcylinder2 = sceneView.scene.rootNode.childNode(withName: "Band_2", recursively: true)
        let color2 = getcylinder2?.geometry?.firstMaterial?.diffuse.contents
        let getcylinder3 = sceneView.scene.rootNode.childNode(withName: "Band_3", recursively: true)
        let color3 = getcylinder3?.geometry?.firstMaterial?.diffuse.contents
        let getcylinder4 = sceneView.scene.rootNode.childNode(withName: "Band_4", recursively: true)
        let color4 = getcylinder4?.geometry?.firstMaterial?.diffuse.contents
        
        print(color1 as Any)
        print(color2 as Any)
        print(color3 as Any)
        print(color4 as Any)
        
        let range = [ ["band1", color1!], ["band2", color2!], ["band3", color3!], ["band4", color4!]] as [[Any]]
        var start : Float = -0.03
        
        let masterParent = SCNNode()
        masterParent.name = "masterCylinderTiles"
        for i in range {
            let parentNode = SCNNode()
            parentNode.name = String(i[0] as! String)
            parentNode.position = startVector + SCNVector3(x: Float(start) , y: 0.1, z: 0)
            start = start + Float(0.02)
            
            let plane = SCNPlane(width: 0.02, height: 0.01)
            let node = SCNNode(geometry: plane)
            
            node.geometry?.firstMaterial?.diffuse.contents = i[1]
            node.opacity = 0.5
            node.name = String(i[0] as! String)
            //node.name1 = "a"
            //sceneView.scene.rootNode.addChildNode(node)
            //node.isHidden = true
            parentNode.addChildNode(node)
            
            let textGeometry = SCNText(string: i[0], extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 10)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = i[1]
            textNode.opacity = 1
            // scale down the size of the text
            textNode.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode.centerAlign()
            parentNode.addChildNode(textNode)
            
            masterParent.addChildNode(parentNode)
        }
        sceneView.scene.rootNode.addChildNode(masterParent)
        let resistorTextParent = SCNNode()
        resistorTextParent.name = "resistorText"
        resistorTextParent.position = startVector + SCNVector3(x: 0 , y: 0.05, z: 0 )
        
        let plane = SCNPlane(width: 0.1, height: 0.01)
        let resistorTextPlane = SCNNode(geometry: plane)
        
        resistorTextPlane.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        resistorTextPlane.opacity = 0.7
        resistorTextPlane.name = "resistorText"
        resistorTextParent.addChildNode(resistorTextPlane)
        
        let createString = "Resistance = " + String(resistorValue) + " Ω"
        
        let textGeometry = SCNText(string: createString, extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 9)
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        textNode.opacity = 1
        // scale down the size of the text
        textNode.simdScale = SIMD3(repeating: 0.0005)
        //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
        textNode.centerAlign()
        textNode.name = "resistorTextNode"
        
        resistorTextParent.addChildNode(textNode)
        
        masterParent.addChildNode(resistorTextParent)
        updateResistance(band1color: color1 as! UIColor, band2color: color2 as! UIColor, band3color: color3 as! UIColor, band4color: color4 as! UIColor)
        
    }
    
    func destroyColorCode () {
        let colorCode = sceneView.scene.rootNode.childNode(withName: "colorCode", recursively: true)
        colorCode?.removeFromParentNode()
    }
    
    func setColorCode(startVector: SCNVector3) {
        
        var start : Float = 0.01
        
        let masterParent = SCNNode()
        masterParent.name = "colorCode"
        for i in 0...9 {
            let parentNode = SCNNode()
            parentNode.name = String(colorName[i] )
            parentNode.position = startVector + SCNVector3(x: 0 , y: Float(start), z: 0 )
            start = start + Float(0.01)
            
            let plane = SCNPlane(width: 0.02, height: 0.01)
            let node = SCNNode(geometry: plane)
            
            node.geometry?.firstMaterial?.diffuse.contents = mapToSignificantNumbers[i]
            node.opacity = 0.5
            node.name = String(colorName[i] )
            //node.name1 = "a"
            //sceneView.scene.rootNode.addChildNode(node)
            //node.isHidden = true
            parentNode.addChildNode(node)
            
            let textGeometry = SCNText(string: colorName[i], extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 9)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = mapToSignificantNumbers[i]
            textNode.opacity = 1
            // scale down the size of the text
            textNode.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode.centerAlign()
            parentNode.addChildNode(textNode)
            
            masterParent.addChildNode(parentNode)
        }
        
        sceneView.scene.rootNode.addChildNode(masterParent)
        
        
    }
    


    
    // MARK: - Capacitor Code
    
    func hitCapacitorTiles (tileName: String, hitTestResult: SCNHitTestResult) {
        destroyCapacitorCircleTiles()
        print( rememberPosition as Any)
        
        //createCapacitorCircleTiles(circle : tileName ,  startVector: rememberPosition)
        
        //let node = sceneView.scene.rootNode.childNode(withName: tileName, recursively: true)
        print(hitTestResult.node.name!)
        //print("tile node",node!.position)
        
        hitTestResult.node.parent!.removeFromParentNode()
        
        createCapacitorCircleTiles(circle : tileName ,  startVector: hitTestResult.worldCoordinates.self)
        
        
        selectedCircle = tileName
    }
    
    func createCapacitorTiles(element : String , startVector : SCNVector3) {
        
        var range : [[Any]]
        
        if element == "Capacitor" {
            range = [ [mapToString[0], mapToValues[0]], [mapToString[1], mapToValues[1]], [mapToString[2], mapToValues[2]], [mapToString[3], mapToValues[3]]]
        } else if element == "Inductor" {
            range = [ [mapToString[4], mapToValues[4]], [mapToString[5], mapToValues[5]], [mapToString[6], mapToValues[6]], [mapToString[7], mapToValues[7]]]
        } else if element == "Battery" {
            range = [ [mapToString[8], mapToValues[8]], [mapToString[9], mapToValues[9]], [mapToString[10], mapToValues[10]], [mapToString[11], mapToValues[11]],
                [mapToString[12], mapToValues[12]], [mapToString[13], mapToValues[13]], [mapToString[14], mapToValues[14]], [mapToString[15], mapToValues[15]] ]
        }
        
        else {
            return
        }
        
        var start : Float = -0.02
        if element == "Battery" {
            start = -0.05
        }
        let masterParent = SCNNode()
        masterParent.name = "masterCapacitorTiles"
        
        print("createCapacitorTiles ", startVector)
        
        for i in range {
            let parentNode = SCNNode()
            parentNode.name = String(i[0] as! String)
            parentNode.position = startVector + SCNVector3(x: Float(start) , y: 0.05, z: 0)
            start = start + Float(0.015)
            
            if parentNode.name == "batteryCircle4" {
                start = start + Float(0.02)
            }
            
            let plane = SCNPlane(width: 0.01, height: 0.008)
            let node = SCNNode(geometry: plane)
            
            node.geometry?.firstMaterial?.diffuse.contents = mapToSignificantNumbers[ i[1] as! Int ]
            node.opacity = 0.5
            node.name = String(i[0] as! String)
            //node.name1 = "a"
            //sceneView.scene.rootNode.addChildNode(node)
            //node.isHidden = true
            parentNode.addChildNode(node)
            
            let textGeometry = SCNText(string: String( i[1] as! Int ), extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 10)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = mapToSignificantNumbers[ i[1] as! Int ]
            textNode.opacity = 1
            // scale down the size of the text
            textNode.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode.centerAlign()
            parentNode.addChildNode(textNode)
            
            masterParent.addChildNode(parentNode)
        }
        
        if element == "Battery" {
            let batteryTextParent = SCNNode()
            batteryTextParent.name = "batteryText"
            batteryTextParent.position = startVector + SCNVector3(x: 0 , y: 0.035, z: 0 )
            
            let batteryParent1 = SCNNode()
            batteryParent1.position = SCNVector3(x: -0.025 , y: 0, z: 0 )
            let batteryParent2 = SCNNode()
            batteryParent2.position = SCNVector3(x: 0.05 , y: 0, z: 0 )
            
            let plane1 = SCNPlane(width: 0.07, height: 0.01)
            let batteryTextPlane1 = SCNNode(geometry: plane1)
            //batteryTextPlane1.position = SCNVector3(x: -0.05 , y: 0, z: 0 )
            batteryTextPlane1.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            batteryTextPlane1.opacity = 0.7
            batteryTextPlane1.name = "batteryTextPlane1"
            batteryParent1.addChildNode(batteryTextPlane1)
            
            let plane2 = SCNPlane(width: 0.07, height: 0.01)
            let batteryTextPlane2 = SCNNode(geometry: plane2)
            //batteryTextPlane2.position = SCNVector3(x: 0.025 , y: 0, z: 0 )
            batteryTextPlane2.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            batteryTextPlane2.opacity = 0.7
            batteryTextPlane2.name = "batteryTextPlane2"
            batteryParent2.addChildNode(batteryTextPlane2)
            
            var siUnit : String?
            
            siUnit = " V"
            
            let createString1 = "Battery value = " + String(mapToElementValues[2]) + siUnit!
            
            let textGeometry1 = SCNText(string: createString1, extrusionDepth: 1)
            textGeometry1.font = UIFont(name: "Futura", size: 9)
            
            let textNode1 = SCNNode(geometry: textGeometry1)
            //textNode1.position = SCNVector3(x: -0.05 , y: 0, z: 0 )
            textNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
            textNode1.opacity = 1
            // scale down the size of the text
            textNode1.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode1.centerAlign()
            textNode1.name = "batteryTextNode1"
            
            siUnit = " Hz"
            
            let createString2 = "Frequency value = " + String(mapToElementValues[3]) + siUnit!
            
            let textGeometry2 = SCNText(string: createString2, extrusionDepth: 1)
            textGeometry2.font = UIFont(name: "Futura", size: 9)
            
            let textNode2 = SCNNode(geometry: textGeometry2)
            textNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
            textNode2.opacity = 1
            //textNode2.position = SCNVector3(x: 0.05 , y: 0, z: 0 )
            // scale down the size of the text
            textNode2.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode2.centerAlign()
            textNode2.name = "batteryTextNode2"
            
            batteryParent1.addChildNode(textNode1)
            batteryParent2.addChildNode(textNode2)
            //sceneView.scene.rootNode.addChildNode(capacitorTextParent)
            batteryTextParent.addChildNode(batteryParent1)
            batteryTextParent.addChildNode(batteryParent2)
            masterParent.addChildNode(batteryTextParent)
            sceneView.scene.rootNode.addChildNode(masterParent)
        } else {
            let capacitorTextParent = SCNNode()
            capacitorTextParent.name = "capacitorText"
            capacitorTextParent.position = startVector + SCNVector3(x: 0 , y: 0.035, z: 0 )
            
            let plane = SCNPlane(width: 0.1, height: 0.01)
            let capacitorTextPlane = SCNNode(geometry: plane)
            
            capacitorTextPlane.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            capacitorTextPlane.opacity = 0.7
            capacitorTextPlane.name = "capacitorText"
            capacitorTextParent.addChildNode(capacitorTextPlane)
            
            var siUnit : String?
            
            if element == "Capacitor" {
                siUnit = " F"
            } else if element == "Inductor" {
                siUnit = " H"
            }
            
            let createString = String(element) + " value = " + String(mapToElementValues[mapToElement.firstIndex(of: element)!]) + siUnit!
            
            let textGeometry = SCNText(string: createString, extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 9)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
            textNode.opacity = 1
            // scale down the size of the text
            textNode.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode.centerAlign()
            textNode.name = "capacitorTextNode"
            
            capacitorTextParent.addChildNode(textNode)
            
            //sceneView.scene.rootNode.addChildNode(capacitorTextParent)
            masterParent.addChildNode(capacitorTextParent)
            sceneView.scene.rootNode.addChildNode(masterParent)
        }
        

    
        update(element: element)
    }
    
    func destroyCapacitorTiles() {
        let node = sceneView.scene.rootNode.childNode(withName: "masterCapacitorTiles", recursively: true)
        node?.removeFromParentNode()
    }
    
    func createCapacitorCircleTiles ( circle : String , startVector: SCNVector3) {
        
        let geometry  = SCNTube(innerRadius: 0.009, outerRadius: 0.01, height: 0.01)
        geometry.radialSegmentCount = 8
        geometry.heightSegmentCount = 5
        
        let masterNode = SCNNode()
        
        masterNode.position = startVector
        masterNode.opacity = 1
        masterNode.eulerAngles = SCNVector3( 0, 0, 90.degreesToradians )
        masterNode.name = "circle"
        
        let range = [
            [0.01, 0, 0, 0],
            [Float(cos(-36.degreesToradians)) * 0.01 , Float(sin(-36.degreesToradians)) * 0.01 ,  36 , 0 ],
            [Float(cos(-72.degreesToradians)) * 0.01, Float(sin(-72.degreesToradians)) * 0.01, 72, 0],
            [Float(cos(-108.degreesToradians)) * 0.01, Float(sin(-108.degreesToradians)) * 0.01, 108, 0],
            [Float(cos(-144.degreesToradians)) * 0.01, Float(sin(-144.degreesToradians)) * 0.01, 144, 0],
            [Float(cos(-180.degreesToradians)) * 0.01, Float(sin(-180.degreesToradians)) * 0.01, 180, 0],
            [Float(cos(-216.degreesToradians)) * 0.01, Float(sin(-216.degreesToradians)) * 0.01, 216, 0],
            [Float(cos(-252.degreesToradians)) * 0.01, Float(sin(-252.degreesToradians)) * 0.01, 252, 0],
            [Float(cos(-288.degreesToradians)) * 0.01, Float(sin(-288.degreesToradians)) * 0.01, 288, 0],
            [Float(cos(-324.degreesToradians)) * 0.01, Float(sin(-324.degreesToradians)) * 0.01, 324, 0]
            ] as [[Float]]
        
        var change : Int = 0

        if mapToString.contains(circle) {
            change = mapToValues[mapToString.firstIndex(of: circle)!]
        }
        print("change",change)
        let color = [ UIColor.black, UIColor.brown, UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue,UIColor.purple , UIColor.gray, UIColor.white]
        var color1 = 0
        
        for _ in range {
            let parentNode = SCNNode()
            
            if (10 - color1) + change <= 9 {
                parentNode.eulerAngles = SCNVector3( range[(10 - color1) + change][2].degreesToradians , range[(10 - color1) + change][3].degreesToradians, -90.degreesToradians )
                parentNode.position = SCNVector3(x: range[(10 - color1) + change][1], y: 0, z: range[(10 - color1) + change][0])
            } else {
                parentNode.eulerAngles = SCNVector3( range[(10 - color1) + change - 10][2].degreesToradians , range[(10 - color1) + change - 10][3].degreesToradians, -90.degreesToradians )
                parentNode.position = SCNVector3(x: range[(10 - color1) + change - 10][1], y: 0, z: range[(10 - color1) + change - 10][0])
            }
            
            let node1 = SCNNode(geometry: SCNPlane(width: 0.01, height: 0.008))
            
            node1.geometry?.firstMaterial?.diffuse.contents = color[color1]
            node1.opacity = 0.5
            node1.name = "circleTile"
            
            parentNode.addChildNode(node1)
            
            let textGeometry = SCNText(string: String(color1), extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 9)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = color[color1]
            textNode.opacity = 1
            
            textNode.simdScale = SIMD3(repeating: 0.0005)
            
            textNode.centerAlign()
            parentNode.addChildNode(textNode)
            
            masterNode.addChildNode(parentNode)
            color1 = color1 + 1
        }
        
        sceneView.scene.rootNode.addChildNode(masterNode)
        
    }
    
    func destroyCapacitorCircleTiles() {
        let node = sceneView.scene.rootNode.childNode(withName: "circle", recursively: true)
        node?.removeFromParentNode()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        node.name = "planeNode"

        DispatchQueue.main.async {
            self.planeDetectedLabel.text = "Plane Detected"

            self.planeDetectedLabel.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.planeDetectedLabel.text = "Tap on the Screen"
            if self.mode == "Tutorial" {
                self.sceneView.scene.rootNode.removeAllAudioPlayers()
                self.sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: self.audioTapScreen))
            }

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetectedLabel.isHidden = true
            //self.sceneView.scene.rootNode.removeAllAudioPlayers()

        }
    }
    
    // MARK: - Update All
    func update(element : String) {
        print("update called", element)
        var siUnit : String?

        if element == "Capacitor" {
            siUnit = " F"
            mapToElementValues[0] = Int(( 1000 * mapToValues[0] ) + ( 100 * mapToValues[1] ) + (10 * mapToValues[2] ) + mapToValues[3])
        } else if element == "Inductor" {
            siUnit = " H"
            mapToElementValues[1] = Int(( 1000 * mapToValues[4] ) + ( 100 * mapToValues[5] ) + (10 * mapToValues[6] ) + mapToValues[7])
        } else if element == "Battery" {
            siUnit = " V"
            mapToElementValues[2] = Int(( 1000 * mapToValues[8] ) + ( 100 * mapToValues[9] ) + (10 * mapToValues[10] ) + mapToValues[11])
            mapToElementValues[3] = Int(( 1000 * mapToValues[12] ) + ( 100 * mapToValues[13] ) + (10 * mapToValues[14] ) + mapToValues[15])
        } else {
            return
        }
        
        if element == "Battery" {
            let node1 = sceneView.scene.rootNode.childNode(withName: "batteryTextNode1", recursively: true)
            let nodeParent1 = node1?.parent
            node1?.removeFromParentNode()
            let createString1 = "Battery value = " + String(mapToElementValues[2]) + String(siUnit!)
            let textGeometry1 = SCNText(string: createString1, extrusionDepth: 1)
            textGeometry1.font = UIFont(name: "Futura", size: 9)
            
            let textNode1 = SCNNode(geometry: textGeometry1)
            textNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
            textNode1.opacity = 1
            // scale down the size of the text
            textNode1.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode1.centerAlign()
            textNode1.name = "batteryTextNode1"
            
            nodeParent1!.addChildNode(textNode1)
            
            siUnit = " Hz"
            let node2 = sceneView.scene.rootNode.childNode(withName: "batteryTextNode2", recursively: true)
            let nodeParent2 = node2?.parent
            node2?.removeFromParentNode()
            let createString2 = "Frequency value = " + String(mapToElementValues[3]) + String(siUnit!)
            let textGeometry2 = SCNText(string: createString2, extrusionDepth: 1)
            textGeometry2.font = UIFont(name: "Futura", size: 9)
            
            let textNode2 = SCNNode(geometry: textGeometry2)
            textNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
            textNode2.opacity = 1
            // scale down the size of the text
            textNode2.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode2.centerAlign()
            textNode2.name = "batteryTextNode2"
            
            nodeParent2!.addChildNode(textNode2)
        } else {
            let node = sceneView.scene.rootNode.childNode(withName: "capacitorTextNode", recursively: true)
            let nodeParent = node?.parent
            node?.removeFromParentNode()
            
            let createString = element + " value = " + String(mapToElementValues[mapToElement.firstIndex(of: element)!]) + String(siUnit!)
            let textGeometry = SCNText(string: createString, extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 9)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
            textNode.opacity = 1
            // scale down the size of the text
            textNode.simdScale = SIMD3(repeating: 0.0005)
            //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
            textNode.centerAlign()
            textNode.name = "capacitorTextNode"
            
            nodeParent!.addChildNode(textNode)
        }
        
        //remove and add results
 
        updateResult()

    }
    
    
    func updateResistance (band1color: UIColor, band2color: UIColor, band3color: UIColor, band4color: UIColor) {
        print("update resistance called")
        
        let b1 = mapToSignificantNumbers.firstIndex(of: band1color) ?? 0
        let b2 = mapToSignificantNumbers.firstIndex(of: band2color) ?? 0
        let b3 = mapToSignificantNumbers.firstIndex(of: band3color) ?? 0
        let b4 = mapToSignificantNumbers.firstIndex(of: band4color) ?? 0
        
        print(b1 as Any, b2 as Any, b3 as Any, b4 as Any)
        
        resistorValue = Int64((b1 * 10) + b2)
        
        if Int(b3) > 1 {
            
            resistorValue = resistorValue * Int64( Int(pow( Double(10) , Double(b3) )))
        }
        print(resistorValue)
        
        let node = sceneView.scene.rootNode.childNode(withName: "resistorTextNode", recursively: true)
        
        let nodeParent = node?.parent
        node?.removeFromParentNode()
        
        let createString = "Resistance = " + String(resistorValue) + " Ω"
        
        let textGeometry = SCNText(string: createString, extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 9)
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        textNode.opacity = 1
        // scale down the size of the text
        textNode.simdScale = SIMD3(repeating: 0.0005)
        //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
        textNode.centerAlign()
        textNode.name = "resistorTextNode"
        
        nodeParent!.addChildNode(textNode)
        
        updateResult()
    }
    

    func updateResult () {
        if (mode == "Tutorial") {
            return
        }
        let node = sceneView.scene.rootNode.childNode(withName: "parentCircuit", recursively: false)
        let position = node!.position
        let node2 = sceneView.scene.rootNode.childNode(withName: "resultCircuit", recursively: false)
        node2?.removeFromParentNode()
        print("update result called position ", position as Any)
        
        addResult(position: position)
        
        print("add result completed")
        print("executed", position)
    }
}





extension SCNNode {
    func centerAlign() {
        let (min, min2) = boundingBox
        let extents = SIMD3(repeating: 0) + float3(min2) -  SIMD3(min)
        simdPivot = float4x4(translation: ((extents / 2) + SIMD3(min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4(1, 0, 0, 0),
                  SIMD4(0, 1, 0, 0),
                  SIMD4(0, 0, 1, 0),
                  SIMD4(vector.x, vector.y, vector.z, 1))
    }
}


extension Double {
    var degreesToradians : Double {return Double(self) * .pi/180}
}

extension Int {
    var degreesToradians : Double {return Double(self) * .pi/180}
}

extension Float {
    var degreesToradians : Double {return Double(self) * .pi/180}
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
