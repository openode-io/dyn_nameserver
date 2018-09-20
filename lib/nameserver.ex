defmodule DynNameserver.Nameserver do
  alias DynNameserver.RedixPool, as: Redis

  def prefix_records, do: "dyn--nameserver--"

  @moduledoc """
  Documentation for DynDns.
  """

  @behaviour DNS.Server
  use DNS.Server

  defp s_ip_to_array(ip) do
    String.split(ip, ".")
      |> Enum.map(fn elem -> String.to_integer(elem) end)
  end

  defp find_a_record(domain) do
    key_name = "#{prefix_records}#{domain}"

    result_a_record = case Redis.command(["GET", "#{key_name}"]) do
      {:ok, res} -> res
      _ -> nil
    end

    case result_a_record do
      nil -> nil
      _ -> s_ip_to_array(result_a_record)
    end
  end

  defp find_record(query) do
    case query.type do
      :a -> find_a_record(query.domain)
      _ -> nil
    end
  end

  def handle(record, _cl) do
    IO.puts "record=#{inspect(record)}"
    query = hd(record.qdlist)

    resource = %DNS.Resource{
      domain: query.domain,
      class: query.class,
      type: query.type,
      ttl: 0,
      data: find_record(query)
    }

    %{record | anlist: [resource]}
  end

end
