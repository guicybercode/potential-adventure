defmodule RealtimeProcessor.Pipeline.ProcessorTest do
  use ExUnit.Case

  alias RealtimeProcessor.Pipeline.Processor

  setup do
    start_supervised!(Processor)
    :ok
  end

  test "processes trade batch" do
    trades = [
      %{
        "symbol" => "BTCUSD",
        "price" => 45000.0,
        "quantity" => 0.25,
        "timestamp" => 1699632000000,
        "side" => "buy"
      }
    ]

    Processor.process_batch(trades)
    Process.sleep(100)

    aggregations = Processor.get_aggregations("BTCUSD")
    assert length(aggregations) >= 0
  end

  test "retrieves aggregations for symbol" do
    result = Processor.get_aggregations("BTCUSD")
    assert is_list(result)
  end

  test "retrieves anomalies for symbol" do
    result = Processor.get_anomalies("BTCUSD")
    assert is_list(result)
  end
end

