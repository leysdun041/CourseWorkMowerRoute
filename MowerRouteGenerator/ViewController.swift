//
//  ViewController.swift
//  Automatic Efficient Mowing Path
//
//  Created by Kai Duncumb on 03/06/2020.
//  Copyright © 2020 Kai Duncumb. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate {

    //program state
    private var currentProgramState :programState = .userInput{
        didSet{
            setProgramState()
        }
    }
    
    //outlet definitions
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var progressWheel: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toggleZoom: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    
    @IBOutlet weak var timeOutput: UILabel!
    @IBOutlet weak var distanceOutput: UILabel!
    
    @IBOutlet weak var speedValue: UITextField!
    @IBOutlet weak var angularValue: UITextField!
    @IBOutlet weak var widthValue: UITextField!
    
    
    
    //this is the raw map data from the user's touches on the screen. It is gathered in a 2d array the first dimention changes everytime the user clicks add inner border.
    var pointsInput=[[(CLLocationCoordinate2D,CLLocationCoordinate2D)]()] {
        didSet {
            //print(points)
        }
    }
    var pointsDisplay=[[CLLocationCoordinate2D]()]
    
    var prevCoord : CLLocationCoordinate2D?
    var selectedVehicle : mowingVehicle = mowingVehicle(name: "Default Vehicle", speed: 4, angularSpeed: 0.5, width: 0.1)
    var zoom=false
    var pointArray = 0
    var mapDrawColor = UIColor.orange
    
    var currentStep=0
    var maxStep : Int?
    var drawer : mapReturn?
    var userField : fieldData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test area for testing the classes in the main program
        let a = line2d(a: point2D(x: 0.0, y: 0.0), b: point2D(x: 2.0, y: 2.0))
        let b = line2d(a: point2D(x: 1.0, y: 0.0), b: point2D(x: 0.0, y: 1.0))
        print(a.doesLineIntersect(line: b))
        if let isct = a.whereDoLinesIntersect(line: b){print(isct.tupleRepresentation())}else{print("nil")}
        
        let c = line2d(a: point2D(x: 0.0, y: 0.0), b: point2D(x: 2.0, y: 2.0))
        let d = line2d(a: point2D(x: 3.0, y: 3.0), b: point2D(x: 4.0, y: 4.0))
        print(c.doesLineIntersect(line: d))
        if let isct = c.whereDoLinesIntersect(line: d){print(isct.tupleRepresentation())}else{print("nil")}

        
        
        //End of test area
        
        //sets up the thinking wheel
        progressWheel.hidesWhenStopped=true
        progressWheel.stopAnimating()
        
        //set up gui
        setProgramState()
        
        //sets up the mapview
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        
        //select vehicle (Hard Coded for testing)
        selectedVehicle=mowingVehicle(name: "Default Vehicle", speed: 4, angularSpeed: 0.5, width: 1)
        
        // Do any additional setup after loading the view.
    }
    
    //Button calculate route is pressed begins the start of the process after user input
    @IBAction func calculateRoute(_ sender: Any) {
        if currentProgramState == .userInput{
            
            //user presses calculate route.
            //in this section the result is verified and processed and the result is displayed on screen.
            print("SEA -Begin Route Verification")
            
            currentProgramState = .loadingRoute
            setProgramState()
            statusText.text="Verifying Your Data... "
            
            //gets the data from the map
            let userFieldData=fieldData(mapData: pointsInput)
            userField=userFieldData
            
            //Checks to see if the data entered is valid
            if userFieldData.isValid(){
                if let speedVehicle=speedValue.text, let angular=angularValue.text , let width=widthValue.text, speedVehicle.isInt, angular.isInt, width.isInt {
                
                
                    //data is valid continuing to do route processing
                    print("SEA -Data Valid, beginning route generation")
                    statusText.text="Generating Your Route... "
                    
                    //A constant that relates the units of latitude to meters
                    let DEGREETOMETER=50000.0
                    
                    //begin object creation
                    let vehicle=mowingVehicle(name: "Custom Vehicle", speed: Double(speedVehicle)!/DEGREETOMETER, angularSpeed: Double(angular)!, width: Double(width)!/DEGREETOMETER)
                    let settings = generatorSettings(numAngle: 72, closestNum: 2)
                    let generator=generatePath(field: userFieldData, vehicle: vehicle, settings: settings)
                    print(pointsInput)
                    
                    let mapReturn=generator.calculateFinal()
                    
                    //Begin ouput all of the results
                    timeOutput.text="Time:"+String(Double(round(100*mapReturn.getTime(vehicle: selectedVehicle))/100))+" S"
                    distanceOutput.text="Distance:"+String(Double(round(100*mapReturn.getDistance())/100))+" M"
                    
                    //Drawing onto the map
                    print(String(Double(round(100*mapReturn.getTime(vehicle: selectedVehicle))/100)))
                    
                    print("SEA -Drawing Onto Map")
                    let overlays = mapView.overlays
                    mapView.removeOverlays(overlays)
                    
                    mapDrawColor = .orange
                    userFieldData.drawFieldData(map: self.mapView)
                    
                    mapDrawColor = .blue
                    mapReturn.displayMap(map: self.mapView, amount: 1)
                    self.drawer=mapReturn
                    self.maxStep=mapReturn.partList.toArray().count
                    
                    currentProgramState = .routeDisplay
                    setProgramState()
                    mapDrawColor = .orange
                }else{
                    //data not fully entered
                    print("SEA -Data not fully entered")
                    currentProgramState = .userInput
                    setProgramState()
                    statusText.text="Please enter full data"
                }
            }else{
                //data is not valid, warning the user.
                print("SEA -Data not valid")
                currentProgramState = .userInput
                setProgramState()
                statusText.text="Data Not Valid, please input again!!"
            }
        }
        else if currentProgramState == .routeDisplay{
            print("SEA -Resetting The application")
            currentProgramState = .userInput
            setProgramState()
            self.clear("")
        }
    }
    @IBAction func toggleZoom(_ sender: UIButton) {
        if currentProgramState == .userInput{
            if zoom==false{mapView.isUserInteractionEnabled = true
                zoom=true}
            else if zoom==true{mapView.isUserInteractionEnabled = false
                zoom=false}
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        if currentProgramState == .userInput{
            pointsDisplay=[[CLLocationCoordinate2D]()]
            pointArray=0
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
        }
        pointsDisplay=[[CLLocationCoordinate2D]()]
        pointsInput=[[(CLLocationCoordinate2D,CLLocationCoordinate2D)]()]
        prevCoord = nil
    }
    
    @IBAction func addInnerBorder(_ sender: Any) {
        if currentProgramState == .userInput{
            pointArray+=1
            pointsDisplay.append([CLLocationCoordinate2D]())
        }
        pointsInput.append([(CLLocationCoordinate2D,CLLocationCoordinate2D)]())
        prevCoord=nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentProgramState == .userInput{
            if let touch = touches.first{
                if zoom==false{
                    let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
                    

                    pointsDisplay[pointArray].append(coordinate)
                    let polyline = MKPolyline(coordinates: pointsDisplay[pointArray], count: pointsDisplay[pointArray].count)
                    mapView.addOverlay(polyline)
                    print("SEA -HERE EARLY")
                    
                    guard let prev = prevCoord else{prevCoord=coordinate ; return}
                    print("SEA -HERE")
                    pointsInput[pointArray].append((prev, coordinate))
                    prevCoord=coordinate
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //nothing happens here this is just required to be overriden
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //nothing happens here this is just required to be overriden
    }
    func setProgramState(){
        //this function configures the GUI to certen states.
        if currentProgramState == .userInput{
            mapDrawColor = .orange
            userField=nil
            drawer=nil
            calculateButton.setTitle("Calculate Route", for: .normal)
            timeOutput.text=""
            distanceOutput.text=""
            statusText.text="Enter Your Field and Click Calculate"
            progressWheel.stopAnimating()
        }
        if currentProgramState == .loadingRoute{
            progressWheel.startAnimating()
            statusText.text="Processing the data"
        }
        if currentProgramState == .routeDisplay{
            calculateButton.setTitle("Reset", for: .normal)
            progressWheel.stopAnimating()
            statusText.text="Finished Processing route is now visible"
        }
    }
    //implementation of map view delegate to render the overlays onto the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = mapDrawColor
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        return MKPolylineRenderer(overlay: overlay)
    }
    
    //The user presses the next step button
    @IBAction func nextStep(_ sender: Any) {
        if let max=maxStep{
            if currentStep<max{
                currentStep+=1
                updateOutputDisplay()
            }
        }
    }
    
    //the user presses the prev step button
    @IBAction func prevStep(_ sender: Any) {
        if let _=maxStep{
            if currentStep>0{
                currentStep-=1
                updateOutputDisplay()
            }
        }
    }
    
    @IBAction func startStep(_ sender: Any) {
        currentStep=1
        updateOutputDisplay()
    }
    
    @IBAction func endStep(_ sender: Any) {
        if let max=maxStep{
            currentStep=max
            updateOutputDisplay()
        }
    }
    
    func updateOutputDisplay(){
        if currentProgramState == .routeDisplay{
            print("SEA -Drawing Onto Map")
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            
            mapDrawColor = .orange
            userField!.drawFieldData(map: self.mapView)
            
            mapDrawColor = .blue
            drawer!.displayMap(map: self.mapView, amount:currentStep-1)
            
            mapDrawColor = .green
            drawer!.renderLast(map: self.mapView,amount:currentStep)
        }

    }
    
    //This enum defines what is happening currently in the program. It is used by the view controller to remake the view.
    private enum programState{
        case userInput
        case loadingRoute
        case routeDisplay
    }
}

//Extention function to test if the input string are numbers
extension String {
    var isInt: Bool {
        return Double(self) != nil
    }
}
