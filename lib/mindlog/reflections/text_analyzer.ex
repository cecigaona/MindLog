defmodule Mindlog.Reflections.TextAnalyzer do
  @moduledoc """
  Transparent, deterministic English word and phrase counting for reflections.

  This module is intentionally not a diagnostic model. Its output is limited to
  the configured lexicon matches so that every stored signal is inspectable.
  """

  @word_pattern ~r/[\p{L}\p{N}]+(?:['’][\p{L}\p{N}]+)?/u

  @emotion_terms %{
    "anger" => ~w(angry anger furious rage frustrated frustration irritated resentful resentment),
    "fear" =>
      ~w(afraid fear fearful scared frightened panic panicked anxious anxiety worried worry),
    "hope" => ~w(hope hopeful optimistic healing resilient relief better),
    "joy" =>
      ~w(happy happiness joyful joy grateful gratitude thankful excited delighted proud calm peaceful content),
    "sadness" =>
      ~w(sad sadness lonely loneliness grief grieving cry crying hopeless depressed down),
    "shame" => ~w(ashamed shame worthless failure inadequate guilty guilt)
  }

  @trauma_terms ~w(
    trauma traumatic flashback flashbacks nightmare nightmares trigger triggered triggers
    unsafe abuse abused assault assaulted violated hypervigilant numb dissociate dissociation
  )

  @crisis_phrases [
    ["kill", "myself"],
    ["end", "my", "life"],
    ["want", "to", "die"],
    ["don't", "want", "to", "live"],
    ["cannot", "go", "on"],
    ["can't", "go", "on"],
    ["hurt", "myself"],
    ["harm", "myself"],
    ["self", "harm"],
    ["suicide"],
    ["suicidal"]
  ]

  @distress_emotions ~w(sadness anger fear shame)
  @positive_emotions ~w(joy hope)

  @spec analyze(String.t()) :: map()
  def analyze(text) when is_binary(text) do
    words = tokenize(text)
    word_count = length(words)
    frequencies = Enum.frequencies(words)
    emotions = count_categories(frequencies, @emotion_terms, word_count)
    trauma_mentions = count_terms(frequencies, @trauma_terms)
    crisis_mentions = count_phrases(words, @crisis_phrases)

    %{
      "word_count" => word_count,
      "emotions" => emotions,
      "trauma_language" => score(trauma_mentions, word_count),
      "crisis_language" => score(crisis_mentions, word_count),
      "overall_signal" => overall_signal(emotions, trauma_mentions, crisis_mentions)
    }
  end

  defp tokenize(text) do
    @word_pattern
    |> Regex.scan(String.downcase(text))
    |> List.flatten()
  end

  defp count_categories(frequencies, categories, word_count) do
    Map.new(categories, fn {category, terms} ->
      {category, score(count_terms(frequencies, terms), word_count)}
    end)
  end

  defp count_terms(frequencies, terms) do
    Enum.reduce(terms, 0, fn term, total -> total + Map.get(frequencies, term, 0) end)
  end

  defp count_phrases(words, phrases) do
    Enum.reduce(phrases, 0, fn phrase, total -> total + phrase_occurrences(words, phrase) end)
  end

  defp phrase_occurrences(words, phrase) do
    words
    |> Enum.chunk_every(length(phrase), 1, :discard)
    |> Enum.count(&(&1 == phrase))
  end

  defp score(mentions, 0), do: %{"mentions" => mentions, "per_100_words" => 0.0}

  defp score(mentions, word_count) do
    %{
      "mentions" => mentions,
      "per_100_words" => Float.round(mentions / word_count * 100, 1)
    }
  end

  defp overall_signal(emotions, trauma_mentions, crisis_mentions) do
    distress_mentions = category_mentions(emotions, @distress_emotions)
    positive_mentions = category_mentions(emotions, @positive_emotions)

    cond do
      crisis_mentions > 0 -> "urgent_support"
      trauma_mentions >= 3 or distress_mentions >= 4 -> "elevated_distress_language"
      distress_mentions > positive_mentions -> "some_distress_language"
      positive_mentions > distress_mentions -> "more_positive_language"
      true -> "mixed_or_neutral_language"
    end
  end

  defp category_mentions(emotions, categories) do
    Enum.reduce(categories, 0, fn category, total ->
      total + get_in(emotions, [category, "mentions"])
    end)
  end
end
