defmodule RealtimeProcessor.Pipeline.Broadway do
  use Broadway

  alias Broadway.Message
  alias RealtimeProcessor.Pipeline.Processor

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayKafka.Producer,
           [
             hosts: [localhost: 9092],
             group_id: "realtime_processor",
             topics: ["trades", "orders"]
           ]},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 10]
      ],
      batchers: [
        default: [concurrency: 5, batch_size: 100, batch_timeout: 1000]
      ]
    )
  end

  def handle_message(_processor, message, _context) do
    message
    |> Message.update_data(&process_message/1)
    |> Message.put_batch_key(:default)
  end

  def handle_batch(_batcher, messages, _batch_info, _context) do
    trades = Enum.map(messages, & &1.data)
    Processor.process_batch(trades)
    messages
  end

  defp process_message(%Message{data: data} = message) do
    case Jason.decode(data) do
      {:ok, trade} ->
        :telemetry.execute([:realtime_processor, :message, :received], %{count: 1}, %{
          topic: message.metadata.topic
        })
        trade

      {:error, _} ->
        :telemetry.execute([:realtime_processor, :message, :parse_error], %{count: 1}, %{})
        data
    end
  end
end

