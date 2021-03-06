//
//  MapViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Razvan  Julian on 19/12/2017.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Parse

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var riderRequestActive = true
    
    var driverOnTheWay = false
    
    
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var requestButton: UIButton!
    
    @IBAction func requestAction(_ sender: Any) {
        
        if riderRequestActive {
            
            requestButton.setTitle("Call an Uber", for: [])
            
            //riderRequestActive = false
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("Username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                        
                            riderRequest.deleteInBackground()
                        
                        }
                    }
                })
            
            } else {
        
            if userLocation.latitude != 0 && userLocation.longitude != 0 {
                
                //riderRequestActive = true
                
                self.requestButton.setTitle("Cancel Uber", for: [])
                
                let riderRequest = PFObject(className: "RiderRequest")
                riderRequest["Username"] = PFUser.current()?.username
                riderRequest["Location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                
                riderRequest.saveInBackground(block: { (success, error) in
                    
                    if success {
                        
                        print("Called an Uber")
                        
                        
                    } else {
                        
                        
                        self.requestButton.setTitle("Call An Uber", for: [])
                        
                        self.riderRequestActive = false

                        
                        self.createAlert(title: "Could not call Uber", message: "Please try again")
                        
                        }
                    
                    
                    
                    })
                
                } else {
                
                createAlert(title: "Could not call Uber", message: "Cannot detect your location.")
            }
        }
        
        riderRequestActive = !riderRequestActive
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutSegue" {
            
            locationManager.stopUpdatingLocation()
            
            PFUser.logOut()
            
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        requestButton.isHidden = true
        
        let query = PFQuery(className: "RiderRequest")
        
        query.whereKey("Username", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if let objects = objects {
                
                if objects.count > 0 {
                    
                
                    self.riderRequestActive = true
                    
                    self.requestButton.setTitle("Cancel Uber", for: [])
                    
                    }
            
            }
            
            self.requestButton.isHidden = false
            
            
        })

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //print(manager.location?.coordinate)
        
        if let location = manager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            if driverOnTheWay == false {
                
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) )
                self.mapView.setRegion(region, animated: true)
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = userLocation
                annotation.title = "Your Location"
                self.mapView.addAnnotation(annotation)
            }
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("Username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                        
                        riderRequest["Location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        
                        riderRequest.saveInBackground()
                        
                    }
                }
            })
            
            
        }
        
        if riderRequestActive == true {
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("Username", equalTo: PFUser.current()?.username)
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    for riderRequest in riderRequests {
                        
                        if let driverUsername = riderRequest["driverResponded"]{
                            
                            let query = PFQuery(className: "DriverLocation")
                            
                            query.whereKey("Username", equalTo: driverUsername)
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                if let driverLocations = objects {
                                    
                                    for driverLocationObject in driverLocations{
                                        
                                        if let driverLocation = driverLocationObject["Location"] as? PFGeoPoint {
                                            
                                            self.driverOnTheWay = true
                                            
                                            let driverCLLocation =  CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            let riderCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            
                                            let distance = riderCLLocation.distance(from: driverCLLocation) / 1000
                                            
                                            let roundedDistance = round(distance * 100) / 100
                                            
                                            // print("Working!!!")
                                            
                                            self.requestButton.setTitle("Your driver is \(roundedDistance) km away", for: [])
                                            
                                            let latDelta = abs(driverLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            
                                            let lonDelta = abs(driverLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            
                                            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                            
                                            self.mapView.removeAnnotations(self.mapView.annotations)
                                            
                                            self.mapView.setRegion(region, animated: true)
                                            
                                            let userLocationAnnotation = MKPointAnnotation()
                                            
                                            userLocationAnnotation.coordinate = self.userLocation
                                            
                                            userLocationAnnotation.title = "Your location"
                                            
                                            self.mapView.addAnnotation(userLocationAnnotation)
                                            
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            driverLocationAnnotation.title = "Your driver"
                                            
                                            self.mapView.addAnnotation(driverLocationAnnotation)
                                            
                                            
                                            
                                        }
                                    }
                                    
                                }
                            })
                            
                            
                            
                        }
                    }
                }
            
            })
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
