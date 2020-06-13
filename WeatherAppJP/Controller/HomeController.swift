//
//  WeatherViewController.swift
//  WeatherAppJP
//
//  Created by Johana Šlechtová on 11/06/2020.
//  Copyright © 2020 Jan Podmolík. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    
    //MARK: - Preferences
    
    private let conditionImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "imClear")
        iv.setDimensions(height: 200, width: 200)
        return iv
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "24°C"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Sun"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    
    @objc func handleCurrentLocation() {
        
    }
    
    @objc func handlePresentCitySearch() {
        
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        let locationImage = UIImage(systemName: "location")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: locationImage, style: .plain, target: self, action: #selector(handleCurrentLocation))
        
        let plusImage = UIImage(systemName: "plus")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(handlePresentCitySearch))
        
        navigationController?.navigationBar.tintColor = .black
        
        let stack = UIStackView(arrangedSubviews: [conditionImageView,
                                                   temperatureLabel,
                                                   conditionLabel])
        
        stack.axis = .vertical
        stack.spacing = 3
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        
    }
}
