//: Playground - noun: a place where people can play

import UIKit
import SceneKit

class Stat {
    
    var name:String = ""
    var amount: Float = 0
    var average: Float = 0
    var showAverage: Bool = true
    
}

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}


extension UIBezierPath
{
    func interpolatePointsWithHermite(interpolationPoints : [CGPoint], alpha: CGFloat = 1.0/3.0)
    {
        guard !interpolationPoints.isEmpty else { return }
        self.moveToPoint(interpolationPoints[0])
        
        let n = interpolationPoints.count - 1
        
        for index in 0..<n
        {
            var currentPoint = interpolationPoints[index]
            var nextIndex = (index + 1) % interpolationPoints.count
            var prevIndex = index == 0 ? interpolationPoints.count - 1 : index - 1
            var previousPoint = interpolationPoints[prevIndex]
            var nextPoint = interpolationPoints[nextIndex]
            let endPoint = nextPoint
            var mx : CGFloat
            var my : CGFloat
            
            if index > 0
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) / 2.0
                my = (nextPoint.y - currentPoint.y) / 2.0
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
            currentPoint = interpolationPoints[nextIndex]
            nextIndex = (nextIndex + 1) % interpolationPoints.count
            prevIndex = index
            previousPoint = interpolationPoints[prevIndex]
            nextPoint = interpolationPoints[nextIndex]
            
            if index < n - 1
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) / 2.0
                my = (currentPoint.y - previousPoint.y) / 2.0
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
            
            self.addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
}

var sceneView:SCNView = SCNView()
var fakeData:Array<Stat> = []

sceneView.scene = SCNScene()
sceneView.backgroundColor = UIColor.clearColor()
sceneView.autoenablesDefaultLighting = false
sceneView.allowsCameraControl = true
sceneView.showsStatistics = true

func buildFakeData() {
    
    for i in 0...30 {
        let stat:Stat = Stat()
        
        stat.name = "Stat \(i)"
        stat.average = Float(Int.random(1...30))
        stat.amount = Float(Int.random(1...30))
        
        fakeData.append(stat)
    }
}

buildFakeData()

func path() -> UIBezierPath {
    
    let path = UIBezierPath()
    
    var interpolationPoints : [CGPoint] = [CGPoint]()
    
    for i in 0..<fakeData.count {
        let pathPointX = i * 1
        let pathPointY = fakeData[i].amount
        
        print(pathPointX)
        print(pathPointY)
        
        interpolationPoints.append(CGPoint(x: pathPointX,y: Int(pathPointY)))
    }
    
    for i in (0..<fakeData.count).reverse() {
        let pathPointX = i * 1
        let pathPointY = (fakeData[i].amount - 2)
        
        print(pathPointX)
        print(pathPointY)
        
        interpolationPoints.append(CGPoint(x: pathPointX,y: Int(pathPointY)))
    }
    
//    interpolationPoints.append(CGPoint(x: 0, y: 0))
//    interpolationPoints.append(CGPoint(x: 50, y: 50))
//    interpolationPoints.append(CGPoint(x: 100, y: 0))
//    
//    interpolationPoints.append(CGPoint(x: 150, y: 0))
//    interpolationPoints.append(CGPoint(x: 200, y: 50))
//    interpolationPoints.append(CGPoint(x: 250, y: 0))
//    
//    //Back
//    interpolationPoints.append(CGPoint(x: 250, y: -2))
//    interpolationPoints.append(CGPoint(x: 200, y: 48))
//    interpolationPoints.append(CGPoint(x: 150, y: -2))
//    
//    interpolationPoints.append(CGPoint(x: 100, y: -2))
//    interpolationPoints.append(CGPoint(x: 50, y: 48))
//    interpolationPoints.append(CGPoint(x: 0, y: -2))
    
    path.interpolatePointsWithHermite(interpolationPoints)
    
    return path
}

let shape = SCNShape(path: path(), extrusionDepth: 0.1)
shape.firstMaterial?.diffuse.contents = UIColor.grayColor()
let carbonNode = SCNNode(geometry: shape)
carbonNode.position = SCNVector3Make(0, 0, 0)

sceneView.scene?.rootNode.addChildNode(carbonNode)
