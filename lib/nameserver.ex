defmodule DynNameserver.Nameserver do
  alias DynNameserver.Util.RedixPool, as: Redis
  alias DynNameserver.Util.Ip, as: IpUtil
  alias Jason

  def prefix_records, do: "dyn--nameserver--"

  @moduledoc """
  Documentation for DynNameserver.
  """

  def start_link(port) do
    GenServer.start_link(__MODULE__, [port])
  end

  def init([port]) do
    socket = Socket.UDP.open!(port, as: :binary, mode: :active)
    IO.puts("Server listening at #{port}")

    # accept_loop(socket, handler)
    {:ok, %{port: port, socket: socket}}
  end

  def handle_info({:udp, client, ip, wtv, data}, state) do
    try do
      record = DNS.Record.decode(data)
      response = handle(record, client)
      Socket.Datagram.send!(state.socket, DNS.Record.encode(response), {ip, wtv})

      {:noreply, state}
    catch
      _ -> {:noreply, state}
    end
  end

  #@behaviour DNS.Server
  #use DNS.Server#, except: [handle_info: 2]

  defp extract_redis_result_values(results) do
    Enum.map(results, fn(result) ->
      result_get = case Redis.command(["GET", result]) do
        {:ok, res} -> res
        _ -> nil
      end

      Jason.decode!(result_get)["value"]
    end)
  end

  defp find_redis_records(domain, type) do
    key_name = "#{prefix_records}#{domain}--#{type}--"
    IO.puts "key name = #{key_name}"

    results = case Redis.command(["KEYS", "#{key_name}*"]) do
      {:ok, res} -> res
      _ -> nil
    end

    res_gets = extract_redis_result_values(results)

    case res_gets do
      nil -> nil
      _ -> res_gets #IpUtil.s_ip_to_array(result_a_record)
    end
  end

  defp find_records(query) do
    fmt_domain = if is_list(query.domain) do
      List.to_string(query.domain)
    else
      query.domain
    end

    type = Atom.to_string(query.type) |> String.upcase
    allowed_types = ["A", "TXT", "CNAME"] # "AAAA", "MX",

    cond do
      Enum.member?(allowed_types, type) -> find_redis_records(String.downcase(fmt_domain), type)
      true -> nil
    end
  end

  def string_result_to_data_resource(result, type) do
    case type do
      :a -> IpUtil.s_ip_to_array(result)
      # :aaaa -> [String.to_charlist(result)]
      :cname -> String.to_charlist(result)
      # :mx -> String.to_charlist(result)
      :txt -> [String.to_charlist(result)]
      _ -> nil
    end
  end

  def handle(record, _cl) do
    try do
      IO.puts "record=#{inspect(record)}"
      query = hd(record.qdlist)

      results = find_records(query)

      IO.puts "   -> #{inspect(results)}"

      case results do
        nil -> %{record | anlist: [], header: %{record.header | qr: true}}
        _ -> resources = Enum.map(results, fn(result) ->
          %DNS.Resource{
            domain: query.domain,
            class: query.class,
            type: query.type,
            ttl: 0,
            data: string_result_to_data_resource(result, query.type)
          }
          end)
        %{record | anlist: resources, header: %{record.header | qr: true}}
      end
    rescue
      _ -> %{record | anlist: [], header: %{record.header | qr: true}}
    end

  end

end
