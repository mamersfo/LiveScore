//
//  MasterViewController.swift
//  LiveScore
//
//  Created by Martin van Amersfoorth on 21/11/15.
//  Copyright © 2015 Martin van Amersfoorth. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    func loadData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let moc = self.managedObjectContext!
        
        Player.create(moc, name: "N.N.")
        Player.create(moc, name: "Amine")
        Player.create(moc, name: "Dieuwe")
        Player.create(moc, name: "Fadi")
        Player.create(moc, name: "Lenny")
        Player.create(moc, name: "Luc")
        Player.create(moc, name: "Quincy")
        Player.create(moc, name: "Stijn")
        Player.create(moc, name: "Vic")
        Player.create(moc, name: "Vito")
        
        let bld = Squad.create(moc, code: "BLD", club: "Blijdorp", team: "E3")
        let vic = Squad.create(moc, code: "VIC", club: "Victoria'04", team: "E2")
        let ket = Squad.create(moc, code: "KSP", club: "Kethel Spaland", team: "E2")
        let cwo = Squad.create(moc, code: "CWO", club: "CWO", team: "E1")
        let exc = Squad.create(moc, code: "EXC", club: "Excelsior'20", team: "E3")
        //        let her = Squad.create(moc, club: "Hermes DVS", team: "E1")
        //        let vfc = Squad.create(moc, club: "VFC", team: "E5")
        //        let glz = Squad.create(moc, club: "GLZ Delfshaven", team: "E1")
        //        let dbs = Squad.create(moc, club: "De Betrokken Spartaan", team: "E3")
        //        let svv = Squad.create(moc, club: "SVV", team: "E2")

        Match.create(moc, year: 2015, month: 11, day: 28, hour: 10, minute: 15, home: vic, away: bld)
        Match.create(moc, year: 2015, month: 12, day: 28, hour: 9, minute: 10, home: exc, away: bld)
        Match.create(moc, year: 2015, month: 12, day: 19, hour: 10, minute: 0, home: ket, away: bld)
        Match.create(moc, year: 2016, month: 1, day: 16, hour: 9, minute: 0, home: cwo, away: bld)
        Match.create(moc, year: 2016, month: 1, day: 23, hour: 10, minute: 45, home: bld, away: ket)
        
        appDelegate.saveContext()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // self.navigationItem.leftBarButtonItem = self.editButtonItem()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Match {
            cell.textLabel!.text = object.description
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Match {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if (appDelegate.timerStart != nil) {
                    let match = appDelegate.match!
                    if object != match {
                        return nil
                    }
                }
            }
        }
        
        return indexPath
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Match", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        fetchRequest.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             abort()
        }
        
        return _fetchedResultsController!
    }    
    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

