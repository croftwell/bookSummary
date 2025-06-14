import SwiftUI

/// Tek bir onboarding sayfasını gösteren SwiftUI View'ı.
struct OnboardingPageView: View {
    
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image(viewModel.pageData.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
            
            Spacer()

            VStack(spacing: 15) {
                Text(LocalizedStringKey(viewModel.pageData.titleKey), tableName: "Onboarding")
                    .font(.title2).bold()
                    .foregroundColor(Theme.darkText)
                
                Text(LocalizedStringKey(viewModel.pageData.descriptionKey), tableName: "Onboarding")
                    .font(.body)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.bottom, 40) // Metin grubunu biraz yukarıda tut
            
            Spacer()
            Spacer()
        }
        .padding()
        .background(Theme.lightGrayBackground)
    }
}

#Preview {
    let samplePageData = OnboardingPageData(
        titleKey: "onboarding_page1_title",
        descriptionKey: "onboarding_page1_description",
        imageName: "onboarding1"
    )
    let viewModel = OnboardingViewModel(pageData: samplePageData)

    return OnboardingPageView(viewModel: viewModel)
        .environment(\.locale, .init(identifier: "tr"))
}
