//
//  CoreDataManager.swift
//  BoxScore
//
//  Created by Kent Brady on 7/17/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CoreData

class FetchResult: NSObject, NSFetchRequestResult {
	
}
class LeagueDao: NSFetchedResultsController<NSFetchRequestResult> {
	
}

class CoreDataManager: NSObject, NSFetchedResultsControllerDelegate {
	static var instance = CoreDataManager()
	
	private override init() {
		
	}
	
	var fetchedResultsController: NSFetchedResultsController<PlayerCD>!
	 
	func initializeFetchedResultsController() {
		let request = NSFetchRequest<PlayerCD>(entityName: "Player")
		let lastNameSort = NSSortDescriptor(key: "lastName", ascending: true)
		request.sortDescriptors = [lastNameSort]
		
		
		let moc = AppDelegate.instance.persistentContainer.viewContext
		fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("Failed to initialize FetchedResultsController: \(error)")
		}
	}
}
