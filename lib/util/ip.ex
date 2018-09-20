defmodule DynNameserver.Util.Ip do

  def s_ip_to_array(ip) do
    String.split(ip, ".")
      |> Enum.map(fn elem -> String.to_integer(elem) end)
  end


end
