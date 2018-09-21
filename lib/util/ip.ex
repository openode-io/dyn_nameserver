defmodule DynNameserver.Util.Ip do

  def s_ip_to_array(ip) do
    try do
      parts = String.split(ip, ".")
        |> Enum.map(fn elem -> String.to_integer(elem) end)

      case length(parts) do
        4 -> parts
        _ -> nil
      end
    rescue
      _ -> nil
    end
  end
end
