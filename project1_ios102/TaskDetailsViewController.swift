//
//  TaskDetailsViewController 2.swift
//  project1_ios102
//
//  Created by Mariia Mohylska on 9/23/25.
//


import UIKit
import MapKit
import PhotosUI
import CoreLocation

class TaskDetailsViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var taskTitleLable: UILabel!
    @IBOutlet weak var completionIcon: UIImageView!
    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewPhotoButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)
        mapView.delegate = self
        mapView.layer.cornerRadius = 15
        
        updateUIView()
        updateMap()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            currentLocation = locations.last
        }
    
    private func updateUIView() {
        taskTitleLable.text = task.title
        taskDescriptionLabel.text = task.description
        
        completionIcon.image = UIImage(systemName: task.isComplete ? "checkmark.circle.fill" : "circlebadge")?.withRenderingMode(.alwaysTemplate)
        
        completionLabel.text = task.isComplete ? "Completed" : "Not completed yet"
        
        mapView.isHidden = !task.isComplete
        addPhotoButton.isHidden = task.isComplete
        viewPhotoButton.isHidden = !task.isComplete
        
    }
    
    private func updateMap() {
        guard let imageLocation = task.imageLocation else { return }
        
        let coordinate = imageLocation.coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region,animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func addPhotoTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Photo", message: "Choose preferred way to add a photo", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(UIAlertAction(
                title: "Take a photo", style: .default
            ){
                [weak self] _ in
                self?.presentCamera()
            })
        }
        
        alert.addAction(UIAlertAction(
            title: "Choose from library", style: .default
        ){
            [weak self] _ in
            if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                    switch status {
                    case .authorized:
                        DispatchQueue.main.async {
                            self?.presentImagePicker()
                        }
                    default:
                        DispatchQueue.main.async {
                            self?.presentGoToSettingAlert()
                        }
                    }
                }
            } else {
                self?.presentImagePicker()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
        
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    DispatchQueue.main.async {
                        self?.presentGoToSettingAlert()
                    }
                }
            }
        } else {
            presentImagePicker()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoDetailSegue" {
            if let photoViewController = segue.destination as? PhotoViewController {
                photoViewController.task = task
            }
        }
    }
    
    private func presentCamera() {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.allowsEditing = false
        camera.delegate = self
        present(camera, animated: true)
    }
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    private func presentGoToSettingAlert() {
        let alertController = UIAlertController(
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert
        )
        
        let settingAction = UIAlertAction(
            title: "Settings", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        
        alertController.addAction(settingAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

extension TaskDetailsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let result = results.first
        
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location
        else { return }
        
        guard let provider = result?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
                DispatchQueue.main.async { [weak self] in self?.showAlert(for: error)}
            }
            
            guard let image = object as? UIImage else {return}
            
            DispatchQueue.main.async { [weak self] in
                self?.task.set(image, with: location)
                self?.updateUIView()
                self?.updateMap()
            }
            
        }
    }
}

extension TaskDetailsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation)
                as? TaskAnnotationView
                else {
                    fatalError("Unable to dequeue TaskAnnotationView")
                }
        
        annotationView.configure(with: task.image)
        return annotationView
    }
}


extension TaskDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
            
            if let image = info[.originalImage] as? UIImage {
                // Use your own GPS location
                guard let location = currentLocation else { return }
                self.task.set(image, with: location)
                self.updateUIView()
                self.updateMap()
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
}
