# README #

# Change Log #
22:00 November 05, 2016:

Added hack due to JSON response always giving back id = 5 for added devices and we need id to be unique to keep track of updates and deletions. Ideally we would have a callback that takes the JSON response and uses it to add the device to Core Data. In other words if online upload to webservice and then store the response to Core Data. Else if offline store in Core Data and then once online update with id from JSON response.


21:00 November 04, 2016:

Refactored control from screens to MainController.
Implemented reachability check, and if the web service is not reachable, took note of offline changes to be synced once connected.
For devices updated and deleted offline, since we have the id, I am using an array stored in user defaults to keep track of them. However, for added devices we don't have the id from JSON, and so I am using a boolean to mark whether they have been synchronized to web service or not.


18:35 Thursday, November 03, 2016:

1. Initial load from JSON to Core Data
2. Added SwiftyJSON
3. Custom DeviceCell

Missing:

1. Sync between JSON and Core Data
2. JSON to Add/Update/Delete device(s)

12:35 Thursday, November 03, 2016:
The UI is complete. Swipe to delete is not working, despite implementing the two necessary methods, I must be missing some setting that changed with Swift 3.0. Row deletion, at least for now, is implemented in a less-elegant manner.

The Core Data stack is complete. Add, update and delete through the UI work. The initial load from JSON response is not done yet, as the HTTP/JSON stack is not done yet. On track to complete by 12:00 Tuesday, November 08, 2016.

# Architecture #
The app has three screens, and hence three classes corresponding to each view. The app also has two classes that provide services (Web and Persistence) to those classes. The app is designed to follow the MVC pattern, but not Apple's MVC. Here, the ViewController is the View, the Model is Core Data's ManagedObjects, which is in this app's case a single Device entity/class, and the controller is split between the WebService and PersistenceService. If this app was larger, or if I had more time, there would be a separate Controller class or a ServicesManager to act as the Controller.

Since there is a need for only one instance of the controller, the WebService and PersistenceService are Singletons. Again if I had a controller class, it would be something like: Controller.shared.web and Controller.shared.persistence, but for now it is: PersistenceService.shared and WebService.shared.

# Multithreading #
Short answer: No

Long answer: For a simple app, I don't shy away from doing everything on the main thread. Apple designs some of the fastest mobile processors, and most iOS devices still only support two hardware threads. Until I measure and identify where the bottlenecks are -thank you Instruments for making it so easy-, I am not going to blindly optimize. My Master's research was on high performance programming for many-core (>50 cores) processors, and it taught me what Donald Knuth succinctly summarized: "Premature optimization is the root of all evil".

# Pods #
Alamofire

SyncDB/DataStack

SyncDB/DataSource

SwiftyJSON