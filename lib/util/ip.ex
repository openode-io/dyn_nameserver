defmodule DynNameserver.Util.Ip do

  def s_ip_to_array(ip) do
    try do
      String.split(ip, ".")
        |> Enum.map(fn elem -> String.to_integer(elem) end)
    rescue
      _ -> nil
    end
  end
end
