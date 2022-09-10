defmodule XmlEnd do
  @chunk_size 100

  def extract(path, first_element, start_from_element, output_path) do
    first = read_headers_until(path, "<CD id=")
    position = find_position(path, "<CD id=\"3\">")
    last = read_from_position(path, position)
    File.write!(output_path, first <> last)
  end

  defp read_from_position(path, position) do
    {:ok, %{size: size}} = File.stat(path)
    {:ok, file} = :file.open(path, [:read, :binary])
    :file.position(file, position)
    {:ok, content} = :file.read(file, size - position)
    content
  end

  defp find_position(path, element) do
    {:ok, %{size: size}} = File.stat(path)
    {:ok, file} = :file.open(path, [:read, :binary])
    try do
      read_chunks(file, size - @chunk_size - 1, element, "")
    catch
      position ->
        position
    end
  end

  defp read_chunks(file, position, element, string_before) do
    :file.position(file, position)
    case :file.read(file, @chunk_size) do
      :eof ->
        :nothing
      {:ok, binary} ->
        string = binary <> string_before
        if String.contains?(string, element) do
          [left, right] = String.split(string, element, parts: 2)
          throw(position + String.length(left))
        end
        read_chunks(file, position - @chunk_size, element, binary)
    end
  end

  defp read_headers_until(path, element) do
    {:ok, file} = :file.open(path, [:read, :binary])
    try do
      do_read_headers(file, 0, element, "")
    catch
      string ->
        string
    end
  end

  defp do_read_headers(file, position, element, acc) do
    :file.position(file, position)
    case :file.read(file, @chunk_size) do
      :eof ->
        :nothing
      {:ok, binary} ->
        if String.contains?(acc <> binary, element) do
          [left, _right] = String.split(acc <> binary, element, parts: 2)
          throw(left)
        end
        do_read_headers(file, position + @chunk_size, element, acc <> binary)
    end
  end
end
