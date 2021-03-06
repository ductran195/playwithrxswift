/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

  @IBOutlet weak var searchCityName: UITextField!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var iconLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var tempSwitch: UISwitch!
  
  private let bag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    style()
    
    let search = Observable.from([searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable(),
                               tempSwitch.rx.controlEvent(.valueChanged).asObservable()])
      .merge()
      .map { [weak self] in self?.searchCityName.text }
      .filter { ($0 ?? "").count > 0 }
      .flatMap { text in
        return ApiController.shared.currentWeather(city: text ?? "Error")
          .catchErrorJustReturn(ApiController.Weather.empty)
      }
      .asDriver(onErrorJustReturn: ApiController.Weather.empty)
      
      
    search.map { [weak self] in
        guard let `self` = self else { return "" }
        if self.tempSwitch.isOn {
          return "\($0.temperature)° C"
        } else {
          return "\(1.8 * Double($0.temperature) + 32)° F"
        }
      }
      .drive(tempLabel.rx.text)
      .disposed(by: bag)
    
    search.map { $0.icon }
      .drive(iconLabel.rx.text)
      .disposed(by: bag)
    
    search.map { "\($0.humidity)%" }
      .drive(humidityLabel.rx.text)
      .disposed(by: bag)
      
    search.map { $0.cityName }
      .drive(cityNameLabel.rx.text)
      .disposed(by: bag)

  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    Appearance.applyBottomLine(to: searchCityName)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Style

  private func style() {
    view.backgroundColor = UIColor.aztec
    searchCityName.textColor = UIColor.ufoGreen
    tempLabel.textColor = UIColor.cream
    humidityLabel.textColor = UIColor.cream
    iconLabel.textColor = UIColor.cream
    cityNameLabel.textColor = UIColor.cream
  }
}

