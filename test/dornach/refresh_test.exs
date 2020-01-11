defmodule Dornach.RefreshTest do
  use ExUnit.Case, async: false
  alias Dornach.Refresh

  setup :stop_refresh_process

  setup do
    test = self()

    callback = fn ->
      send(test, :sync)
    end

    {:ok, callback: callback}
  end

  test "callback is called upon start", %{callback: callback} do
    {:ok, _pid} = Refresh.start_link(callback)
    assert_receive :sync
  end

  test "callback is called periodically", %{callback: callback} do
    {:ok, _pid} = Refresh.start_link(callback)
    assert_receive :sync
    assert_receive :sync
    assert_receive :sync
  end

  defp stop_refresh_process(_) do
    pid = Process.whereis(Refresh)
    ref = Process.monitor(pid)
    Process.exit(pid, :kill)

    receive do
      {:DOWN, ^ref, :process, ^pid, _msg} -> :ok
    end
  end
end
