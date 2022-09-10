defmodule XmlEndTest do
  use ExUnit.Case

  test "XmlEnd" do
    XmlEnd.extract("test/example1.xml", "<CD id=", "<CD id=\"3\">", "test/output.xml")
  end

  test "XmlEndGz" do
    XmlEndGz.extract("test/example1.xml.gz", "<CD id=", "<CD id=\"3\">", "test/outputgz.xml")
  end
end
