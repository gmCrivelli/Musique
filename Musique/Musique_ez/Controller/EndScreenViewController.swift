//
//  EndScreenViewController.swift
//  
//
//  Created by Carlos Marcelo Tonisso Junior on 12/3/17.
//

import UIKit

class EndScreenViewController: BasicViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var score : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = score + "%"
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
