require "test_helper"

class WeekTest < ActiveSupport::TestCase
  test "weeks start on monday" do
    week = Week.new(Date.new(2026, 3, 5))
    assert_equal Date.new(2026, 3, 2), week.start
    assert_equal Date.new(2026, 3, 8), week.finish
    assert_equal 7, week.days.count
    assert Week.new(Date.new(2026, 3, 8)) == week, "sunday belongs to the week before it"
  end

  test "previous and next" do
    week = Week.new(Date.new(2026, 3, 2))
    assert_equal Date.new(2026, 2, 23), week.previous.start
    assert_equal Date.new(2026, 3, 9), week.next.start
  end

  test "labels" do
    assert_equal "2–8 March 2026", Week.new(Date.new(2026, 3, 2)).label
  end

  test "labels for weeks that span two months or years" do
    assert_equal "30 Mar – 5 Apr 2026", Week.new(Date.new(2026, 3, 30)).label
    assert_equal "29 Dec 2025 – 4 Jan 2026", Week.new(Date.new(2025, 12, 29)).label
  end

  test "parse" do
    assert_equal Date.new(2026, 3, 2), Week.parse("2026-03-04").start
    assert_equal Week.current, Week.parse(nil)
    assert_equal "2026-03-02", Week.parse("2026-03-02").to_param
  end

  test "parse falls back to this week for anything unreadable" do
    assert_equal Week.current, Week.parse("next tuesday")
    assert_equal Week.current, Week.parse("2026-02-31")
    assert_equal Week.current, Week.parse([ "2026-03-02" ])
  end
end
