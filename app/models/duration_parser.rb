# Reads cooking times the way recipes write them and returns whole minutes.
#
#   DurationParser.minutes("1 hr 15 mins")  # => 75
#   DurationParser.minutes("1 1/2 hours")   # => 90
#   DurationParser.minutes("PT45M")         # => 45
#   DurationParser.minutes("soon")          # => nil
module DurationParser
  HOURS = /h|hr|hrs|hour|hours/
  MINUTES = /m|min|mins|minute|minutes/

  module_function

  def minutes(text)
    text = text.to_s.downcase.strip
    return if text.empty?
    return iso8601(text) if text.start_with?("pt")

    total = 0
    found = false
    text.scan(/(#{Quantity::NUMBER})\s*(#{HOURS}|#{MINUTES})(?![a-z])/o) do |number, unit|
      value = Quantity.parse(number) or next
      found = true
      total += unit.start_with?("h") ? value * 60 : value
    end
    # "1 hr 15" - a bare number after the hours is minutes.
    if found && (bare = text.match(/(?:#{HOURS})\s*(\d+)\s*\z/o))
      total += bare[1].to_i
    end
    return text.to_i if !found && text.match?(/\A\d+\z/)
    return unless found

    total.round
  end

  def iso8601(text)
    match = text.match(/\Apt(?:(\d+)h)?(?:(\d+)m)?/)
    return unless match && (match[1] || match[2])

    match[1].to_i * 60 + match[2].to_i
  end
end
