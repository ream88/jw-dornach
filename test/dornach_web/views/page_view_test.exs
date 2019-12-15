defmodule DornachWeb.PageViewTest do
  use DornachWeb.ConnCase, async: true
  alias DornachWeb.PageView

  test "first" do
    assert PageView.first(~D[2019-11-01]) == ~D[2019-10-28]
    assert PageView.first(~D[2019-12-01]) == ~D[2019-11-25]
    assert PageView.first(~D[2020-01-01]) == ~D[2019-12-30]
  end

  test "last" do
    assert PageView.last(~D[2019-11-01]) == ~D[2019-12-01]
    assert PageView.last(~D[2019-12-01]) == ~D[2020-01-05]
    assert PageView.last(~D[2020-01-01]) == ~D[2020-02-02]
  end
end
