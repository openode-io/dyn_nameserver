defmodule DynNameserverUtilIpTest do
  use ExUnit.Case
  doctest DynNameserver.Util.Ip

  describe "Util Ip > s_ip_to_array" do
    test "with localhost valid ip" do
      assert DynNameserver.Util.Ip.s_ip_to_array("127.0.0.1") == [127, 0, 0, 1]
    end

    test "with network ip" do
      assert DynNameserver.Util.Ip.s_ip_to_array("192.168.0.1") == [192, 168, 0, 1]
    end

    test "with invalid ip should return nil" do
      assert DynNameserver.Util.Ip.s_ip_to_array("192.168.0") == nil
    end

    test "with word without dot should return nil" do
      assert DynNameserver.Util.Ip.s_ip_to_array("hello") == nil
    end
  end

end
