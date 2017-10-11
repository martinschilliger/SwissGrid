//
//  SettingsView.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 20.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet var settingsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Makes the title large (iOS11) => https://stackoverflow.com/a/44410330/1145706
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            //            self.navigationItem.largeTitleDisplayMode = .always
        }
    }

    // Close the settings modal
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBAction func closeButtonTriggered(_: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Settings content
    var savedMapProvider: String = UserDefaults.standard.object(forKey: "savedMapProvider") as? String ?? "Apple"

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return AvailableMap.count
        case 1:
            return BooleanSetting.count
        default:
            return 4
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Map providers"
        case 1:
            return "Behavior"
        default:
            return "Section \(section)"
        }
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    var lastCheckedIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as UITableViewCell

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = AvailableMap.maps[indexPath.row]
            if cell.textLabel?.text == savedMapProvider {
                cell.accessoryType = .checkmark
                lastCheckedIndexPath = indexPath
            } else {
                cell.accessoryType = .none
            }

            let cellUrl = AvailableMap.getCase(map: AvailableMap.maps[indexPath.row]).urlBase(test: true)
            if !UIApplication.shared.canOpenURL(URL(string: cellUrl)!) {
                cell.textLabel?.isEnabled = false
            }

            // TODO: How to hide greyed out maps??
            break
        case 1:
            // add a Switch to the cell
            let cellSwitch = UISwitch(frame: CGRect.zero) as UISwitch
            cellSwitch.isOn = UserDefaults.standard.object(forKey: BooleanSetting.id(indexPath.row).getName()) as? Bool ?? BooleanSetting.id(indexPath.row).getDefaults()
            cellSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
            cellSwitch.tag = indexPath.row
            cell.accessoryView = cellSwitch
            cell.tag = 5000 // from now on this means this is a UITableViewCell with a UISwitch in it
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            cell.textLabel?.text = BooleanSetting.id(indexPath.row).getDescription()
            break
        default:
            cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        }

        return cell
    }

    @objc func switchTriggered(sender: UISwitch) {
        let name = BooleanSetting.id(sender.tag).getName()
        UserDefaults.standard.set(sender.isOn, forKey: name)
        //        debugPrint("Button \(name) switched to: \(sender.isOn)")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect the cell, because trigger is now received by this function
        tableView.deselectRow(at: indexPath, animated: true)

        // Prevent selection of maps not available
        if tableView.cellForRow(at: indexPath)?.textLabel?.isEnabled == false {
            return
        }

        // find the new cell
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.tag == 5000 { // this is a UITableViewCell with a UISwitch in it
            return
        }

        // check if it was already checked
        if indexPath.row != lastCheckedIndexPath?.row {
            // ok, a new cell is checked. remove checkmark at the old cell
            if let lastCheckedIndexPath = lastCheckedIndexPath {
                let oldCell = tableView.cellForRow(at: lastCheckedIndexPath)
                oldCell?.accessoryType = .none
            }

            // place checkmark on the new cell
            newCell?.accessoryType = .checkmark

            // save the indexPath of the new cell for later comparing
            lastCheckedIndexPath = indexPath

            // save the new selected map provider to user settings
            savedMapProvider = (newCell?.textLabel?.text)!

            // change the map provider to user settings
            UserDefaults.standard.set(savedMapProvider, forKey: "savedMapProvider")
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        // TODO: Make the mail link clickable!
        return SectionFooter.getText(section: section)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
