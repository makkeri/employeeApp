//
//  EmployeeTableCell.swift
//  EmployeeApp
//
//  Created by Marko Peitsila on 22/01/2017.
//  Copyright © 2017 makkeri. All rights reserved.
//

import UIKit

/* Custom class for cells in tableView.
 */
class EmployeeTableCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
