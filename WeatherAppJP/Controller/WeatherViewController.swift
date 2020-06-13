//
//  WeatherViewController.swift
//  WeatherAppJP
//
//  Created by Johana Šlechtová on 11/06/2020.
//  Copyright © 2020 Jan Podmolík. All rights reserved.
//

import UIKit
import SkeletonView
import CoreLocation
import Loaf

class WeatherViewController: UIViewController {
    
    //MARK: - Properties
    
    private let weatherManager = WeatherManager()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private let conditionImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "imClear")
        iv.setDimensions(height: 200, width: 200)
        return iv
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "24°C"
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.setDimensions(height: 40, width: 200)
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Sun"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setDimensions(height: 100, width: 200)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchWeather(byCity: "Nový Hrozenkov1")
    }
    
    //MARK: - Actions
    
    @objc func handleCurrentLocation() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestLocation()
            default:
                promptForLocationPermission()
        }
    }
    
    
    @objc func handlePresentCitySearch() {
        let controller = AddCityViewController()
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func promptForLocationPermission() {
        let alertController = UIAlertController(title: "Requires Location Permission", message: "Would you like to enable location permission in Settings?", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func fetchWeather(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func fetchWeather(byCity city: String) {
        showAnimation()
        weatherManager.fetchWeather(city: city) { [weak self] result in
            guard let this = self else { return }
            this.handleResult(result)
            
        }
    }
    
    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
            case .success(let weatherModel):
                updateUI(with: weatherModel)
            case .failure(let error):
                handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        hideAnimation()
        conditionImageView.image = #imageLiteral(resourceName: "imSad")
        temperatureLabel.text = "Oops!"
        conditionLabel.text = "Something went wrong. Please try again later.."
        navigationItem.title = ""
        Loaf(error.localizedDescription, state: .error, location: .bottom, sender: self).show()
    }
    
    private func hideAnimation() {
        conditionImageView.hideSkeleton()
        temperatureLabel.hideSkeleton()
        conditionLabel.hideSkeleton()
    }
    
    private func showAnimation() {
        conditionImageView.showAnimatedGradientSkeleton()
        temperatureLabel.showAnimatedGradientSkeleton()
        conditionLabel.showAnimatedGradientSkeleton()
    }
    
    func updateUI(with model: WeatherModel) {
        hideAnimation()
        navigationItem.title = model.cityName
        temperatureLabel.text = model.temp.toString().appending("°C")
        conditionLabel.text = model.conditionDescription
        conditionImageView.image = UIImage(named: model.conditionImage)
    }
    
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
        stack.spacing = 8
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        
        conditionImageView.isSkeletonable = true
        temperatureLabel.isSkeletonable = true
        conditionLabel.isSkeletonable = true
    }
}

//MARK: - AddCityViewControllerDelegate

extension WeatherViewController: AddCityViewControllerDelegate {
    
    func didUpdateWeatherFromSearch(_ model: WeatherModel) {
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let this = self else { return }
            this.updateUI(with: model)
        })
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        if let locations = locations.last {
            manager.stopUpdatingLocation()
            fetchWeather(byLocation: locations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
}
