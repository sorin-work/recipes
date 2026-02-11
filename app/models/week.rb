# A Monday-to-Sunday week, the unit the planner and grocery list work in.
class Week
  include Comparable

  attr_reader :start

  def self.current
    new(Date.current)
  end

  # From a ?week=2026-03-02 parameter. Anything unreadable means this week.
  def self.parse(param)
    param.present? ? new(Date.iso8601(param.to_s)) : current
  rescue Date::Error
    current
  end

  def initialize(date)
    @start = date.to_date.beginning_of_week(:monday)
  end

  def finish = start + 6
  def days = (start..finish)
  def previous = Week.new(start - 7)
  def next = Week.new(start + 7)
  def current? = include?(Date.current)
  def include?(date) = days.cover?(date)
  def to_param = start.iso8601
  def <=>(other) = start <=> other.start

  def label
    if start.month == finish.month
      "#{start.day}–#{finish.day} #{finish.strftime('%B %Y')}"
    elsif start.year == finish.year
      "#{start.strftime('%-d %b')} – #{finish.strftime('%-d %b %Y')}"
    else
      "#{start.strftime('%-d %b %Y')} – #{finish.strftime('%-d %b %Y')}"
    end
  end
end
