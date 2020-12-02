//import UIKit
//import PlaygroundSupport
//invalid file just for copying stuff into the final program
//
//
//class MyViewController : UIViewController {
//
//    override func loadView() {
//
//        let data1=[[[0.0, 0.0], [0.0, 12.0]], [[0.0, 12.0], [6.0, 12.0]], [[6.0, 12.0], [6.0, 18.0]], [[6.0, 18.0], [0.0, 18.0]], [[0.0, 18.0], [0.0, 30.0]], [[0.0, 30.0], [24.0, 30.0]], [[24.0, 30.0], [24.0, 24.0]], [[24.0, 24.0], [30.0, 24.0]], [[30.0, 24.0], [30.0, 0.0]], [[30.0, 0.0], [0.0, 0.0]]]
//        //let data2=[((0, 0), (0, 20)),  ((0, 20), (20, 20)),  ((20, 20), (20, 5)), ((20, 5), (10, 0))]
//        //let data3=[[[0.0, 0.0], [30.0, 0.0]], [[30.0, 0.0], [30.0, 30.0]], [[30.0, 30.0], [0.0, 30.0]], [[0.0, 30.0], [0.0, 0.0]]]
//        self.view=UIView()
//        self.view.backgroundColor = .black
//        self.drawData(data: data1, muliplier: 10)
//        let usedvehicle=vehicle(speed: 2, turnSpeed: 160, width: 2)
//        let solver=field(data:data1, vehicle: usedvehicle,draw:self)
//        //print(solver.isPointWithinLine(point: (0, 0.5), line: [[0,0],[44,44]], distance: 2))
//        let paths=solver.findRandomRoute(start: (0, 0), resolution: 1)
//        for path in paths{
//            //print("drawing")
//            self.drawPath(path: path.getDraw(multiplier: 10))}
//        //print(solver.doLinesIntersect(l1: line.tupleToLine(tuple: [[0.1, 0.1], [7.07, 7.07]]), l2: line.tupleToLine(tuple: [[0.0, 30.0], [0.0, 0.0]])))
//
//    }
//
//    func drawData(data:[[[Double]]],muliplier:Int){
//        //print(data)
//        for line in data{
//            self.drawLine(a: (line[0][0], line[0][1]), b: (line[1][0], line[1][1]), multiplier: muliplier)
//        }
//    }
//    func drawLine(a:(Double,Double),b:(Double,Double), multiplier:Int){
//        let multiplier=Double(multiplier)
//        let path: UIBezierPath = UIBezierPath()
//        path.move(to: CGPoint(x:a.0*multiplier , y:a.1*multiplier ))
//        path.addLine(to: CGPoint(x: b.0*multiplier, y: b.1*multiplier))
//        self.drawPath(path: path)
//    }
//    func drawPath(path:UIBezierPath){
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//        shapeLayer.strokeColor = UIColor.blue.cgColor
//        //shapeLayer.fillColor = UIColor.white.cgColor
//        shapeLayer.lineWidth = 1.0
//        shapeLayer.position = CGPoint(x: 10, y: 10)
//        let layer=self.view.layer
//        layer.addSublayer(shapeLayer)
//    }
//}
//
//class field{
//    var data:[[[Double]]]
//    var vehicle:vehicle
//    //var draw: MyViewController
//    var visitedNumInUnit: Double
//    var bounds: [Double]
//
//    init(data:[[[Double]]],vehicle:vehicle,draw:MyViewController) {
//        self.data=data
//        self.vehicle=vehicle
//        self.draw=draw
//        self.visitedNumInUnit=2.0
//        self.bounds=[0.0]
//    }
//
//    func findRandomRoute(start:(Double,Double), resolution:Int)->[path]{
//        var route=[path]()
//        print(self.getOptimalParralelLines())
//        return route
//    }
//
//    func getOptimalParralelLines()->Int{
//        var usedAngle=0
//        var minNum=100000
//        let bounds=self.getSquareOfField()
//        let boundStart=(bounds[1],bounds[3])
//        let boundEnd=(bounds[0],bounds[2])
//        let width=self.vehicle.width
//        var point=(0.0,0.0)
//        var pointDown=(0.0,0.0)
//        let angleLine=(atan((bounds[2]-bounds[3])/(bounds[0]-bounds[1])) * 180/Double.pi)
//        for angle in 0...180{
//            print(angle)
//            var angleNum=0
//            point=boundStart
//            pointDown=point
//            while self.isPointInField(point:point){
//                while self.isPointInField(point:pointDown) || !self.isPointOnSquare(point:pointDown){
//                    let next=self.nextLine(start: pointDown, angle: Double(angle))
//                    pointDown=next.1
//                    angleNum+=1
//                }
//                while self.isPointInField(point:pointDown) || !self.isPointOnSquare(point:pointDown){
//                    let next=self.nextLine(start: pointDown, angle: Double(angle+180))
//                    pointDown=next.1
//                    angleNum+=1
//                }
//                print(point)
//                point=(cos(angleLine * Double.pi / 180)*point.0 , sin(angleLine * Double.pi / 180)*point.1)
//
//                angleNum-=1
//                if angleNum<minNum{minNum=angleNum
//                    usedAngle=angle}
//                }
//        }
//        return usedAngle
//    }
//    func nextLine(start:(Double,Double),angle:Double)->(line, (Double,Double)){
//        let increment=30.0
//        let trackLine=line()
//        trackLine.a=start
//        trackLine.b=start
//        var intersect=0
//        while (intersect==0)&&(self.isLineInBounds(line: trackLine)){
//            trackLine.b.0+=increment*cos(angle * Double.pi / 180)
//            trackLine.b.1+=increment*sin(angle * Double.pi / 180)
//            intersect=self.doAnyLinesIntersect(lineTest: trackLine)
//        }
//        let whereIntersect=self.whereDoAnyLinesIntersect(lineTest:trackLine)
//        if whereIntersect.count>0{
//            trackLine.b.0=whereIntersect[0].0
//            trackLine.b.1=whereIntersect[0].1
//        }
//        else{
//            trackLine.b.0-=increment*cos(angle * Double.pi / 180)
//            trackLine.b.1-=increment*sin(angle * Double.pi / 180)
//        }
//        return (trackLine,(trackLine.b.0,trackLine.b.1))
//    }
//    func isLineInBounds(line:line)->Bool{
//        let bounds=self.getSquareOfField()
//        if (line.a.0>=bounds[1])&&(line.a.0<=bounds[0])&&(line.b.0>=bounds[1])&&(line.b.0<=bounds[0])&&(line.a.1>=bounds[3])&&(line.a.1<=bounds[2])&&(line.b.1>=bounds[3])&&(line.b.1<=bounds[2]){
//            return true
//        }
//        else{return false}
//    }
//    func isPointOnSquare(point:(Double,Double))->Bool{
//        bounds=getSquareOfField()
//        if point.0==bounds[0] || point.0==bounds[1] || point.1==bounds[2] || point.1==bounds[3] {
//            return true
//        }
//        else{
//            return false
//        }
//    }
//
////    func getSquareOfField()->[Double]{
////        if self.bounds==[0.0]{
////            var bounds=[0.0,Double.greatestFiniteMagnitude,0.0,Double.greatestFiniteMagnitude]
////            //xMAX,xMIN,YMAX,YMIN
////            for line in self.data{
////                for point in line{
////                    if Double(point[0])>bounds[0]{
////                        bounds[0]=Double(point[0])}
////                    if Double(point[0])<bounds[1]{
////                        bounds[1]=Double(point[0])}
////                    if Double(point[1])>bounds[2]{
////                        bounds[2]=Double(point[1])}
////                    if Double(point[1])<bounds[3]{
////                        bounds[3]=Double(point[1])}
////                }
////            }
////            self.bounds=bounds
////        }
////        return self.bounds
////    }
//    func isPointWithinLine(point:(Double,Double),linea:[[Double]],distance:Double)->(Bool,Bool){
//        var angle=(atan((linea[0][1]-linea[1][1])/(linea[0][0]-linea[1][0])) * 180/Double.pi)
//        if (linea[0][0]-linea[1][0])==0{
//            angle=0
//        }
//        angle+=90
//        let dy=round(sin(angle * Double.pi / 180)*distance)
//        let dx=round(cos(angle * Double.pi / 180)*distance)
//        let minLine=line.tupleToLine(tuple: [[point.0-dx,point.1-dy],[point.0+dx,point.1+dy]])
//        //print(minLine)
//        //let b=self.doAnyLinesIntersect(lineTest:minLine)
//        return (self.doLinesIntersect(l1: minLine, l2: line.tupleToLine(tuple: linea)),false)
//    }
////    func doAnyLinesIntersect(lineTest:line)->Int{
////        var a=0
////        var lineNew=line()
////        for linea in self.data{
////            lineNew=line.tupleToLine(tuple: linea)
////            if self.doLinesIntersect(l1: lineNew, l2: lineTest){
////                //print("linethat intersects")
////                //print(linea)
////                //print(lineTest.toList())
////                a+=1
////            }
////        }
////        return a
////    }
////    func whereDoAnyLinesIntersect(lineTest:line)->[(Double,Double)]{
////        var a=[(Double,Double)]()
////        var lineNew=line()
////        for linea in self.data{
////            lineNew=line.tupleToLine(tuple: linea)
////            let doIsct=self.whereDoLinesIntersect(l1: lineNew, l2: lineTest)
////            if doIsct != nil{
////                a.append(doIsct!)
////            }
////        }
////        return a
////    }
////    func whereDoLinesIntersect(l1:line,l2:line)->(Double,Double)?{
////        if doLinesIntersect(l1:l1, l2:l2){
////            let m1=l1.getSlope()
////            let m2=l2.getSlope()
////            //print("slope")
////            //print(m1,m2)
////
////            if abs(m1) != Double.infinity && abs(m2) != Double.infinity{
////                let y1=l1.a.1
////                let y2=l2.a.1
////                let x1=l1.a.0
////                let x2=l2.a.0
////                //Formula x=(m2x2-y2-m1x1+y1)/(m2-m1)
////                let a=(m2-m1)
////                let x=((m2*x2)-y2-(m1*x1)+y1)/a
////                //Formula y=m1x-m1x1+y1
////                let y=m1*x-m1*x1+y1
////                return(x,y)
////            }
////            //case2 one of the lines is vertical a different calculation is needed, due to the slope being undefined.
////            if abs(m1) == Double.infinity && abs(m2) != Double.infinity{
////                //print("here No")
////                let x=l1.a.0
////                let y=l2.getYfromX(xVal: x)
////                return (x,y)
////            }
////            if abs(m1) != Double.infinity && abs(m2) == Double.infinity{
////                //print("here")
////                let x=l2.a.0
////                let y=l1.getYfromX(xVal: x)
////                return (x,y)
////            }
////            if abs(m1) == Double.infinity && abs(m2) == Double.infinity{return nil}
////            else{return nil}
////        }
////        else{
////            return nil
////        }
////    }
////    //Takes in two line segments and returns whether they intersect
////    func doLinesIntersect(l1:line,l2:line)->Bool{
////        let A=l1.a
////        let B=l1.b
////        let C=l2.a
////        let D=l2.b
////        return ccw(A:A,B:C,C:D) != ccw(A:B,B:C,C:D) && ccw(A:A,B:B,C:C) != ccw(A:A,B:B,C:D)
////
////    }
////    //A helper function for doLinesIntersect
////    func ccw(A:(Double,Double),B:(Double,Double),C:(Double,Double))->Bool{
////        let x=(C.1-A.1) * (B.0-A.0)
////        let y=(B.1-A.1) * (C.0-A.0)
////        return x >= y
////    }
//    //creates a 2d array with 0 storing the points that have been visited.
////    func createFieldVisitedTracker()->tracker{
////        var a=[[Int]]()
////        let bounds=self.getSquareOfField()
////        let dx=Int((bounds[0]-bounds[1])*self.visitedNumInUnit)
////        let dy=Int((bounds[2]-bounds[3])*self.visitedNumInUnit)
////        print(dy,dx )
////        var total=dy*dx
////        print("Genetation of tracker BEGIN")
////        print(total)
////        for x in 0...dx{
////            a.append([Int]())
////            for y in 0...dy{
////                if !self.isPointInField(point: (Double(x)/self.visitedNumInUnit, Double(y)/self.visitedNumInUnit)){
////                    a[x].append(0)
////                    total-=1
////
////                }
////                else{
////                    a[x].append(1)
////                }
////            }
////        }
////        print("Genetation of tracker END")
////        return tracker(val: a, numNeededSpaces: total)
////    }
//    func isPointInField(point:(Double,Double))->Bool{
//        let bounds=self.getSquareOfField()
//        let outPoint=(bounds[1]-1.0,bounds[3]-1.0)
//        let num = self.doAnyLinesIntersect(lineTest:line.tupleToLine(tuple: [[point.0,point.1],[outPoint.0,outPoint.1]]))
//        if num % 2 == 0 {
//          return false
//        } else {
//          return true
//        }
//
//    }
//}
//class curve:path{
//    var start:(Double,Double)
//    var angle:Double
//    var radius:Double
//
//    init(start:(Double,Double),angle:Double,radius:Double){
//        self.start=start
//        self.angle=angle
//        self.radius=radius
//    }
//
//    func getDraw(multiplier: Double) -> UIBezierPath {
//        let path: UIBezierPath = UIBezierPath()
//        path.close()
//        return path
//    }
//
//    func getTime(vehicle: vehicle) -> Double {
//        return vehicle.turnSpeed*self.angle
//    }
//
//    func getLength() -> Double {
//        return (angle/360.0)*2*3.1415*self.radius
//    }
//}
//class line:path{
//    var a:(Double,Double)
//    var b:(Double,Double)
//    init(a:(Double,Double),b:(Double,Double)){
//        self.a=a
//        self.b=b
//    }
//    init(){
//        self.a=(0,0)
//        self.b=(0,0)
//    }
//    func getLength()->Double{
//        return sqrt(pow((Double(self.a.0)-Double(self.b.0)), 2) + pow((Double(self.a.1)-Double(self.b.1)), 2))
//    }
//    func getTime(vehicle: vehicle)->Double {
//        return round(self.getLength()/vehicle.speed)
//    }
//    func getDraw(multiplier:Double) -> UIBezierPath {
//        let path: UIBezierPath = UIBezierPath()
//        path.move(to: CGPoint(x:a.0*multiplier , y:a.1*multiplier ))
//        path.addLine(to: CGPoint(x: b.0*(multiplier), y: b.1*(multiplier)))
//        path.close()
//        return path
//    }
////    func getYfromX(xVal:Double)->Double{
////        let slope=(a.1-b.1)/(a.0-b.0)
////        let yVal=(slope*xVal)-(slope*a.0)+a.1
////        return yVal
////    }
////    func getAngle()->Double{
////        return(atan((a.1-b.1)/(a.0-b.0)) * 180/Double.pi)
////    }
////    func getSlope()->Double{
////        return (a.1-b.1)/(a.0-b.0)
////    }
//
//    static func tupleToLine(tuple:((Double,Double),(Double,Double)))->line{
//        return line(a:tuple.0,b:tuple.1)
//    }
//    static func tupleToLine(tuple:[[Double]])->line{
//        return line(a:(tuple[0][0],tuple[0][1]),b:(tuple[1][0],tuple[1][1]))
//    }
//    func toList()->[[Double]]{
//        return [[a.0,a.1],[b.0,b.1]]
//    }
//}
//protocol path{
//    func getTime(vehicle:vehicle)->Double
//    func getLength()->Double
//    func getDraw(multiplier:Double)->UIBezierPath
//}
//
//class vehicle{
//    let speed:Double
//    let turnSpeed:Double
//    let width:Double
//    init(speed:Double, turnSpeed:Double, width:Double){
//        self.speed=speed
//        self.turnSpeed=turnSpeed
//        self.width=width
//    }
//    func getLength(paths:Array<path>)->Double{
//        var total=0.0
//        for path in paths{
//            total+=path.getLength()
//        }
//        return total
//    }
//    func getTime(paths:Array<path>)->Double{
//        var total=0.0
//        for path in paths{
//            total+=path.getTime(vehicle:self)
//        }
//        return total
//    }
//}
//class tracker{
//    var val:[[Int]]
//    var numNeededSpaces:Int
//    init(val:[[Int]],numNeededSpaces:Int){
//        self.val=val
//        self.numNeededSpaces=numNeededSpaces
//    }
//    func incrementPoint(x:Int,y:Int){
//        self.numNeededSpaces-=1
//        self.val[x][y]+=1
//    }
//    func isFieldFilled(field:tracker)->Bool{
//        return self.numNeededSpaces==0
//    }
//}
//
//
//
//
////PlaygroundPage.current.liveView = MyViewController()
//
//
