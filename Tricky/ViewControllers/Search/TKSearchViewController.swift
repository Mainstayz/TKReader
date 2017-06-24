//
//  TKSearchViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKSearchViewController: TKViewController {


    
    enum RestorationKeys : String {
        case searchControllerIsActive
        case searchBarText
        case searchBarIsFirstResponder
    }
    
    struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }
    

    var searchController: UISearchController!
    var resultsTableController: TKSearchResultViewController!
    var restoredState = SearchControllerRestorableState()

    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        resultsTableController = TKSearchResultViewController(style: .plain)
 
        searchController = UISearchController(searchResultsController: resultsTableController)

        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar
        
    
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = resultsTableController
        
        definesPresentationContext = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
 

    
    // MARK: - UIStateRestoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        // Encode the view state so it can be restored later.
        
        // Encode the search controller's active state.
        coder.encode(searchController.isActive, forKey:RestorationKeys.searchControllerIsActive.rawValue)
        
        // Encode the first responser status.
        coder.encode(searchController.searchBar.isFirstResponder, forKey:RestorationKeys.searchBarIsFirstResponder.rawValue)
        
        // Encode the search bar text.
        coder.encode(searchController.searchBar.text, forKey:RestorationKeys.searchBarText.rawValue)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        
        // Restore the active state:
        // We can't make the searchController active here since it's not part of the view
        // hierarchy yet, instead we do it in viewWillAppear.
        //
        restoredState.wasActive = coder.decodeBool(forKey: RestorationKeys.searchControllerIsActive.rawValue)
        
        // Restore the first responder status:
        // Like above, we can't make the searchController first responder here since it's not part of the view
        // hierarchy yet, instead we do it in viewWillAppear.
        //
        restoredState.wasFirstResponder = coder.decodeBool(forKey: RestorationKeys.searchBarIsFirstResponder.rawValue)
        
        // Restore the text in the search field.
        searchController.searchBar.text = coder.decodeObject(forKey: RestorationKeys.searchBarText.rawValue) as? String
    }

  
}
