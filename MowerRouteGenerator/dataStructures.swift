//
//  dataStructures.swift
//  Automatic Efficient Mowing Path
//
//  Created by Kai Duncumb on 21/08/2020.
//  Copyright © 2020 Kai Duncumb. All rights reserved.
//

import Foundation
import MapKit
//this is my definition of a simple point. This is my reason and my functions.
class point2D: Equatable{
    //X is x coord while Y is y coord
    var x : Double
    var y : Double
    
    init(x : Double, y : Double){
        self.x=x
        self.y=y
    }
    //gives a representation as a tuple, good for printing the data out
    func tupleRepresentation()->(Double,Double){
        return (self.x,self.y)
    }
    //Multiplies the point by the double, useful for translating stuff
    func multiply(value : Double)->point2D{
        return point2D(x: self.x*value, y: self.y*value)
    }
    //Finds the midpoint between two points
    func midpoint(other : point2D)->point2D{
        return point2D(x: (self.x+other.x)/2, y: (self.y+other.y)/2)
    }
    //Finds the distance between two points
    func getDistance(other : point2D)->Double{
        let dx=self.x-other.x
        let dy=self.y-other.y
        return (dx * dx + dy * dy).squareRoot()
    }
    
}
//This datasturcture takes 2 points and creates a line out of them. Multiple helper functions like magnitude are included
class line2d :Equatable{
    
    var a : point2D
    var b : point2D
    
    init(a : point2D, b : point2D){
        self.a=a
        self.b=b
    }
    init(){//Init if you want a default point.
        self.a=point2D(x:0,y:0)
        self.b=point2D(x:0,y:0)
    }
    func tupleRepresentation()->[(Double,Double)]{
        return [self.a.tupleRepresentation(),self.b.tupleRepresentation()]
    }
    func asList()->[point2D]{
        return [self.a,self.b]
    }
    
    func getMidpoint()->point2D{
        return point2D(x: (self.a.x+self.b.x)/2, y: (self.a.y+self.b.y)/2)
    }
    
    func getDistance()->Double{
        let dx=self.a.x-self.b.x
        let dy=self.a.y-self.b.y
        return (dx * dx + dy * dy).squareRoot()
    }
    func getRange()->(Double,Double){//in format dx, dy
        return (self.a.x-self.b.x, self.a.y-self.b.y)
    }
    
    //Takes in two line segments and returns whether they intersect
    func doesLineIntersect(line : line2d)->Bool{
        let A=self.a
        let B=self.b
        let C=line.a
        let D=line.b
        return ccw(A:A,B:C,C:D) != ccw(A:B,B:C,C:D) && ccw(A:A,B:B,C:C) != ccw(A:A,B:B,C:D)
    }
    //A helper function for doesLineIntersect
    private func ccw(A:point2D,B:point2D,C:point2D)->Bool{
        let x=(C.y-A.y) * (B.x-A.x)
        let y=(B.y-A.y) * (C.x-A.x)
        return x >= y
       }
    
    //implementation of ==
    static func == (lhs: line2d, rhs: line2d) -> Bool {
        if lhs.a.x==rhs.a.x,lhs.b.x==rhs.b.x,lhs.a.y==rhs.a.y,lhs.b.y==rhs.b.y{
            return true
        }else{return false}
    }
    //Input xvalue get xvalue anywhere along the line
    func getYfromX(xVal:Double)->Double{
        let yVal=(getSlope()*xVal)-(getSlope()*a.x)+a.y
        return yVal
    }
    func getAngle()->Double{
        return(atan((a.y-b.y)/(a.x-b.x)) * 180/Double.pi)
    }
    func getSlope()->Double{
        return (a.y-b.y)/(a.x-b.x)
    }
    func whereDoLinesIntersect(line: line2d)->point2D?{
        if self.doesLineIntersect(line: line){
            let m1=self.getSlope()
            let m2=line.getSlope()
            //Case 1: None of the lines are vertical
            if abs(m1) != Double.infinity && abs(m2) != Double.infinity{
                let y1=self.a.y
                let y2=line.a.y
                let x1=self.a.x
                let x2=line.a.x
                //Formula x=(m2x2-y2-m1x1+y1)/(m2-m1)
                let a=(m2-m1)
                let x=((m2*x2)-y2-(m1*x1)+y1)/a
                //Formula y=m1x-m1x1+y1
                let y=m1*x-m1*x1+y1
                return point2D(x: x,y: y)
            }
            //Case 2: one of the lines is vertical a different calculation is needed, due to the slope being undefined.
            if abs(m1) == Double.infinity && abs(m2) != Double.infinity{
                let x=self.a.x
                let y=line.getYfromX(xVal: x)
                return point2D(x: x,y: y)
            }
            if abs(m1) != Double.infinity && abs(m2) == Double.infinity{
                let x=line.a.x
                let y=self.getYfromX(xVal: x)
                return point2D(x: x,y: y)
            }
            //Case 3: two vertical lines
            if abs(m1) == Double.infinity && abs(m2) == Double.infinity{return nil}
            else{return nil}
        }
        else{
            return nil
        }
    }
    static func getLineFromSlope(point : point2D, angle : Double, distance : Double, canNegative : Bool)->line2d{
        let dx=distance*cos(angle.rad)
        let dy=distance*sin(angle.rad)
        //print(dx)
        //print(dy)
        if canNegative{
            return line2d(a: point2D(x: point.x-dx, y: point.y-dy), b: point2D(x: point.x+dx, y: point.y+dy))
        }else{
           return line2d(a: point2D(x: point.x, y: point.y), b: point2D(x: point.x+dx, y: point.y+dy))
        }
    }
    //ispt = y intercept
    static func getLineFromEquation(slope : Double, ispt : Double, xRange : (Double,Double))->line2d{
        return line2d(a: point2D(x: xRange.0, y: (xRange.0*slope)+ispt), b: point2D(x: xRange.1, y: (xRange.1*slope)+ispt))
    }
}

//This datastructure defines a polygon that will be inside of outside of the field
struct innerFieldPolygon{
    var lineList : [line2d]
    
    init(lineList : [line2d]){
        self.lineList=lineList
    }
    
    mutating func addLine(line : line2d){
        lineList.append(line)
    }
}

//This data structure defines the field that will be processed.
//There is a base coordinate that maps the field to a real world location
//The rest of the line definitions are relative to the base location.
class fieldData{
    var baseLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var valid=true
    var fullData : [innerFieldPolygon]=[]
    var lineData : [line2d]?
    var beginNode : point2D = point2D(x: 0, y: 0)
    var MINDISTANCE : Double = 10000.0
    
    //TODO make this auto connect
    
    init(mapData : [[(CLLocationCoordinate2D,CLLocationCoordinate2D)]]){
        //check that data exists
        for subData in mapData{
            if subData.count<1{
                self.valid=false;return
            }
        }
        
        //loop through all the points to find a minimum coordinate location. This will be used as a reference point for all of the data in field data
        var minX = Double.greatestFiniteMagnitude
        var minY = Double.greatestFiniteMagnitude
        for i in mapData{
            for coord in i{
                if coord.0.latitude<minY {minY=coord.0.latitude}
                if coord.0.longitude<minX {minX=coord.0.longitude}
            }
        }
        
        //Get baseLocation
        baseLocation=CLLocationCoordinate2D(latitude: minY, longitude: minX)
        
        //This is finding the first node and will be used to identify the way to traverse the graph.
        beginNode=point2D.pointCreationFromCoord(coordBase: baseLocation, coordCurrent: mapData[0][0].0)
        
        //This is verifying that the data is correctly inputed and making any adjustments if nessesary or marking the data as bad.
        
        var pointCurrent : point2D
        var pointNext : point2D
        var currentLine : line2d
        var currentPolygon : innerFieldPolygon
        for var inner in mapData{
            if inner.count>0{
            currentPolygon=innerFieldPolygon(lineList:[])
                
            //check for if it is a round polygon by only checking the first and last points
                pointCurrent=point2D.pointCreationFromCoord(coordBase: baseLocation, coordCurrent: inner[0].0)
                pointNext=point2D.pointCreationFromCoord(coordBase: baseLocation, coordCurrent: inner[inner.count-1].1)
                currentLine=line2d(a: pointCurrent, b: pointNext)
            //checks if the distance between first and last is within a neglegsble range and make them join up.
            if currentLine.getDistance()>self.MINDISTANCE{//deprecated clause will always default to else
             //points don't connect here at all
                self.valid=false
            }else{
                //if close enough sets the last point in polygon to the first to create complete
                inner[inner.count-1].1=inner[0].0
            }
                
            //Now we loop through all of the points in the polygon too loop them up
            for i in 0...inner.count-1{
                pointCurrent=point2D.pointCreationFromCoord(coordBase: baseLocation, coordCurrent: inner[i].0)
                pointNext=point2D.pointCreationFromCoord(coordBase: baseLocation, coordCurrent: inner[i].1)
                currentLine=line2d(a: pointCurrent, b: pointNext)
                    currentPolygon.addLine(line: currentLine)
            }
            self.fullData.append(currentPolygon)
            }
        }
        
        //set the linedata that is without the polygons attached
        var lineDataNew : [line2d]=[]
        for polygon in self.fullData{
            for line in polygon.lineList{
                lineDataNew.append(line)
            }
        }
        self.lineData=lineDataNew
        //FINAL TEST: line intersection tests if lines intersect by looping through all combinations of them.
        for line1 in lineDataNew{
            for line2 in lineDataNew{
                if !(line1.a.x==line2.a.x||line1.b.x==line2.b.x||line1.a.x==line2.b.x||line1.b.x==line2.a.x||line1.a.y==line2.a.y||line1.b.y==line2.b.y||line1.a.y==line2.b.y||line1.b.y==line2.a.y){//Check to see if the lines are connected
                    if line1 != line2{
                            if line1.doesLineIntersect(line: line2){
                                print("Invalidate")
                                print(line1.tupleRepresentation())
                                print(line2.tupleRepresentation())
                                self.valid=false
                        }
                    }
                }
            }
        }
        //END IF INITIALIZATION
    }
    
    func isValid()->Bool{
        return self.valid
    }
    
    func drawFieldData(map : MKMapView){
        for line in getFullLine(){
            line.drawOntoMap(mapView: map, baseCoord: baseLocation)
        }
    }
    
    //gets the full line ignoring the polygon struct inbetween
    func getFullLine()->[line2d]{
        if let data = self.lineData {
            return data
        }else{//Else statement may be redundant code. MAY WANT TO DELETE
            var lineDataNew : [line2d]=[]
            for polygon in self.fullData{
                for line in polygon.lineList{
                    lineDataNew.append(line)
                }
            }
            self.lineData=lineDataNew
            return lineDataNew
        }
    }
    //this function gets the square of a field, the absolute bounds of the field
    func getSquareOfField()->fieldBounds{
        var bounds=fieldBounds(xMax: 0.0, xMin: Double.greatestFiniteMagnitude, yMax: 0.0, yMin: Double.greatestFiniteMagnitude)
        //xMAX,xMIN,YMAX,YMIN
        for line in getFullLine(){
            for point in line.tupleRepresentation(){
                if Double(point.0)>bounds.xMax{
                    bounds.xMax=Double(point.0)}
                if Double(point.0)<bounds.xMin{
                    bounds.xMin=Double(point.0)}
                if Double(point.1)>bounds.yMax{
                    bounds.yMax=Double(point.1)}
                if Double(point.1)<bounds.yMin{
                    bounds.yMin=Double(point.1)}
                }
            }
        return bounds
    }
    func doAnyLinesIntersect(lineTest:line2d)->Int{
        var a=0
        for lineField in getFullLine(){
            if lineTest.doesLineIntersect(line: lineField){
                a+=1
            }
        }
        return a
    }
    func whereDoAnyLinesIntersect(lineTest:line2d)->[point2D]{
        var a : [point2D] = []
        for lineField in getFullLine(){
            let doIsct=lineTest.whereDoLinesIntersect(line: lineField)
            if let isct = doIsct{
                a.append(isct)
            }
        }
        return a
    }
}

//This data structure defines all the charachtereisics of a vehicle.
struct mowingVehicle{
    var name : String //Name of the vehicle
    var speed : Double //Meters per second
    var angularSpeed : Double //radians per secong
    var width : Double //Meters
}

//this struct defines settings that can be used by the route generator
struct generatorSettings{
    var numAngle : Int
    var closestNum: Int
}


//This struct is an easy way of storing bounaries of a field
struct fieldBounds{
    var xMax : Double
    var xMin : Double
    var yMax : Double
    var yMin : Double
    
    func listRepr()->[Double]{
        return [xMax,xMin,yMax,yMin]
    }
}

//Extending my point 2D class to make it easier to create points from the difference between a base coord and a coord.
extension point2D{
    static func pointCreationFromCoord(coordBase:CLLocationCoordinate2D , coordCurrent :CLLocationCoordinate2D)->point2D{
        let MULTIPLYCONSTANT=1.0
        return point2D(x: (coordCurrent.longitude-coordBase.longitude)*MULTIPLYCONSTANT, y: (coordCurrent.latitude-coordBase.latitude)*MULTIPLYCONSTANT)
    }
}


//Generic implementation of a graph data structure.
//T is the connector data  (Line)
//S is the node data (Point)
public class graph<T,S: Hashable> {
    private var mapping = [table<S> : T]()
    public var initial : S?
    init(){
        //nothing goes here
    }
    func insertLine(line:T, node1:S, node2:S){
        if let _ = initial{initial=node1}
        let table1=table(data: (node1, node2))
        let table2=table(data: (node2, node1))
        mapping[table1]=line
        mapping[table2]=line
    }
    
    func traverse(node:S)->[(S,T)]{
        var nodeList=[(S,T)]()
        
        for tablePair in mapping{
            if tablePair.0.data.0==node{
                nodeList.append((tablePair.0.data.1 , tablePair.1))
            }
        }
        return nodeList
    }

    func returnAllConnect()->[T]{
        var temp = [T]()
        for (_,value) in mapping{
            temp.append(value)
        }
        return temp
    }
}

private struct table<S: Hashable>:Hashable{
    
    static func == (lhs: table<S>, rhs: table<S>) -> Bool {
        if lhs.data.0==rhs.data.0 && lhs.data.1==rhs.data.1{
            return true
        }else{return false}
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(data.0.hashValue)
        hasher.combine(data.1.hashValue)
    }
    
    var data : (S,S)
}

//This linkes list allows u to store a variable of value T. And then use the next read function to read off the list one by one as that is really the only way that the list is going to be read.
public struct linkedList<T>{
    private var headNode: Node<T>?
    private var tailNode: Node<T>?
    private var nodeList = [Node<T>]()
    private var viewingNode=0
    
    //adds a value to the end of the list
    mutating func addHead(value:T){
        if let head=headNode {
            let next=head.nextNode
            nodeList.append(head)
            headNode=Node(value: value, nextNode: next+1, id: next)
        }else{
            tailNode=Node(value: value, nextNode: 1, id: 0)
            headNode=Node(value: value, nextNode: 1, id: 0)
        }
    }
    //This function allows u to reset the viewer to begin reading the list from the beggining.
    mutating func resetView(){viewingNode=0}
    
    //This implementation will read the next item in the list where viewing node always corresponds to the next item. This is because the list will always be read in order. When it is usd.
    //if nil is returned then linked list is empty
    mutating func nextRead()->T?{
        //print("READING FROM LINKED LIST")
        guard let tail=tailNode else {return nil}
        //check to see if the tail is the current node
        if viewingNode==tail.id{
            viewingNode=tail.nextNode
            return tail.value
        }
        //check to see if head node exists
        if let head=headNode{if head.id==viewingNode{return head.value}}
        if (tail.id==viewingNode){return tail.value}
        for node in nodeList{
            if node.id==viewingNode{
                viewingNode=node.nextNode
                return node.value
            }
        }
        return nil
    }
    
    //Returns just an array
    func toArray()->[T]{
        var tempList=[T]()
        if let head=headNode{tempList.append(head.value)}
        //if let tail=tailNode{tempList.append(tail.value)}
        for node in nodeList{
            tempList.append(node.value)
        }
        return tempList
    }
    
    //This is a node that lets you store simple stuff in the linkes list and it is only intended for use within the struct itself as the storage area.
    private struct Node<T>{
        let value : T
        let nextNode : Int
        let id : Int
    }
}


