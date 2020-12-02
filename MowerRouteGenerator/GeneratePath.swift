//
//  GeneratePath.swift
//  Automatic Efficient Mowing Path
//
//  Created by Kai Duncumb on 21/08/2020.
//  Copyright © 2020 Kai Duncumb. All rights reserved.
//

import Foundation
import MapKit

//This is the main class that will generate the route.
class generatePath{
    var field : fieldData
    let vehicle : mowingVehicle
    var maxDistancePossible : Double?
    var bounds : fieldBounds
    let settings : generatorSettings
    
    init(field : fieldData, vehicle : mowingVehicle, settings : generatorSettings){
        self.field=field
        self.vehicle=vehicle
        self.bounds=self.field.getSquareOfField()
        self.settings=settings
    }
    
    //The main function that is called to generate the route
    func calculateFinal()->mapReturn{
        //This finds the best route of just lines
        let bestRoute=calculateBestLines()
        //generate the graph
        let graph=generateGraph(lines: bestRoute)
        //calculate the final roue
        let connectedRoute=calculateBetweenRoute(fieldGraph: graph)
        
        //This creates a map drawer object with all the data and returns it to the main program.
        return mapReturn(baseCoord: self.field.baseLocation, partList:connectedRoute)
    }
    
    func generateGraph(lines:[line2d])->graph<mowerRoute,point2D>{
        let fieldGraph=graph<mowerRoute,point2D>()
        let pointList=getListOfPoints(bestRoute: lines)
        //loop thru all the lines
        for line in lines{
            //Insert the line into the graph
            fieldGraph.insertLine(line: line, node1: line.a, node2: line.b)
            //Loop thru the 2 points at the end of the line
            for point in [line.a,line.b]{
                //get closest points to the end of line points
                let closest=getClosestPoints(mainPoint: point, pointList: pointList, amount: self.settings.closestNum)
                for closestPoint in closest{
                    //create a curve connector object and attach it to the end of the two points
                    //Check to see if the points are thee same
                    if point.x != closestPoint.x , point.y != closestPoint.y{
                        let curve=simpleCurveConnector(aGiven: point, bGiven: closestPoint)
                        //insert this new thing to the graph
                        fieldGraph.insertLine(line: curve, node1: point, node2: closestPoint)
                    }
                }
            }
        }
        
        return fieldGraph
    }
    
    func calculateBetweenRoute(fieldGraph : graph<mowerRoute,point2D>)->linkedList<mowerRoute> {
        print("Calculate Between Route")
        //Create the linked list to put the final path into
        var link=linkedList<mowerRoute>()
        
        //Step 1: Find the starting node as a point2d
        let pointList=self.getListOfPointsGraph(fieldGraph: fieldGraph)
        let initPoint=self.field.beginNode
        var closest=Double.greatestFiniteMagnitude
        var closestNode = point2D(x: 0.0, y: 0.0)
        for point in pointList{
            let dis=initPoint.getDistance(other: point)
            if dis<closest{
                closestNode=point
                closest=dis
            }
        }
        
        //variable initialization
        let allPaths=fieldGraph.returnAllConnect()
        var linesRemain=getLinesFromGraph(fieldGraph: fieldGraph)
        var currentNode=closestNode
        var lastLine : line2d?
        
        while linesRemain.count>1{
            //Begin processing each line for the next thing
            var closestLine = line2d()
            var closestDis=Double.greatestFiniteMagnitude
            for line in linesRemain{
                let midpoint=line.getMidpoint()
                let dis=currentNode.getDistance(other: midpoint)
                if dis<closestDis{
                    closestLine=line
                    closestDis=dis
                }
            }
            //closestLine is now what we are trying to aim for
            let a=self.findRouteNodeToLine(fieldGraph: fieldGraph, node: currentNode, line: closestLine, lastLine: lastLine ?? line2d())
            lastLine=closestLine
            
            let route=a.0
            let nextNode=a.1
            
            for subRoute in route{
                link.addHead(value: subRoute)
            }
            currentNode=nextNode
                
            //Here we finish by removing the line we just move to and processed
            linesRemain = linesRemain.filter {$0 != closestLine}
        }
        
        return link
    }
    
    //This function takes a graph a node that is the starting and A line that is the destination. It will find the fastest route there.
    func findRouteNodeToLine(fieldGraph : graph<mowerRoute,point2D>,node : point2D, line : line2d, lastLine : line2d)->([mowerRoute],point2D){//Function returns route as mowerRoute array and the next node to start recalculation
        print("FINDING ROUTE")
        print(line.tupleRepresentation())
        let a=traverseOne(beginPoint: node, beginLine: nil, fieldGraph: fieldGraph, destinyLine: line, count: 0,lineCannotTraverse: lastLine)
        var route=a.0
        var endPoint=a.1
         
        route.reverse()
        print("ROUTE LENGTH")
        print(route.count)
        
        if route.count==0{
            let b = getPointToLineDirect(beginPoint: node, fieldGraph: fieldGraph, destinyLine: line)
            route=b.0
            endPoint=b.1
        }
        
        return (route,endPoint!)
    }
    
    func getPointToLineDirect(beginPoint : point2D,fieldGraph : graph<mowerRoute,point2D>,destinyLine : line2d)->([mowerRoute],point2D){
        
        if beginPoint.getDistance(other: destinyLine.a)>beginPoint.getDistance(other: destinyLine.b){
            //Use destinyLine.b
            return ([line2d(a: beginPoint, b: destinyLine.b),destinyLine],destinyLine.a)
        }else{//Use destinyLine.a
            return ([line2d(a: beginPoint, b: destinyLine.a),destinyLine],destinyLine.b)
        }
    }
    
    //recursion
    func traverseOne(beginPoint : point2D, beginLine:mowerRoute?, fieldGraph : graph<mowerRoute,point2D>, destinyLine : line2d, count : Int, lineCannotTraverse : line2d)->([mowerRoute],point2D?){

        let MAXCOUNT=6
        if count>MAXCOUNT{
            return ([],nil)
        }
        var returnedRoute=[mowerRoute]()
        var nextPoint : point2D = point2D(x: 0,y: 0)
        //check to see if the jackpot is found
        if let beginLineUnwrapped=beginLine{
            if beginLineUnwrapped is line2d{
                let ew=beginLineUnwrapped as? line2d
                if ew!.a==lineCannotTraverse.a , ew!.b==lineCannotTraverse.b{
                    return ([],nil)
                }
            }
            if (beginLineUnwrapped as? line2d) == destinyLine{
                let endPoint : point2D
                if destinyLine.a.x == beginPoint.x , destinyLine.a.y == beginPoint.y{
                    endPoint=destinyLine.a
                }else{endPoint=destinyLine.b
                }
                return ([destinyLine],endPoint)
            }
        }
        
        let branches=fieldGraph.traverse(node: beginPoint)
        print(branches.count)
        
        var bestScore=Double.greatestFiniteMagnitude
        var bestReturnedRoute = [mowerRoute]()
        
        for branch in branches{
            print(branch.0.tupleRepresentation())
            if branch.1 is line2d{
                let abs=branch.1 as? line2d
                print(abs!.tupleRepresentation())
            }
            
            let newPoint=branch.0
            let newRoute=branch.1
                
            let a=traverseOne(beginPoint: newPoint, beginLine: newRoute, fieldGraph: fieldGraph, destinyLine: destinyLine, count: count+1, lineCannotTraverse: lineCannotTraverse)
            
            let possibleNextPoint=a.1
            returnedRoute=a.0
            
            var isReturned=true
            if returnedRoute.count==0{
                isReturned=false
            }
            
            if let beginLineUnwrapped=beginLine{
                returnedRoute.append(beginLineUnwrapped)
            }
            
            let returnedRouteScore=getLineDistance(returnedRoute)
                
            if returnedRouteScore<bestScore && isReturned==true{
                bestScore=returnedRouteScore
                bestReturnedRoute=returnedRoute
                nextPoint=possibleNextPoint!
            }
        }
        
        return (bestReturnedRoute,nextPoint)
    }
    
    //This function inputs a mowerRoute array and finds the total distance to travel.
    func getLineDistance(_ returnedRoute : [mowerRoute])->Double{
        var total=0.0
        for route in returnedRoute{
            total+=route.getSectionDistance()
        }
        return total
    }
    
    func calculateBestLines()->[line2d]{
        
        //Get Bounds and
        let boundsField = self.field.getSquareOfField()
        //print(boundsField.listRepr())
        //get the max possible width of the field. This value is used to extend lines along an angle as if they were an infinite line, but I have no way to represent this without other stuff getting in the way.
        self.maxDistancePossible=line2d(a: point2D(x: boundsField.xMin,y: boundsField.yMin), b: point2D(x: boundsField.xMax,y: boundsField.yMax)).getDistance()
        
        //angle range -90 to 90 cannot equal 0.0
        var angle = -90.0
        let angleDistance=180.0/Double(self.settings.numAngle)
               
        //set up variables for testing
        var bestScore = 0.0
        var bestAngle=0.0
               
        //loop through all of the angles and generate scores for all of them. The best score is the returned.
        while angle<=90.0{
            //print(angle)
            let route = self.createPararelLines(angle: angle)
            let score = self.generateScore(lines: route)

            if score>bestScore{
                bestScore=score
                bestAngle=angle
            }
            angle+=angleDistance
        }
        //bestRoute = self.createPararelLines(angle: 45.0)
        //create returner and the drawer to return to main program
        let bestRoute = self.createPararelLines(angle: bestAngle)
        print("SEA- BestAngle: "+String(bestAngle))
        return bestRoute
    }
    
    //This function is used to generate an approximate ranking score for each parralel line route. It is based on range of lengths, average length length, and number of lengths. This will produce a number where the higher the number the better it is.
    func generateScore(lines : [line2d])->Double{
        let getter=lineAnylisis(partListGiven: lines)
        let num=((1/Double(lines.count))*1.0)
        let average=getter.getAverageDistance()*1.0
        let range=((1/getter.getRange())*1.0)
        
        let score=num+average+range
          print(score)
        
        return score
    }
    
    //function to create parrarel line
    func createPararelLines( angle : Double)->[line2d]{
        //check to see if angle is 90.0 , this will cause problems
        guard abs(angle) < 85.0 else {return []}
        
        //initialize default variables
        var lineList : [line2d]=[]
        
        //get slope and range
        let slope=tan(angle.rad)
        let range=(self.field.getSquareOfField().xMin,self.field.getSquareOfField().xMax)
        
        let lower=(self.field.getSquareOfField().yMin)-(self.maxDistancePossible!)*10
        let upper=(self.field.getSquareOfField().yMax)+(self.maxDistancePossible!)*10
        let distanceY=self.vehicle.width/cos((abs(angle)).rad)
        var curY=lower
        
        //loop through all of the y coords of the y axis and move line up.
        while curY<upper{
            //print(curY)
            curY+=distanceY //y-ispt
            let line=line2d.getLineFromEquation(slope: slope, ispt: curY, xRange:range)
    
             if self.field.doAnyLinesIntersect(lineTest: line)>0{
                 var intersectionPoints=self.field.whereDoAnyLinesIntersect(lineTest: line)
                 //creates the lines!
                 if intersectionPoints.count>1{
                     //sorts the lines to avoid any problems in the drawing.
                     intersectionPoints.sort {$0.x < $1.x}
                     for i in 0...(intersectionPoints.count)-1{
                         //even number of intersections, just a precaution, not that it will ever happen.
                         if i%2==0{
                             let appendedLine=line2d(a:intersectionPoints[i], b: intersectionPoints[i+1])
                             lineList.append(appendedLine)
                         }
                     }
                 }
             }
        }
        return lineList
    }
    
    //Simple Utility function that will get a list of points in the whole array is lines.
    func getListOfPoints(bestRoute:[line2d])->[point2D]{
        var pointList:[point2D]=[]
        for line in bestRoute{
            for i in 0...1{
                pointList.append(line.asList()[i])
            }
        }
        return pointList
    }
    
    func getListOfPointsGraph(fieldGraph:graph<mowerRoute,point2D>)->[point2D]{
        var pointList:[point2D]=[]
        let lineList=getLinesFromGraph(fieldGraph: fieldGraph)
        for line in lineList{
            for i in 0...1{
                pointList.append(line.asList()[i])
            }
        }
        
        return pointList
    }
    
    func getLinesFromGraph(fieldGraph:graph<mowerRoute,point2D>)->[line2d]{
        var lineList:[line2d]=[]
        let edgeList=fieldGraph.returnAllConnect()
        for edge in edgeList{
            if let lineEdge = edge as? line2d{
                lineList.append(lineEdge)
            }
        }
        return lineList
    }
        
    
    //This function inputs a point and a list of points and outputs the closest points
    //where the number of points if given by amount.
    func getClosestPoints(mainPoint:point2D, pointList:[point2D], amount:Int)->[point2D]{
        var smallerList:[point2D]=[]
        var distanceList:[(point2D,Double)]=[]
        //Create a temporaty list to store points with distances
        for point in pointList{
            let distance = mainPoint.getDistance(other: point)
            distanceList.append((point, distance))
        }
        //Sorts the distance list to find the top amount distances
        distanceList.sort {$0.1 < $1.1}
        for i in 0...amount-1{smallerList.append(distanceList[i].0)}
        
        return smallerList
    }
}

//simple way to convert to radians and degrees
extension Double {
    public var rad: Double { return self * .pi / 180 }
    public var degrees: Double { return self * 180 / .pi }
}

class lineAnylisis{
    var partList : [mowerRoute]
    
    init(partListGiven : [mowerRoute]){
        partList=partListGiven
    }
    
    func getRange()->Double{
        var min = Double.greatestFiniteMagnitude
        var max = 0.0
        for line in self.partList{
            let distance=line.getSectionDistance()
            if distance<min {min=distance}
            if distance>max {max=distance}
        }
        return max-min
    }
    
    func getAverageDistance()->Double{
        var total=0.0
        for line in self.partList{
            total+=line.getSectionDistance()
        }
        return total/Double(self.partList.count)
    }
    
    
}

extension point2D:Hashable{
    static func == (lhs: point2D, rhs: point2D) -> Bool {
        if lhs.x==rhs.x , lhs.y==rhs.y{return true}
        else{return false}
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.x.hashValue)
        hasher.combine(self.y.hashValue)
    }
    
}
