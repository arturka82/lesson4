//
//  ViewController.swift
//  lesson4
//
//  Created by GEDAKYAN Artur on 12.02.2024.
//

import UIKit

struct TableItem: Hashable {
    let id = UUID()
    var title: String
    var isChecked: Bool
}

enum Section {
    case main
}

class ViewController: UIViewController {
    var tableView: UITableView!
    var dataSource: UITableViewDiffableDataSource<Section, TableItem>!
    var data: [TableItem] = Array(1...30).map { TableItem(title: "\($0)", isChecked: false) }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureDataSource()
        applySnapshot(animatingDifferences: false)
        setupShuffleButton()
    }

    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        navigationItem.title = "Task 4"
        view.backgroundColor = .white
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, TableItem>(tableView: tableView) {
            (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isChecked ? .checkmark : .none
            return cell
        }
    }

    func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TableItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func setupShuffleButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleAndMoveCheckedItemsToTop))
    }

    @objc func shuffleAndMoveCheckedItemsToTop() {
        data.shuffle()
  
        var snapshot = NSDiffableDataSourceSnapshot<Section, TableItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TableItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func animateCellMovement(cell: UITableViewCell, to position: CGPoint, completion: @escaping () -> Void) {
        guard let snapshot = cell.snapshotView(afterScreenUpdates: true) else { return }
        snapshot.frame = tableView.convert(cell.frame, to: view)
        view.addSubview(snapshot)

        UIView.animate(withDuration: 0.5, animations: {
            snapshot.center = position
        }) { _ in
            snapshot.removeFromSuperview()
            completion()
        }
    }

}

// MARK: ViewController + UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        var newItem = item
        newItem.isChecked.toggle()

        if let index = data.firstIndex(where: { $0.id == item.id }) {
            data.remove(at: index)
            data.insert(newItem, at: 0)
        }

        applySnapshot(animatingDifferences: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
