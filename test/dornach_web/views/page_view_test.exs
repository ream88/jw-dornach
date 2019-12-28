defmodule DornachWeb.PageViewTest do
  use DornachWeb.ConnCase, async: true
  alias DornachWeb.PageView

  test "first_day_of_calendar" do
    assert PageView.first_day_of_calendar(~D[2019-11-01]) == ~D[2019-10-28]
    assert PageView.first_day_of_calendar(~D[2019-12-01]) == ~D[2019-11-25]
    assert PageView.first_day_of_calendar(~D[2020-01-01]) == ~D[2019-12-30]
  end

  test "last_day_of_calendar" do
    assert PageView.last_day_of_calendar(~D[2019-11-01]) == ~D[2019-12-01]
    assert PageView.last_day_of_calendar(~D[2019-12-01]) == ~D[2020-01-05]
    assert PageView.last_day_of_calendar(~D[2020-01-01]) == ~D[2020-02-02]
  end

  test "first_day_of_previous_month" do
    assert PageView.first_day_of_previous_month(~D[2019-11-01]) == ~D[2019-10-01]
    assert PageView.first_day_of_previous_month(~D[2019-01-01]) == ~D[2018-12-01]
  end

  test "first_day_of_next_month" do
    assert PageView.first_day_of_next_month(~D[2019-11-01]) == ~D[2019-12-01]
    assert PageView.first_day_of_next_month(~D[2019-12-01]) == ~D[2020-01-01]
  end
end
