//
//  AddCityViewController.swift
//  WeatherAppJP
//
//  Created by Johana Šlechtová on 11/06/2020.
//  Copyright © 2020 Jan Podmolík. All rights reserved.
//

import UIKit


protocol AddCityViewControllerDelegate: class {
    func didUpdateWeatherFromSearch(_ model: WeatherModel)
}

class AddCityViewController: UIViewController {
    
    //MARK: - Properties
    
    private let weatherManager = WeatherManager()
    
    weak var delegate: AddCityViewControllerDelegate?
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let enterCityLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter city"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    let searchTextField: UITextField = {
        let textfield = UITextField()
        textfield.keyboardAppearance = .dark
        textfield.textAlignment = .center
        textfield.textColor = .black
        textfield.backgroundColor = .white
        textfield.layer.cornerRadius = 5
        textfield.autocorrectionType = .no
        textfield.setDimensions(height: 40, width: 200)
        return textfield
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setDimensions(height: 40, width: 200)
        button.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    //MARK: - Actions
    
    @objc func handleSearch() {
        statusLabel.isHidden = true
        guard let query = searchTextField.text, !query.isEmpty else {
            showSearchError(text: "City cannot be empty. Please try again!")
            return }
        searchForCity(query: query)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func searchForCity(query: String) {
        view.endEditing(true)
        activityIndicator.startAnimating()
        weatherManager.fetchWeather(city: query) { [weak self] result in
            guard let this = self else { return }
            this.activityIndicator.stopAnimating()
            switch result {
                case .success(let model):
                    this.handleSearchSuccess(model: model)
                case .failure(let error):
                    this.showSearchError(text: error.localizedDescription)
            }
        }
    }
    
    private func handleSearchSuccess(model: WeatherModel) {
        statusLabel.isHidden = false
        statusLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        statusLabel.text = "Success!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let this = self else { return}
            this.delegate?.didUpdateWeatherFromSearch(model)
        }
    }
    
    private func showSearchError(text: String) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemRed
        statusLabel.text = text
    }
    
    func configureUI() {
        
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
        
        statusLabel.isHidden = true
        
        view.addSubview(backgroundView)
        backgroundView.centerX(inView: view)
        backgroundView.centerY(inView: view, constant: -100)
        
        let stack = UIStackView(arrangedSubviews: [enterCityLabel, searchTextField,
                                                   searchButton, activityIndicator, statusLabel])
        stack.axis = .vertical
        stack.spacing = 15
        
        backgroundView.addSubview(stack)
        
        stack.centerX(inView: backgroundView)
        stack.centerY(inView: backgroundView)
        
        // stack.layoutIfNeeded()
        backgroundView.setDimensions(height: 250, width: 250)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
}

//MARK: - UIGestureRecognizerDelegate

extension AddCityViewController: UIGestureRecognizerDelegate {
    // Take care of dismissing view only after touching background
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view == self.view
    }
}
