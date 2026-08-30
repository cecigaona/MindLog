defmodule Mindlog.Reflections.TextAnalyzerTest do
  use ExUnit.Case, async: true

  alias Mindlog.Reflections.TextAnalyzer

  test "counts emotion and trauma-related lexicon matches per one hundred words" do
    analysis = TextAnalyzer.analyze("I am grateful and hopeful, but anxious after a nightmare.")

    assert analysis["word_count"] == 10
    assert analysis["emotions"]["joy"] == %{"mentions" => 1, "per_100_words" => 10.0}
    assert analysis["emotions"]["hope"] == %{"mentions" => 1, "per_100_words" => 10.0}
    assert analysis["emotions"]["fear"] == %{"mentions" => 1, "per_100_words" => 10.0}
    assert analysis["trauma_language"] == %{"mentions" => 1, "per_100_words" => 10.0}
    assert analysis["overall_signal"] == "more_positive_language"
  end

  test "surfaces urgent-support language without claiming a diagnosis" do
    analysis = TextAnalyzer.analyze("I do not know what to do. I want to die.")

    assert analysis["crisis_language"]["mentions"] == 1
    assert analysis["overall_signal"] == "urgent_support"
  end

  test "handles an empty string without dividing by zero" do
    analysis = TextAnalyzer.analyze("")

    assert analysis["word_count"] == 0
    assert analysis["emotions"]["joy"]["per_100_words"] == 0.0
    assert analysis["trauma_language"]["per_100_words"] == 0.0
  end
end
