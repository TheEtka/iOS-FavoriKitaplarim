//
//  DetailsViewController.swift
//  FavoriKitaplarim
//
//  Created by Abdullah Etka Karadeniz  on 29.07.2021.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var kaydetButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var kitapTextField: UITextField!
    @IBOutlet weak var yazarTextField: UITextField!
    @IBOutlet weak var yilTextField: UITextField!
    
    var secilenKitapAdi = ""
    var secilenKitapUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Kitapları Filtrele
        if secilenKitapAdi != "" {
            
            // Kaydet Button gösterme
            kaydetButton.isHidden = true
            
            // CoreData seçilen kitap bilgileri
            if let uuidString = secilenKitapUUID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Kitaplar")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                        
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let kitap = sonuc.value(forKey: "kitap") as? String {
                                kitapTextField.text = kitap
                            }
                            
                            if let yazar = sonuc.value(forKey: "yazar") as? String {
                                yazarTextField.text = yazar
                            }
                            
                            if let yil = sonuc.value(forKey: "yil") as? Int {
                                yilTextField.text = String(yil)
                            }
                            
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                            
                        }
                        
                    }
                    
                } catch {
                    print("Hata!")
                }
                
            }
            
        } else {
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = false // Kaydet Button Gizle
            kitapTextField.text = ""
            yazarTextField.text = ""
            yilTextField.text = ""
        }
        
        // Klavyeyi Kapat
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        // Görsel Seç
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func gorselSec() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        kaydetButton.isEnabled = true // Kaydet Button Aktif
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func klavyeyiKapat() {
        view.endEditing(true)
    }

    @IBAction func kaydetButtonTiklandi(_ sender: Any) {
        
        // AppDelegate Dosyasına Ulaş
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Entity Dosyasına Ulaş
        let kitaplar = NSEntityDescription.insertNewObject(forEntityName: "Kitaplar", into: context)
        
        // Entity İçindeki Attribute
        kitaplar.setValue(kitapTextField.text!, forKey: "kitap")
        kitaplar.setValue(yazarTextField.text!, forKey: "yazar")
        
        if let yil = Int(yilTextField.text!) {
            kitaplar.setValue(yil, forKey: "yil")
        }
        
        // Universal Unique ID
        kitaplar.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        kitaplar.setValue(data, forKey: "gorsel")
        
        // Hata Çıkarsa...
        do {
            try context.save()
            print("Kayıt Tamamlandı")
        } catch {
            print("Hata!")
        }
        
        // Bildirim
        NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
