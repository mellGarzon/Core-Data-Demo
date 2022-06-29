//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Mellani Garzon on 29/06/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemBackground
        return table
    }()
    
    lazy var barButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        return button
    }()
    
    @objc func addTapped(){
        let alert = UIAlertController(title: "Add person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let textfield = alert.textFields![0]
            
            let newPerson = Person(context: self.context)
            newPerson.name = textfield.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            //Save the data
            do {
                try self.context.save()
            }catch{
                print(error)
            }
            self.fetchPeople()
        }
        
        alert.addAction(submitButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Data for the table
    var items: [Person]?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Core Data Demo"
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        configureNavigation()
        addConstraints()
        fetchPeople()
    }
    
    func relationshipDemo(){
        // Create a family
        let family = Family(context: context)
        family.name = "ABC family"
        
        //Create a person
        let person = Person(context: context)
        person.name = "Maggie"
        
        //Set the relationship
        //person.family = family
        //or
        family.addToPeople(person)
        
        //Save context
        do {
            try self.context.save()
        }catch{
            print(error)
        }
    }
    
    func fetchPeople(){
        //Fetch the data from Core Data
        do{
            
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            //Set the filtering on the request
//            let pred = NSPredicate(format: "name CONTAINS %@", "Mellani")
//            request.predicate = pred
            
            //Set the sorting on the request
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            //you can limit the number of objects that return using fetchLimit...
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }catch{
            print(error)
        }
    }
    
    func configureNavigation(){
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func addConstraints(){
        let tableViewConstraints = [
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(tableViewConstraints)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items?.count ?? 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as? PersonTableViewCell else {
            return UITableViewCell()
        }
        
        if let person = items?[indexPath.row] {
            cell.configure(with: person)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            if let personToRemove = self.items?[indexPath.row]{
                //Remove the person
                self.context.delete(personToRemove)
                //Save the data
                do {
                    try self.context.save()
                }catch{
                    print(error)
                }
                self.fetchPeople()
            }
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let person = self.items?[indexPath.row] else {return}
        
        let alert = UIAlertController(title: "Edit Person", message: "Edit name", preferredStyle: .alert)
        alert.addTextField()
        
        let textfield = alert.textFields![0]
        textfield.text = person.name
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { [self] (action) in
            
            let textfield = alert.textFields![0]
            
            person.name = textfield.text
            
            //Save the data
            do {
                try self.context.save()
            }catch{
                print(error)
            }
            self.fetchPeople()
        }
        alert.addAction(saveButton)
        self.present(alert, animated: true, completion: nil)
    }
}
