defmodule ScanRecords do
    use GenServer

    def start_link do
      GenServer.start_link(__MODULE__, %{})
    end

    def init(state) do
      schedule_work() # Schedule work to be performed on start
      {:ok, state}
    end

    def handle_info(:work, state) do
      IO.puts "hello"

      # Do the desired work here
      schedule_work() # Reschedule once more
      {:noreply, state}
    end

    defp schedule_work() do
      Process.send_after(self(), :work, 5 * 1000) # In 2 hours
    end
end
