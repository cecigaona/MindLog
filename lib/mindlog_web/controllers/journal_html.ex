defmodule MindlogWeb.JournalHTML do
  use MindlogWeb, :html

  alias Mindlog.Reflections.Entry

  embed_templates "journal_html/*"

  def emotion_rows(%Entry{analysis: %{"emotions" => emotions}}) when is_map(emotions) do
    Enum.sort_by(emotions, fn {emotion, score} -> {-Map.get(score, "mentions", 0), emotion} end)
  end

  def emotion_rows(_entry), do: []

  def emotion_label(emotion) do
    emotion
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  def overall_label(%Entry{analysis: %{"overall_signal" => signal}}), do: overall_label(signal)

  def overall_label("urgent_support"), do: "Urgent-support language"
  def overall_label("elevated_distress_language"), do: "Elevated distress language"
  def overall_label("some_distress_language"), do: "Some distress language"
  def overall_label("more_positive_language"), do: "More positive language"
  def overall_label(_signal), do: "Mixed or neutral language"

  def overall_badge_class(%Entry{analysis: %{"overall_signal" => signal}}),
    do: overall_badge_class(signal)

  def overall_badge_class("urgent_support"), do: "badge-error"
  def overall_badge_class("elevated_distress_language"), do: "badge-warning"
  def overall_badge_class("some_distress_language"), do: "badge-warning"
  def overall_badge_class("more_positive_language"), do: "badge-success"
  def overall_badge_class(_signal), do: "badge-neutral"

  def crisis_language?(entry), do: analysis_mentions(entry, "crisis_language") > 0
  def trauma_mentions(entry), do: analysis_mentions(entry, "trauma_language")
  def crisis_mentions(entry), do: analysis_mentions(entry, "crisis_language")

  def analysis_mentions(%Entry{analysis: analysis}, category) when is_map(analysis) do
    analysis
    |> Map.get(category, %{})
    |> Map.get("mentions", 0)
  end

  def analysis_mentions(_entry, _category), do: 0

  def formatted_date(%DateTime{} = datetime),
    do: Calendar.strftime(datetime, "%b %d, %Y at %H:%M UTC")

  def formatted_date(_datetime), do: "Unknown date"

  def body_paragraphs(body) do
    case String.split(body, ~r/\R{2,}/u, trim: true) do
      [] -> [body]
      paragraphs -> paragraphs
    end
  end
end
