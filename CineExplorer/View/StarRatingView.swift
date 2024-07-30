import UIKit

class StarRatingView: UIView {

    private let starImageViews = [UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView()]

    var voteAverage: Double = 0.0 {
        didSet {
            setupStars()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        for starImageView in starImageViews {
            starImageView.contentMode = .scaleAspectFit
            addSubview(starImageView)
        }
    }

    private func setupStars() {
        let fullStars = Int(voteAverage)
        let hasHalfStar = voteAverage - Double(fullStars) >= 0.5

        for (index, starImageView) in starImageViews.enumerated() {
            if index < fullStars {
                starImageView.image = UIImage(named: "full_star")
            } else if index == fullStars && hasHalfStar {
                starImageView.image = UIImage(named: "half_star")
            } else {
                starImageView.image = UIImage(named: "empty_star")
            }
        }

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let starWidth = bounds.width / CGFloat(starImageViews.count)
        let starHeight = bounds.height

        for (index, starImageView) in starImageViews.enumerated() {
            let xPosition = CGFloat(index) * starWidth
            starImageView.frame = CGRect(x: xPosition, y: 0, width: starWidth, height: starHeight)
        }
    }
}
