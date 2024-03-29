//
//  AllClients.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 28/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

class AllClients: UITableViewController {
  var hud:MBProgressHUD?
  var allClients = [[String: AnyObject]]()
  let viewAllURL = "prospect/view/"
  let prospectName = "Name"

  // MARK: View Functions
  
  override func viewDidLoad() {
    // stylizeControls()
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.backgroundColor = Theme.Clients.RefreshControlBackground
    self.refreshControl?.tintColor = Theme.Clients.RefreshControl
    self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    fetchData()
  }
  // MARK: action functions
  @IBAction func logout(sender: UIBarButtonItem) {
    GIDSignIn.sharedInstance().signOut()
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: tableView Functions
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    let item =  self.tabBarController?.tabBar.items as! [UITabBarItem]
//    item[1].badgeValue = "\(allClients.count)"
    return allClients.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCellWithIdentifier("client-id") {
      let client = allClients[indexPath.row] as [String: AnyObject]
      populateCellData(cell, withProspectDictionary: client)
      // stylizeCell(cell, index: indexPath.row)
      return cell
    } else {
      return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "client-id")
    }
  }
  
  func refresh(sender:AnyObject) {
    fetchData()
  }

  
  // MARK: Internal Functions
  private func stylizeCell(cell: UITableViewCell, index: Int) {
    if index % 2 != 0 {
      cell.backgroundColor = Theme.Clients.cellBGOddCell
      tableView.backgroundColor = Theme.Clients.cellBGEvenCell
    } else {
      cell.backgroundColor = Theme.Clients.cellBGEvenCell
      tableView.backgroundColor = Theme.Clients.cellBGOddCell
    }
    cell.textLabel?.backgroundColor = UIColor.clearColor()
    cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
  }

  private func stylizeControls() {
    navigationController?.navigationBar.backgroundColor = Theme.Clients.navBarBG
    tableView.separatorColor = Theme.Clients.tableViewSeparator
    tableView.backgroundColor = Theme.Clients.cellBGOddCell
  }

  private func populateCellData(cell: UITableViewCell,
    withProspectDictionary client: [String: AnyObject]) {
      if let name = client[prospectName] as? String {
        cell.textLabel?.text = name
        if let buHead = client["BUHead"] as? String {
          if let size = client["TeamSize"] as? Int {
            cell.detailTextLabel!.text = "Team Size: \(size) BU Head: \(buHead)"
            cell.detailTextLabel!.textColor = Theme.Prospects.detailText
          } else {
            cell.detailTextLabel!.text = ""
          }
        }
      }
  }
  
  private func commonHandler() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    dispatch_async(dispatch_get_main_queue()) {
      self.hud?.hide(true)
      self.refreshControl?.endRefreshing()
    }

  }
  func fetch_success() -> Void {
    commonHandler()
    allClients = []
    for dict in AllProspects.fillData()  {
      if let teamSize = dict["TeamSize"] as? Int {
        if teamSize > 0 {
          allClients.append(dict)
        }
    }
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }
  
  func network_error( error: NSError) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Network error",
        message: "Code: \(error.code)\n\(error.localizedDescription)")
    }
  }
  
  func service_error(response: NSHTTPURLResponse) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Webservice Error",
        message: "Error received from webservice: \(response.statusCode)")
    }
  }
  
  private func showMessage(title:String, message: String) {
    let alert = UIAlertController(title: title, message: message,
      preferredStyle: .Alert)
    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }


  private func fetchData() {
    dispatch_async(dispatch_get_main_queue()) {
      self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.hud?.labelText = "Loading.."
    }
    fetch_success()
  }

  // MARK: Segue Functions
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let targetController = segue.destinationViewController as! UINavigationController
    let targetView = targetController.topViewController as! Client
    if segue.identifier == "viewClient" {
      if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
        targetView.itemToView = allClients[indexPath.row]
      }
    }
  }
  
}
