//
//  DashboardCVC.swift
//  PicBucket
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import UIKit



class DashboardCVC: UIViewController {
        
    private let SEGUE_IDENTIFIER_FOR_IMAGE_PREVIEW = "previewImage"
    
    private var images                      : [Image] = []
    private var imageSelectedForPreview     : Image!
    
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var collectionView       : UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupCollectionView()
        reloadCollectionView()
    }
    
    private func setupCollectionView() {
                
        let layout                              = UICollectionViewFlowLayout()
        layout.itemSize                         = CGSize(width: 120, height: 100)
        layout.sectionInset                     = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing               = 8
        layout.minimumInteritemSpacing          = 8
        collectionView.collectionViewLayout     = layout
            
        collectionView.dataSource               = self
        collectionView.delegate                 = self
    }
    
    private func showHideActivityIndicator() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    private func reloadCollectionView() {
        images = ImageListTable.getImageList()
        collectionView.reloadData()
    }
    
    private func pickImage(from type: UIImagePickerController.SourceType) {
        let pickerVC                = UIImagePickerController()
        pickerVC.allowsEditing      = true
        pickerVC.sourceType         = type
        pickerVC.delegate           = self
     
        present(pickerVC, animated: true)
    }
    
    private func deleteImage(at indexPath: IndexPath) {
        let confirmationAction = UIAlertController(title: "Are your sure you want to delete this photo?", message: nil, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.showHideActivityIndicator()
            let image = self.images[indexPath.row]
            AWSOperationManager.shared.deleteImage(named: image.name) { task  in
                if task == .sucess {
                    self.showHideActivityIndicator()
                    if ImageListTable.delete(image: image) {
                        self.images.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                    }
                } else {
                    self.showHideActivityIndicator()
                    let alert   = UIAlertController(title: "Failed To Delete!", message: "There seems to be some issue while performing your action", preferredStyle: .alert)
                    let okAction  = UIAlertAction(title: "Ok", style: .default) { _ in }
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }
            }
        }
        
        let noAction = UIAlertAction(title: "Ok", style: .default) { _ in }
        
        confirmationAction.addAction(yesAction)
        confirmationAction.addAction(noAction)
        
        present(confirmationAction, animated: true)
    }
    
    private func preViewImage(at indexPath: IndexPath) {
        imageSelectedForPreview = images[indexPath.row]
        performSegue(withIdentifier: SEGUE_IDENTIFIER_FOR_IMAGE_PREVIEW, sender: self)
    }

    @IBAction func addImageToBucket(_ sender: UIBarButtonItem) {
        let alertController             = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction                = UIAlertAction(title: "Camera", style: .default) { _ in self.pickImage(from: .camera) }
        let photoLibraryAction          = UIAlertAction(title: "Photo Library", style: .default) { _ in self.pickImage(from: .photoLibrary) }
        let cancelAction                = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
                   popoverController.sourceView = self.view
                   popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                   popoverController.permittedArrowDirections = []
               }
        
        present(alertController, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ImageViewController {
            destination.image = imageSelectedForPreview
        }
    }
}

extension DashboardCVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell {
            cell.loadCell(with: images[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension DashboardCVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alertController             = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let viewAction                  = UIAlertAction(title: "View Image", style: .default) { _ in self.preViewImage(at: indexPath) }
        let deleteAction                = UIAlertAction(title: "Delete Image", style: .destructive) { _ in self.deleteImage(at: indexPath) }
        let cancelAction                = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(viewAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alertController, animated: true)
    }

}

extension DashboardCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 100)
    }
}

extension DashboardCVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        showHideActivityIndicator()
        if let imageData = image.jpegData(compressionQuality: 1.0) {
        //Save image to bit bucket
            AWSOperationManager.shared.saveImage(data: imageData, progressBlock: {_,_ in }) {[weak self] result in
                if result == .sucess {
                    print("SUCESSSSS")
                    let items = ImageListTable.getImageList()
                    if items.count > 0 {
                        self?.images.append(items.last!)
                        let indexPath = IndexPath(item: items.count - 1, section: 0)
                        self?.collectionView.insertItems(at: [indexPath])
                    }
                    self?.showHideActivityIndicator()
                } else {
                    self?.showHideActivityIndicator()
                }
            }
        }
    }
}

extension DashboardCVC: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        session.loadObjects(ofClass: UIImage.self) { images in
            print(images.count)
            for image in images {
                if let image = image as? UIImage {
                    self.showHideActivityIndicator()
                    if let imageData = image.jpegData(compressionQuality: 1.0) {
                        //Save image to bit bucket
                        AWSOperationManager.shared.saveImage(data: imageData, progressBlock: {_,_ in }) {[weak self] result in
                            if result == .sucess {
                                print("SUCESSSSS")
                                let items = ImageListTable.getImageList()
                                if items.count > 0 {
                                    self?.images.append(items.last!)
                                    let indexPath = IndexPath(item: items.count - 1, section: 0)
                                    self?.collectionView.insertItems(at: [indexPath])
                                }
                                self?.showHideActivityIndicator()
                            } else {
                                self?.showHideActivityIndicator()
                            }
                        }
                    }
                }
            }
        }
    }
}

