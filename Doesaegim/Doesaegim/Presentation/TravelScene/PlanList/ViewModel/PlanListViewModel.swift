//
//  PlanListViewModel.swift
//  Doesaegim
//
//  Created by sun on 2022/11/15.
//

import Foundation

final class PlanListViewModel {

    // MARK: - Properties

    let navigationTitle: String?

    /// 일정 데이터를 성공적으로 받아왔을 때 호출하는 클로저
    var planFetchHandler: ((Bool) -> Void)?

    /// 일정을 성공적으로 삭제했을 때 호출하는 클로저
    var planDeleteHandler: ((UUID) -> Void)?

    private(set) var planViewModels = [[PlanViewModel]]()

    private let travel: Travel

    private let repository: PlanRepository

    /// 22.11.16(수) 형태의 날짜를 리턴하는 DateFormatter
    private let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = StringLiteral.dateFormat
        return formatter
    }()

    /// 현재 갖고 있는 일정 중 가장 오래된 날짜
    private var lastSection: String? {
        guard let plan = planViewModels.last?.last?.plan,
              let date = plan.date
        else {
            return nil
        }

        return sectionDateFormatter.string(from: date)
    }

    
    // MARK: - Init(s)

    init(travel: Travel, repository: PlanRepository) {
        self.repository = repository
        self.travel = travel
        self.navigationTitle = travel.name
    }


    // MARK: - Functions

    func title(forSection section: Int) -> String? {
        guard let plan = planViewModels[section].first?.plan,
              let date = plan.date
        else {
            return nil
        }

        return sectionDateFormatter.string(from: date)
    }

    func item(at indexPath: IndexPath, withID id: UUID) -> PlanViewModel? {
        // TODO: Safe Subscript -> 이 부분은 내일 대대적인 리팩토링이 있을 것 같아 일단 그냥 뒀습니다!
        let item = planViewModels[indexPath.section][indexPath.row]
        return item.id == id ? item : nil
    }


    // MARK: - Plan Fetching Functions

    func fetch() throws {
        let plans = try repository.fetchPlans(ofTravel: travel)
        convertPlansToPlanViewModelsAndAppend(plans)
        planFetchHandler?(planViewModels.isEmpty)
    }

    private func convertPlansToPlanViewModelsAndAppend(_ plans: [Plan]) {
        plans.forEach {
            guard let date = $0.date
            else {
                return
            }

            let section = sectionDateFormatter.string(from: date)
            let viewModel = PlanViewModel(plan: $0, repository: repository)

            if section == lastSection {
                planViewModels[planViewModels.count - 1].append(viewModel)
            } else {
                planViewModels.append([viewModel])
            }
        }
    }


    // MARK: - Plan Deleting Functions

    func deletePlan(at indexPath: IndexPath) throws {
        let section = indexPath.section
        let index = indexPath.row

        guard section < planViewModels.count,
              index < planViewModels[section].count
        else { return }

        let planViewModel = planViewModels[section][index]
        try repository.deletePlan(planViewModel.plan)
        planViewModels[section].remove(at: index)
        if planViewModels[section].isEmpty {
            planViewModels.remove(at: section)
        }
        planDeleteHandler?(planViewModel.id)
    }
}


// MARK: - Constants
fileprivate extension PlanListViewModel {

    enum StringLiteral {
        static let dateFormat = "yy.MM.dd(E)"
    }
}
