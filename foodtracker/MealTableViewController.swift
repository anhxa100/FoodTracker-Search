//
//  MealTableViewController.swift
//  foodtracker
//
//  Created by anhxa100 on 9/4/18.
//  Copyright © 2018 anhxa100. All rights reserved.
//

import UIKit
import os.log



class MealTableViewController: UITableViewController, UISearchResultsUpdating {
    var searchController = UISearchController(searchResultsController: nil)
    
    //MARK: Properties
    var meals = [Meal]()
    var filterMeals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        if let saveMeals = loadMeals() {
            meals += saveMeals
            printMeals() //Debug
        }else{
            loadSimpleMeals()
        }
        
      //  filterMeals = meals
        //MARK: Search
        
        filterMeals = meals
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func loadSimpleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal(name: "Caprese Slalad", photo: photo1, rating: 4) else {
            fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = Meal(name: "Chicken and Potatoe", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        guard let meal3 = Meal(name: "Pasta with Meatballs" , photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal3")
        }
        
        meals = [meal1, meal2, meal3]
        printMeals()
    }
    
    func printMeals() {
        var i = 0
        for meal in meals {
            print("meal.name: [\(i)] '\(meal.name)'") // Debug
            i += 1
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        // #warning Incomplete implementation, return the number of rows
        
        return filterMeals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let meal = filterMeals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        

        // Configure the cell...

        return cell
    }
    
    //Unwind
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ViewController, let meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                if let index = meals.index(of: filterMeals[selectedIndexPath.row]){
                    meals[index] = meal
                    filterMeals[selectedIndexPath.row] = meal
                }
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            }
            else {
                
                let newIndexPath = IndexPath(row: filterMeals.count, section: 0)
                meals.append(meal)
                filterMeals = meals
                tableView.reloadData()
//                tableView.reloadRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the meals.
            saveMeals()
        }
        
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? ViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination) ")
            }
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected segue: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = filterMeals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
        //MARK: Save the meals
        saveMeals()
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
//            if let indexOfMeals  = meals.index(of: filterMeals[indexPath.row]){
                if let indexOfMeals  = meals.index(of: filterMeals[indexPath.row]){
                    meals.remove(at: indexOfMeals)
                    filterMeals.remove(at: indexPath.row)
            }
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    //MARK: Private methods
    private func saveMeals(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successful saved.", log: OSLog.default, type: .debug)
        }else{
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    
    private func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    
    
    //MARK: Search func
        func updateSearchResults(for searchController: UISearchController) {
            if let searchText = searchController.searchBar.text, !searchText.isEmpty {
                filterMeals = meals.filter{ item in
                    return item.name.lowercased().contains(searchText.lowercased())
                }
            }
            else{
                filterMeals = meals
            }
            
            tableView.reloadData()
        }
    
   
    
    
}
