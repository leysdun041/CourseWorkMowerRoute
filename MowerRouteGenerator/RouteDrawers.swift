//
//  RouteDrawers.swift
//  Automatic Efficient Mowing Path
//
//  Created by Kai Duncumb on 21/08/2020.
//  Copyright © 2020 Kai Duncumb. All rights reserved.
//

import Foundation
import MapKit

//This interface defines something that can be followed and can have a distance and time to follow it. Classes that implement it are line, curve, u-turn curve.
protocol mowerRoute {

    func drawOntoMap(mapView: MKMapView, baseCoord : CLLocationCoordinate2D);
    
    func getSectionTime(vehicle :mowingVehicle)->Double;
    
    func getSectionDistance()->Double;
    
    func getAsPointArray(distance : Double)->[point2D]
    
}

//defines a struct that will store the calculated path and have functions that will display it on the map
class mapReturn {
    
    var baseCoord : CLLocationCoordinate2D
    var partList : linkedList<mowerRoute>
    let DEGREETOMETER=50000.0
    
    init(baseCoord : CLLocationCoordinate2D, partList : linkedList<mowerRoute>){
        self.baseCoord=baseCoord
        self.partList=partList
    }
    
    func displayMap(map : MKMapView, amount : Int){
        guard amount>=0 else{return}
        
        self.partList.resetView()
        for _ in 0...amount{
            if let next=self.partList.nextRead(){
                //print(next.getSectionDistance())
                next.drawOntoMap(mapView: map, baseCoord: self.baseCoord)
            }
        }
    }
    
    func renderLast(map : MKMapView, amount : Int){
        guard amount>=0 else{return}
        
        self.partList.resetView()
        for i in 0...amount{
            if let next=self.partList.nextRead(){
                if i==amount{
                    next.drawOntoMap(mapView: map, baseCoord: self.baseCoord)
                }
            }
        }
    }
    
    func getDistance()->Double{
        var tot=0.0
        for part in self.partList.toArray(){
            tot+=part.getSectionDistance()
        }
        return tot*DEGREETOMETER
    }
    func getTime(vehicle : mowingVehicle)->Double{
        var tot=0.0
        for part in self.partList.toArray(){
            tot+=part.getSectionTime(vehicle: vehicle)
            print(tot)
        }
        return tot
    }
}


extension line2d : mowerRoute{
    func drawOntoMap(mapView: MKMapView, baseCoord:
        CLLocationCoordinate2D) {
        let MULTIPLYCONSTANT=1.0//NOT USED
        let coordTemp=[CLLocationCoordinate2D(latitude: (baseCoord.latitude+self.a.y)/MULTIPLYCONSTANT, longitude: (baseCoord.longitude+self.a.x)/MULTIPLYCONSTANT),CLLocationCoordinate2D(latitude: (baseCoord.latitude+self.b.y)/MULTIPLYCONSTANT, longitude: (baseCoord.longitude+self.b.x)/MULTIPLYCONSTANT)]
        let polyline = MKPolyline(coordinates:coordTemp ,count: 2)
        mapView.addOverlay(polyline)
    }
    
    func getSectionTime(vehicle: mowingVehicle) -> Double {
        let DEGREETOMETER=50000.0
        return (getSectionDistance()*DEGREETOMETER)/vehicle.speed
    }
    
    func getSectionDistance() -> Double {
        return getDistance()
    }
    
    func getAsPointArray(distance: Double) -> [point2D] {
        let amount=Int(getDistance()/distance)
        let range=self.getRange()
        var list = [point2D(x: range.0, y: range.1)]
        for i in 2...amount{
            list.append(list[0].multiply(value: Double(i)))
        }
        return list
    }
}

class simpleCurveConnector :mowerRoute{
    
    var diameter : Double
    var center : point2D
    var a : point2D
    var b : point2D
    //semicircle representation
    init(aGiven : point2D, bGiven : point2D){
        self.center=aGiven.midpoint(other: bGiven)
        self.diameter=line2d(a: aGiven, b: bGiven).getDistance()
        a=aGiven
        b=bGiven
        
    }

    
    func drawOntoMap(mapView: MKMapView, baseCoord: CLLocationCoordinate2D) {
        //draw from point a to b and rest is reperesnted as cicrle
        let coordTemp=[CLLocationCoordinate2D(latitude: (baseCoord.latitude+a.y), longitude: (baseCoord.longitude+a.x)),CLLocationCoordinate2D(latitude: (baseCoord.latitude+b.y), longitude: (baseCoord.longitude+b.x))]
        let polyline = MKPolyline(coordinates:coordTemp ,count: 2)
        mapView.addOverlay(polyline)
       
    }
    
    //Gets the time of a curved section of path
    func getSectionTime(vehicle: mowingVehicle) -> Double {
        let DEGREETOMETER=50000.0
        let distanceTime=(getSectionDistance()*DEGREETOMETER)/vehicle.speed
        let turnTime=vehicle.angularSpeed/Double.pi
        if distanceTime>=turnTime{return distanceTime}
        if turnTime>distanceTime{return turnTime}
        return 0.0
    }
    
    func getSectionDistance() -> Double {
        return Double.pi*self.diameter
    }
    
    
    //May be a broken function
    //Function is not used in the main program so it doesn't matter
    func getAsPointArray(distance: Double) -> [point2D] {
        var points : [point2D]=[]
        print("BEGIN GETTING AS POINT ARRAY")
//        print(distance)
//        print(getSectionDistance())
//        print(self.diameter)
//        print(self.center.tupleRepresentation())
//        print(self.a.tupleRepresentation())
//        print(self.b.tupleRepresentation())
        
        let amount=Int(getSectionDistance()/(2*distance))
        //print(amount)

        let dis=abs(a.x-b.x)
        let minx=a.x-(3*dis)
        let maxx=a.x+(3*dis)
        let spanDis=maxx-minx
        // print(dis)
        for i in 1...amount{
            //print("LOOPING THROUGH AMOUNT")
            let xVal=((Double(i/amount))*dis)+minx
            //print(((Double(i/amount))*dis)+minx)
            let yVal=center.y+sqrt(pow((diameter/2),2)-pow((xVal-center.x),2))
            points.append(point2D(x: xVal, y: yVal))
            //print(xVal,yVal)
        }
        return points
    }
}
