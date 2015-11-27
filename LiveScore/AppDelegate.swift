import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var timerStart: NSDate?
    var half: Int = 1
    var match: Match?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = self.managedObjectContext
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            return true
        }
        return false
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("LiveScore", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("LiveScoreData.sqlite")
        
        print("url: \(url)")
        
        var error: NSError? = nil
        
        let fm = NSFileManager.defaultManager()
        
        if ( fm.fileExistsAtPath(url.path!) ) {
            
            if let dir = url.URLByDeletingLastPathComponent as NSURL! {
                
                let contents = (try! fm.contentsOfDirectoryAtPath(dir.path!))
                
                for next in contents {
                    if next.hasPrefix("LiveScoreData") {
                        let nexturl = dir.URLByAppendingPathComponent(next)
                        
                        do {
                            try fm.removeItemAtURL(nexturl)
                        } catch {
                            print("Error deleting file: \(error)")
                        }
                    }
                }
            }
        }
        
        if let preloadURL = NSBundle.mainBundle().URLForResource("LiveScoreData", withExtension: "sqlite") {
            
            do {
                try fm.copyItemAtURL(preloadURL, toURL: url)
            } catch {
                print("Unable to copy \(preloadURL) to \(url)")
            }
        }
        
        do {
            try coordinator!.addPersistentStoreWithType(
                NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func screenShot() -> UIImage? {
        var image: UIImage? = nil
        
        // create graphics context with screen size
        let screenRect = UIScreen.mainScreen().bounds
        UIGraphicsBeginImageContext(screenRect.size)
        
        if let ctx = UIGraphicsGetCurrentContext() {
            UIColor.blackColor().set()
            CGContextFillRect(ctx, screenRect)
            
            
            // grab reference to our window
            if let window = UIApplication.sharedApplication().keyWindow {
                // transfer content into our context
                window.layer.renderInContext(ctx)
                image = UIGraphicsGetImageFromCurrentImageContext()
            }
        }
        
        UIGraphicsEndImageContext()
        
        return image
    }    
}