defmodule DynNameserver.Nameserver do
  alias DynNameserver.Util.RedixPool, as: Redis
  alias DynNameserver.Util.Ip, as: IpUtil

  def prefix_records, do: "dyn--nameserver--"

  @moduledoc """
  Documentation for DynDns.
  """

  @behaviour DNS.Server
  use DNS.Server


  defp find_a_record(domain) do
    key_name = "#{prefix_records}#{domain}"

    result_a_record = case Redis.command(["GET", "#{key_name}"]) do
      {:ok, res} -> res
      _ -> nil
    end

    case result_a_record do
      nil -> nil
      _ -> IpUtil.s_ip_to_array(result_a_record)
    end
  end

  defp find_record(query) do
    fmt_domain = if is_list(query.domain) do
      List.to_string(query.domain)
    else
      query.domain
    end

    case query.type do
      :a -> String.downcase(fmt_domain) |> find_a_record
      _ -> nil
    end
  end

  def handle(record, _cl) do
    IO.puts "record=#{inspect(record)}"
    query = hd(record.qdlist)

    result = find_record(query)

    IO.puts "   -> #{inspect(result)}"

    case result do
      nil -> %{record | anlist: [], header: %{record.header | qr: true}}
      _ -> resource = %DNS.Resource{
        domain: query.domain,
        class: query.class,
        type: query.type,
        ttl: 0,
        data: result
      }
      %{record | anlist: [resource], header: %{record.header | qr: true}}
    end
  end

end
