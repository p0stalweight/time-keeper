//
//  TaskTableViewCell.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 6/13/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var elapsedHoursLabel: UILabel!
    @IBOutlet weak var hourProgressBar: UIProgressView!
    
    // MARK: Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
