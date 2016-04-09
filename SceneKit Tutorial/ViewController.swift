//
//  ViewController.swift
//  SceneKit Tutorial
//
//  Created by Gary Williams on 4/5/16.
//  Copyright © 2016 Gary Williams. All rights reserved.
//

import UIKit
import SceneKit
import AVKit
import AVFoundation
import SpriteKit
import Cartography

class ViewController: UIViewController {
    
    let globals = Globals()
    
    let screenSize:CGRect = UIScreen.mainScreen().bounds
    let masterView = UIView();
    
    let numberOfRings = 5
    let maximumCircumference:Int = 10
    let centerOfTheUniverse:(x: Float, y: Float, z: Float) = (0.0, 0.0, -2.0)
    
    var sceneView:SCNView = SCNView()
    
    var cameraNode: SCNNode = SCNNode()
    let startingCameraPosition = SCNVector3Make(0, 0, 25)
    let fadeInDuration: Double = 2.0
    
    let mainAmbientLight = SCNLight()
    let moodAmbientLight = SCNLight()
    let sunLight = SCNLight()
    let sunParticleSystem = SCNParticleSystem()
    
    var player: AVPlayer?
    
    var universeNode: SCNNode = SCNNode() // All Geometry
    var currentUniverseXAngle: Float = 0.0
    var currentUniverseYAngle: Float = 0.0
    let maxZoom:Float = 12
    
    let currentGraph = SCNNode()
    var currentGraphYAngle: Float = 0.0
    var fakeData:Array<Stat> = []
    var barNodes:Array<SCNNode> = []
    var avgBarNodes:Array<SCNNode> = []
    var pointNodes:Array<SCNNode> = []
    var avgPointNodes:Array<SCNNode> = []
    
    let controlBooth = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildFakeData()
        
        buildMasterView()
        
        buildSceneView()
        
        buildVideo()
        
        buildGalaxy()
        
        buildCamera()
        
        buildFloor()
        
        buildAmbientLights()
        
        buildControls()
        
        
        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        print("from: \(fromInterfaceOrientation.rawValue)")
    }
    
    func buildMasterView() {
        
        masterView.frame.size.height = screenSize.height
        masterView.frame.size.width = screenSize.width
        masterView.backgroundColor = UIColor.blackColor()
        self.view = masterView
    }
    
    func buildSceneView() {
        sceneView.frame = masterView.frame
        
        masterView.addSubview(sceneView)
        
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = UIColor.clearColor()
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        

    }
    
    func buildVideo() {
        
        let videoURL: NSURL = NSBundle.mainBundle().URLForResource("h5-announcement", withExtension: "mp4")!
        
        player = AVPlayer(URL: videoURL)
        player?.actionAtItemEnd = .None
        player?.muted = true
        player?.play()
//        player?.rate = 0.2
        
        let videoWidth = 3840
        let videoHeight = 720
        
        let videoNode:SKVideoNode = SKVideoNode(AVPlayer: player!)
        let spritescene = SKScene(size: CGSize(width: videoWidth, height: videoHeight))
        videoNode.position = CGPointMake(spritescene.size.width/2, spritescene.size.height/2)
        videoNode.size.width = spritescene.size.width
        videoNode.size.height = spritescene.size.height
        videoNode.xScale = 1.0
        videoNode.yScale = -1.0
        spritescene.addChild(videoNode)
        
        // assign SKScene-embedded video to screen geometry
        let screen = SCNPlane()
        screen.width = 80
        screen.height = 45
        screen.firstMaterial?.diffuse.contents  = spritescene
//        screen.firstMaterial?.multiply.contents = spritescene
        let screenNode = SCNNode(geometry: screen)
        screenNode.position = SCNVector3(x: centerOfTheUniverse.x, y: centerOfTheUniverse.y, z: centerOfTheUniverse.z - Float(maximumCircumference) - 0.8)
        
//        let screenLight = SCNLight()
//        screenLight.type = SCNLightTypeOmni
//        screenLight.color = UIColor.whiteColor()
//        screenLight.castsShadow = true
//        screenLight.attenuationStartDistance = 5
//        screenLight.attenuationEndDistance = 8
//        screenNode.light = screenLight
        
        sceneView.scene?.rootNode.addChildNode(screenNode)
        
        //loop video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.loopVideo),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: nil)
    }
    
    func loopVideo() {
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }
    
    func buildGalaxy() {
        // Build Galaxy
        universeNode.position = SCNVector3(x: 0.0, y: 0.0, z: 4.0)
        sceneView.scene?.rootNode.addChildNode(universeNode)
        
        buildSun()
        
        buildRings()
    }
    
    func buildSun() {
        
        // Build the sun
        let sphere = SCNSphere(radius: 1.0)
        let color = UIColor.whiteColor()
        sphere.firstMaterial?.diffuse.contents = color
        
        let theSun = SCNNode(geometry: sphere)
        theSun.name = "sun"
        theSun.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        universeNode.addChildNode(theSun)
        
        // Build out the lighting for the sun
        sunLight.type = SCNLightTypeOmni
        sunLight.color = UIColor.whiteColor()
        sunLight.castsShadow = true
        sunLight.attenuationStartDistance = 8
        sunLight.attenuationEndDistance = 12
        theSun.light = sunLight
        
        // Add particles to the sun
        buildParticleSystem(theSun, type: "sun", color: UIColor.whiteColor(), emitter: sphere)
        
    }
    
    func buildRings() {
        // Calculate the angle increments
        let animationAngleIncrement:CGFloat = CGFloat(M_PI) * 2.0 / 100000 // Smaller increment for animations
        
        // Build the rings
        for i in 1...numberOfRings {
            // How far will this one float from the sun?
            let radiusFromSun:Float = Float(3 + i)
            
            // Create the center point / orbit
            let ring = SCNTube(innerRadius: CGFloat(radiusFromSun - 0.1), outerRadius: CGFloat(radiusFromSun), height: 0.9)
            let ringMaterial = SCNMaterial()
            ringMaterial.diffuse.contents = UIImage(named: "Terrestrial1.png")
            ringMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(1,1,-1);
            ringMaterial.specular.contents = UIImage(named: "Terrestrial1-specular.jpg")
            ringMaterial.specular.contentsTransform = SCNMatrix4MakeScale(1,1,-1);
            
            
            ring.firstMaterial? = ringMaterial
            
            let ringNode = SCNNode(geometry: ring)
            ringNode.name = "ring"
            ringNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
            universeNode.addChildNode(ringNode)
            
            // Rotate the ring
            let yRotation:CGFloat = CGFloat(radiusFromSun) * cos(animationAngleIncrement)
            let xRotation:CGFloat = CGFloat(radiusFromSun) * cos(animationAngleIncrement) + CGFloat(Int.random(-10...10))
            let zRotation:CGFloat = CGFloat(radiusFromSun) * cos(animationAngleIncrement) + CGFloat(Int.random(-10...10))
            
            let rotate = SCNAction.rotateByX(xRotation, y: yRotation, z: zRotation, duration: Double(Int.random(100...120)))
            let sequence = SCNAction.sequence([rotate])
            let repeatedSequence = SCNAction.repeatActionForever(sequence)
            
            ringNode.runAction(repeatedSequence)
        }
        
        addSceneGestureRecognizers()
    }
    
    func buildFakeData() {
        
        for i in 0...30 {
            let stat:Stat = Stat()
            
            stat.name = "Stat \(i)"
            stat.average = Float(Int.random(1...30))
            stat.amount = Float(Int.random(1...30))
            
            fakeData.append(stat)
        }
    }
    
    func hideAllCharts() {
        hideBarChart()
        hideLineChart()
    }
    
    func buildBarChart(data: Array<Stat>) {
        
        for i in 0..<data.count {
            
            let bar = SCNBox(width: 1, height: 0, length: 1, chamferRadius: 0.1);
            let avgBar = SCNBox(width: 0.25, height: 0, length: 1, chamferRadius: 0.1);
            bar.firstMaterial?.diffuse.contents = UIColor.lightGrayColor()
            avgBar.firstMaterial?.diffuse.contents = UIColor.redColor()
            
            let barNode = SCNNode(geometry: bar)
            let avgBarNode = SCNNode(geometry: avgBar)
            barNode.position = SCNVector3(x: Float(i) * 1.75, y:0.0, z:0.0)
            avgBarNode.position = SCNVector3(x: (Float(i) * 1.75) + 0.5, y:0.0, z:0.0)
            
            currentGraph.addChildNode(barNode)
            currentGraph.addChildNode(avgBarNode)
            
            barNodes.append(barNode)
            avgBarNodes.append(avgBarNode)
        }
        
        currentGraph.position = SCNVector3(x:-30, y:-Float(maximumCircumference) - 0.8, z:centerOfTheUniverse.z - (Float(maximumCircumference) / 2))
        sceneView.scene!.rootNode.addChildNode(currentGraph)
        
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(1.0)
        
            for i in 0..<data.count {
                let height = data[i].amount
                let avgHeight = data[i].average
                
                let amountNode = barNodes[i]
                let avgNode = avgBarNodes[i]
                
                let box = amountNode.geometry as! SCNBox
                let avgBox = avgNode.geometry as! SCNBox
                
                box.height = CGFloat(height)
                amountNode.position.y = height / 2
                
                avgBox.height = CGFloat(avgHeight)
                avgNode.position.y = avgHeight / 2
            }
        
        SCNTransaction.commit()
    }
    
    func hideBarChart() {
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(1.0)
        
        for node in barNodes {
            if let geo = node.geometry as? SCNBox {
                geo.height = 0
            }
            node.position.y = 0
        }
        
        for node in avgBarNodes {
            if let geo = node.geometry as? SCNBox {
                geo.height = 0
            }
            node.position.y = 0
        }
        
        SCNTransaction.setCompletionBlock {
            for node in self.barNodes {
                node.removeFromParentNode()
            }
            
            for node in self.avgBarNodes {
                node.removeFromParentNode()
            }
            
            self.barNodes = []
            self.avgBarNodes = []
        }
        
        SCNTransaction.commit()
    }
    
    func buildLineChart(data: Array<Stat>) {
        for i in 0..<data.count {
            
            let point = SCNSphere(radius: 0.5)
            let avgPoint = SCNSphere(radius: 0.2)
            point.firstMaterial?.diffuse.contents = UIColor.lightGrayColor()
            avgPoint.firstMaterial?.diffuse.contents = UIColor.redColor()
            
            let pointNode = SCNNode(geometry: point)
            let avgPointNode = SCNNode(geometry: avgPoint)
            pointNode.position = SCNVector3(x: Float(i) * globals.lineGraphPointMargin, y:-Float(maximumCircumference) - 0.6, z:0.0)
            avgPointNode.position = SCNVector3(x: (Float(i) * globals.lineGraphPointMargin) + 0.2, y:-Float(maximumCircumference) - 0.6, z:1.0)
            
            currentGraph.addChildNode(pointNode)
            currentGraph.addChildNode(avgPointNode)
            
            pointNodes.append(pointNode)
            avgPointNodes.append(avgPointNode)
        }
        
        // Add the line
        let line = SCNShape(path: buildLinePath(), extrusionDepth: 0.1)
        line.firstMaterial?.diffuse.contents = UIColor.grayColor()
        let lineNode = SCNNode(geometry: line)
        lineNode.position = SCNVector3Make(0, 0, 0)
        currentGraph.addChildNode(lineNode)
        
        // Position and Add the Graph
        currentGraph.position = SCNVector3(x:-30, y:-Float(maximumCircumference) - 0.8, z:centerOfTheUniverse.z - (Float(maximumCircumference) / 2))
        sceneView.scene!.rootNode.addChildNode(currentGraph)
        
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(1.0)
        
        for i in 0..<data.count {
            let height = data[i].amount
            let avgHeight = data[i].average
            
            let amountNode = pointNodes[i]
            let avgNode = avgPointNodes[i]
            
//            let point = amountNode.geometry as! SCNSphere
//            let avgPoint = avgNode.geometry as! SCNSphere
            
            amountNode.position.y = height / 2
            avgNode.position.y = avgHeight / 2
        }
        
        SCNTransaction.commit()
    }
    
    func hideLineChart() {
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(1.0)
        
        for node in pointNodes {
            if let geo = node.geometry as? SCNSphere {
                geo.radius = 0
            }
            node.position.y = 0
        }
        
        for node in avgPointNodes {
            if let geo = node.geometry as? SCNSphere {
                geo.radius = 0
            }
            node.position.y = 0
        }
        
        SCNTransaction.setCompletionBlock {
            for node in self.pointNodes {
                node.removeFromParentNode()
            }
            
            for node in self.avgPointNodes {
                node.removeFromParentNode()
            }
            
            self.pointNodes = []
            self.avgPointNodes = []
        }
        
        SCNTransaction.commit()
    }
    
    func buildLinePath() -> UIBezierPath {
        
        let path = UIBezierPath()
        
        var interpolationPoints : [CGPoint] = [CGPoint]()
        
        for i in 0..<fakeData.count {
            let pathPointX = i * Int(globals.lineGraphPointMargin)
            let pathPointY = fakeData[i].amount
            
            interpolationPoints.append(CGPoint(x: pathPointX,y: Int(pathPointY)))
        }
        
        for i in (0..<fakeData.count).reverse() {
            let pathPointX = i * Int(globals.lineGraphPointMargin)
            let pathPointY = (fakeData[i].amount - 2)
            
            interpolationPoints.append(CGPoint(x: pathPointX,y: Int(pathPointY)))
        }
        
        path.interpolatePointsWithHermite(interpolationPoints)
        
        return path
    }
    

    
    func buildParticleSystem(parent: SCNNode, type: String, color: UIColor, emitter: SCNGeometry) {
        
        sunParticleSystem.loops = true
        sunParticleSystem.birthRate = 10000
        sunParticleSystem.emissionDuration = 0.1
        sunParticleSystem.spreadingAngle = 180
        sunParticleSystem.particleDiesOnCollision = true
        sunParticleSystem.particleLifeSpan = 0.02
        sunParticleSystem.particleLifeSpanVariation = 0.05
        sunParticleSystem.particleVelocity = 3
        sunParticleSystem.particleVelocityVariation = 1
        sunParticleSystem.particleSize = 0.1
        sunParticleSystem.particleColor = color
        sunParticleSystem.emitterShape = emitter
        sunParticleSystem.blendMode = SCNParticleBlendMode.Additive
        sunParticleSystem.particleImage = UIImage(named: "spark.png")
        
        parent.addParticleSystem(sunParticleSystem)
    }

    func viewTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0] as SCNHitTestResult
            let node = result.node
            
            if node.name == "planet" {
//                transitionInside(node)
            }
        }
    }
    
    func addSceneGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(self.viewTapped))
        sceneView.gestureRecognizers = [tapRecognizer]
        
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
        sceneView.addGestureRecognizer(panRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
        sceneView.addGestureRecognizer(pinchRecognizer)
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(sender.view!)
        
        var newAngleX = (Float)(translation.y)*(Float)(M_PI)/180.0
        var newAngleY = (Float)(translation.x)*(Float)(M_PI)/180.0
        
        
        // Rotate Universe
        newAngleX += currentUniverseXAngle
        newAngleY += currentUniverseYAngle
        
        universeNode.eulerAngles.x = newAngleX
        universeNode.eulerAngles.y = newAngleY
        
        if(sender.state == UIGestureRecognizerState.Ended) {
            currentUniverseXAngle = newAngleX
            currentUniverseYAngle = newAngleY
        }
        
        // Pan Graph
        print(currentGraph.position.x, translation.x)
        if ((currentGraph.position.x > -50 && translation.x < 0) || (currentGraph.position.x < 20 && translation.x > 0)) {
            currentGraph.position.x += Float(translation.x * 0.01)
        }
    }
    
    func pinchGesture(sender: UIPinchGestureRecognizer) {
        let translation = sender.scale
        
        if translation > 1 {
            let newZ = universeNode.position.z + (Float(translation) * 0.08)
            
            if newZ < maxZoom {
                universeNode.position.z = newZ
            }
        } else {
            universeNode.position.z *= Float(translation)
        }
    }
    
    func buildCamera() {
        // Add Camera
        cameraNode.camera = SCNCamera()
        cameraNode.position = startingCameraPosition
        cameraNode.camera?.focalDistance = 5
        cameraNode.camera?.focalBlurRadius = 100
        
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(fadeInDuration)
            self.cameraNode.camera?.focalBlurRadius = 0
        SCNTransaction.commit()
    }
    
    func buildFloor() {
        let yPos:Float = -Float(maximumCircumference) - 0.8
        
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.reflectionFalloffEnd = 6
        floor.firstMaterial?.diffuse.contents = UIColor.whiteColor()

        let floorNode = SCNNode(geometry: floor)
        floorNode.position.y = yPos
        sceneView.scene?.rootNode.addChildNode(floorNode)
        
        SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(30.0)
            floor.reflectivity = 1.2
        SCNTransaction.commit()
    }
    
    func buildAmbientLights() {

        mainAmbientLight.type = SCNLightTypeOmni
        mainAmbientLight.color = UIColor.whiteColor()
        mainAmbientLight.castsShadow = false
        mainAmbientLight.attenuationStartDistance = 30
        mainAmbientLight.attenuationEndDistance = 100
        
        let mainAmbientLightNode = SCNNode()
        mainAmbientLightNode.position.y = 0
        mainAmbientLightNode.position.z = 30
        mainAmbientLightNode.light = mainAmbientLight
    
        sceneView.scene?.rootNode.addChildNode(mainAmbientLightNode)
        
        moodAmbientLight.type = SCNLightTypeOmni
        moodAmbientLight.color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        moodAmbientLight.castsShadow = false
        moodAmbientLight.attenuationStartDistance = 500
        moodAmbientLight.attenuationEndDistance = 500
        
        let moodAmbientLightNode = SCNNode()
        moodAmbientLightNode.position = SCNVector3Make(0, 0, 0)
        moodAmbientLightNode.light = moodAmbientLight
        
        sceneView.scene?.rootNode.addChildNode(moodAmbientLightNode)
    }
    
    
    func navigate(sender: NavigationButton) {
        
        if let mood = sender.mood {
            setMood(mood)
        }
        
        if let action = sender.action {
            runAction(action)
        }
    }
    
    func runAction(action:String) {
        
        
        if action == "home" {
            hideAllCharts()
        } else if action == "barChart" {
            buildBarChart(fakeData)
        } else if action == "lineChart" {
            buildLineChart(fakeData)
        }
    }
    
    func setMood(mood: String) {
        var mainColor = UIColor.whiteColor()
        var sunColor = UIColor.whiteColor()
        var moodColor = UIColor.blackColor()
        
        if mood == "bad" {
            mainColor = UIColor.darkGrayColor()
            sunColor = UIColor.redColor()
            moodColor = UIColor.redColor()

        } else if mood == "good" {
            mainColor = UIColor.whiteColor()
            sunColor = UIColor.whiteColor()
            moodColor = UIColor.blackColor()
        }
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(0.5)
        cameraNode.position = startingCameraPosition
        mainAmbientLight.color = mainColor
        sunLight.color = sunColor
        sunParticleSystem.particleColor = sunColor
        
        moodAmbientLight.color = moodColor
        moodAmbientLight.attenuationStartDistance = 500
        moodAmbientLight.attenuationEndDistance = 500
        SCNTransaction.commit()
    }
    
    func buildControls() {
        
        controlBooth.backgroundColor = globals.blue
        controlBooth.alpha = 0.5
        
        self.view.addSubview(controlBooth)
        
        constrain(controlBooth) { controls in
            controls.right == controls.superview!.right
            controls.top == controls.superview!.top
            controls.bottom == controls.superview!.bottom
            controls.width == controls.superview!.width * 0.25
        }
        
        let shimView = UIView()
        controlBooth.addSubview(shimView)
        
        constrain(shimView) { shim in
            shim.top == shim.superview!.top
        }
        
        let matchesButton = buildControl(shimView, title: "Home", mood: "good", action: "home")
        let killsButton = buildControl(matchesButton, title: "Bar Graph", mood: "bad", action: "barChart")
        let _ = buildControl(killsButton, title: "Line Graph", mood: "bad", action: "lineChart")
    }
    
    func buildControl(previousEl: UIView, title: String, mood: String, action: String) -> UIButton {
        let button = Buttons.primaryButton(title, font: UIFont.systemFontOfSize(16, weight: UIFontWeightLight))
        button.mood = mood
        button.action = action
        button.addTarget(self, action: #selector(self.navigate), forControlEvents: .TouchUpInside)
        
        controlBooth.addSubview(button)
        
        constrain(previousEl, button) { previousEl, button in
            button.top == previousEl.bottom + 1
            button.left == button.superview!.left
            button.right == button.superview!.right
            button.height == globals.buttonHeight
        }
        
        return button
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
