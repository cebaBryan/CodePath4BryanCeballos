import UIKit
import Photos
import MapKit

protocol TaskDetailViewControllerDelegate: AnyObject {
    func taskDetailViewController(_ controller: TaskDetailViewController, didUpdateTask task: Task)
}

class TaskDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: TaskDetailViewControllerDelegate?
    var task: Task?
    var completionHandler: ((Bool) -> Void)?
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskQuestionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var completionImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        guard let taskToShow = task else {
            print("No task to display.")
            return
        }
        
        taskTitleLabel.text = taskToShow.title
        taskDescriptionLabel.text = taskToShow.description
        taskQuestionLabel.text = taskToShow.userQuestion
        completionImageView.image = taskToShow.isCompleted ? UIImage(named: "checkmark") : UIImage(named: "circle")
    }
    
    
    
    @IBAction func attachPictureTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.checkCameraAccessAndPresentPicker(picker)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func checkCameraAccessAndPresentPicker(_ picker: UIImagePickerController) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            picker.sourceType = .camera
            present(picker, animated: true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        picker.sourceType = .camera
                        self.present(picker, animated: true)
                    }
                } else {
                    print("Camera access denied")
                }
            }
        case .denied, .restricted:
            print("Camera access denied or restricted")
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        @unknown default:
            break
        }
    }

    
    @IBAction func backToMainTapped(_ sender: UIButton) {
        updateTaskAsCompleted()
        dismiss(animated: true, completion: nil)
    }
    
    func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                    picker.sourceType = .camera
                    self.present(picker, animated: true)
                })
            }
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true)
                })
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentPhotoPicker()
                    } else {
                        print("Camera access denied.")
                        
                    }
                }
            }
            
        case .denied, .restricted:
            print("Camera access denied or restricted.")
            
        @unknown default:
            print("Unknown authorization status.")
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image selected")
            return
        }
        completionImageView.image = UIImage(named: "checkmark")
        updateTaskAsCompleted()
        if let assetURL = info[.phAsset] as? PHAsset {
            let location = assetURL.location
            if let location = location {
                self.displayLocationOnMap(location)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func updateTaskAsCompleted() {
        guard var task = task else { return }
        task.isCompleted = true
        delegate?.taskDetailViewController(self, didUpdateTask: task)
    }
    
    func displayLocationOnMap(_ location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }

}
