//
//  ViewController.swift
//  UIKitSpotlightExample
//
//  Created by tigi KIM on 2021/07/08.
//

import UIKit
import CoreSpotlight
import CoreServices

let aType = "com.tigi44.devices-selection2"

struct Device: Identifiable {
    let id: Int
    let name: String
    let price: Float
    let image: String
}

let devices = [
    Device(id: 0, name: "Macpro", price: 1000.0, image: "macpro.gen1"),
    Device(id: 1, name: "Ipod", price: 100.45, image: "ipod"),
    Device(id: 2, name: "AppleWatch", price: 500.9, image: "applewatch")
]


// MARK: - ViewController


class ViewController: UIViewController {

    let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Apple Device"
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "AllDelete", style: .plain, target: self, action: #selector(self.allDelete))
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.estimatedRowHeight = UITableView.automaticDimension
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    public func pushDetail(_ index: Int) {
        let device = devices[index]
        self.navigationController?.pushViewController(DetailViewController(device), animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: NSStringFromClass(UITableViewCell.self))
        let device = devices[indexPath.row]
        
        cell.selectionStyle = .none
        cell.imageView?.image = UIImage(systemName: device.image)
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = String(format: "%0.2f", device.price)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pushDetail(indexPath.row)
    }
}

extension ViewController {
    @objc func allDelete() {
        NSUserActivity.deleteAllSavedUserActivities {
            print("done!")
        }
    }
}



// MARK: - DetailViewController


class DetailViewController: UIViewController {
    let device: Device
    let imageView: UIImageView = UIImageView()
    let titleLabel: UILabel = UILabel()
    let priceLabel: UILabel = UILabel()
    let deindexButton: UIButton = UIButton()
    
    init(_ device: Device) {
        self.device = device
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: device.image)
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = device.name
        self.view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        ])
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = String(format: "%0.2f", device.price)
        self.view.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
        
        deindexButton.translatesAutoresizingMaskIntoConstraints = false
        deindexButton.setTitle("deindex", for: .normal)
        deindexButton.setTitleColor(.red, for: .normal)
        deindexButton.setTitleColor(UIColor.red.withAlphaComponent(0.2), for: .highlighted)
        deindexButton.backgroundColor = .lightGray
        deindexButton.layer.cornerRadius = 5
        deindexButton.addTarget(self, action: #selector(deindexItem), for: .touchUpInside)
        self.view.addSubview(deindexButton)
        NSLayoutConstraint.activate([
            deindexButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            deindexButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.indexItem()
    }
}

extension DetailViewController {
    private func indexItem() {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = device.name
        attributeSet.contentDescription = "Get a Greate Device!"
        attributeSet.thumbnailData = UIImage(systemName: device.image)?.pngData()

        let item = CSSearchableItem(uniqueIdentifier: "\(device.id)", domainIdentifier: aType, attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    @objc private func deindexItem() {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(device.id)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
}
