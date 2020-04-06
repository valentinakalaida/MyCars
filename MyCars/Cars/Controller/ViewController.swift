//
//  ViewController.swift
//  MyCars
//
//  Created by Валентина Калайда on 10.02.2020.
//  Copyright © 2020 Валентина Калайда. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController {
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCar: Car!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageLabel: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var fanChoiseImageLabel: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFile()
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: 0)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest).first
            selectedCar = results
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func insertDataFrom(selectedCar: Car) {
        
        carImageLabel.image = UIImage(data: selectedCar.imageData!)
        markLabel.text = selectedCar.mark
        modelLabel.text = selectedCar.model
        fanChoiseImageLabel.isHidden = !(selectedCar.fanChoice)
        ratingLabel.text = "Rating: \(selectedCar.rating) / 10.0"
        numberOfTripsLabel.text = "Number of trips: \(selectedCar.timesDriven)"
        
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        lastTimeStartedLabel.text = "Last time started: \(df.string(from: selectedCar.lastStarted! as Date))"
        
        segmentedControl.tintColor = selectedCar.tintColor as? UIColor
        
        
    }

    
    func getDataFromFile() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0
        
        do {  
            let count = try context.count(for: fetchRequest)
            records = count
            print("Data is there already?")
        } catch {
            print(error.localizedDescription)
        }
        
        guard records == 0 else {return}
        
        let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: pathToFile!)!
        
        for dictionary in dataArray {
            
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
            let car = NSManagedObject(entity: entity!, insertInto: context) as! Car
            
            let carDictionary = dictionary as! NSDictionary
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = (carDictionary["rating"] as? Double)!
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = (carDictionary["timesDriven"] as? Int16)!
            car.fanChoice = ((carDictionary["fanChoice"] as? Bool?) != nil)
            
            let imageName = carDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            let imageData = image?.pngData()
            car.imageData = imageData as Data?
            
            let colorDictionary = carDictionary["tintColor"] as? NSDictionary
            car.tintColor = getColor(colorDictionary: colorDictionary!)
        }
    }
    
    func getColor(colorDictionary: NSDictionary) -> UIColor {
        let red = colorDictionary["red"] as! NSNumber
        let green = colorDictionary["green"] as! NSNumber
        let blue = colorDictionary["blue"] as! NSNumber
        return UIColor(red: CGFloat(red.floatValue) / 255, green: CGFloat(green.floatValue) / 255, blue: CGFloat(blue.floatValue) / 255, alpha: 1)
    }
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        
        let mark = sender.titleForSegment(at: sender.selectedSegmentIndex)
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest).first
            selectedCar = results
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    @IBAction func startEnginePressed(_ sender: UIButton) {
        
        let timesDriven = selectedCar.timesDriven
        selectedCar.timesDriven = Int16(truncating: NSNumber(value: timesDriven + 1))
        selectedCar.lastStarted = Date()
        
        do {
            try context.save()
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Rate it", message: "Rate this car please", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) {
            action in
            
            let textField = alertController.textFields?[0]
            self.update(rating: textField!.text!)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        alertController.addTextField {
            textField in
            textField.keyboardType = .numberPad
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    func update(rating: String) {
        
        selectedCar.rating = Double(truncating: NSNumber(value: Double(rating)!))
        
            do {
                try context.save()
                insertDataFrom(selectedCar: selectedCar)
            } catch {
                
                let ac = UIAlertController(title: "Wrong value", message: "Wrong input", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                ac.addAction(ok)
                present(ac,animated: true, completion: nil)
                print(error.localizedDescription)
            }
        }
    }


