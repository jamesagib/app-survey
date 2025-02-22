import SwiftUI

@MainActor
struct SurveyQuestionView {
    private let question: SurveyQuestion
    @Binding private var answers: Set<String>
    @State private var otherText: String = ""
    let customFont: String // Added custom font property

    init(
        question: SurveyQuestion,
        answers: Binding<Set<String>>,
        customFont: String // Added custom font to initializer
    ) {
        self.question = question
        self._answers = answers
        self.customFont = customFont
    }

    private func binding(for answer: String) -> Binding<Bool> {
        .init(
            get: { answers.contains(answer) },
            set: { _ in
                if !question.isMultipleChoice && !answers.contains(answer) {
                    answers.removeAll()
                    otherText = ""
                }
                answers.toggle(answer)
            }
        )
    }

    private func otherTextChanged(oldText: String, newText: String) {
        answers.remove(oldText)
        guard !newText.isEmpty else { return }

        if !question.isMultipleChoice {
            answers.removeAll()
        }

        answers.insert(newText)
    }

    private func resetOtherText() {
        guard let otherAnswer = answers.first(where: { answer in
            !question.answers.contains(answer)
        }) else {
            otherText = ""
            return
        }
        otherText = otherAnswer
    }
}

extension SurveyQuestionView: View {
    var body: some View {
        VStack(spacing: 16) {
            titleView
            selectAllThatApplyView
            answerList
        }
    }

    private var titleView: some View {
        Text(question.title)
            .font(.custom(customFont, size: 18).weight(.semibold)) // Applied custom font
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 24)
    }

    @ViewBuilder
    private var selectAllThatApplyView: some View {
        if question.isMultipleChoice {
            Text(.selectAllThatApply)
                .font(.custom(customFont, size: 32).weight(.medium)) // Applied custom font
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var answerList: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(
                    question.answers,
                    id: \.self,
                    content: answerToggle
                )
                otherTextField
            }
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
    }

    private func answerToggle(answer: String) -> some View {
        Toggle(answer, isOn: binding(for: answer))
            .toggleStyle(.bezeledGray)
            .font(.custom(customFont, size: 16)) // Applied custom font
    }

    @ViewBuilder
    private var otherTextField: some View {
        if question.includeOther {
            OtherTextField(text: $otherText)
                .onChange(of: otherText, otherTextChanged)
                .onChange(of: question, resetOtherText)
        }
    }
}

