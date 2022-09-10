defmodule XmlEndGz do
  @acc_size 100

  def extract(path, first_element, start_from_element, output_path) do
    first = find_beginning(path, "<CD id=")
    last = find_ending(path, "<CD id=\"3\">")
    File.write!(output_path, first <> last)
  end

  defp find_beginning(path, element) do
    "test/example1.xml.gz"
    |> File.stream!
    |> StreamGzip.gunzip
    |> Stream.chunk_while("",
         fn chunk, acc ->
           if String.contains?(acc <> chunk, element) do
             [left, right] = String.split(acc <> chunk, element, parts: 2)
             {:halt, left}
           else
             {:cont, acc <> chunk}
           end
         end,
         fn acc ->
           {:cont, acc, ""}
         end
       )
    |> Enum.into("")
  end

  defp find_ending(path, element) do
    "test/example1.xml.gz"
    |> File.stream!
    |> StreamGzip.gunzip
    |> Stream.chunk_while({:not_found, ""}, fn
      chunk, {:not_found, acc} ->
        if String.contains?(acc <> chunk, element) do
          [left, right] = String.split(acc <> chunk, element, parts: 2)
          {:cont, {:found, element <> right}}
        else
          string = acc <> chunk
          new_acc = String.slice(string, String.length(string) - @acc_size, @acc_size)
          {:cont, {:not_found, new_acc}}
        end
      chunk, {:found, acc} ->
        {:cont, {:found, acc <> chunk}}
    end,
         fn
           {:not_found, acc} ->
             {:cont, :not_found, ""}
           {:found, acc} ->
             {:cont, acc, ""}
         end
       )
    |> Enum.into("")
  end


end
