defmodule Tcp do
  use Supervisor
  def open(port) do
    :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, false}])
  end
  def close(socket) do :gen_tcp.close(socket) end
  def start_link(x, func) do
		{port, id} = x
		Supervisor.start_link(__MODULE__, [port, func, id])
	end
	def atom_join(x, y) do
		a=to_string(x) <> "." <> to_string(y)
		String.to_atom(a)
	end
	def sup_name(i) do atom_join(Tcp.TaskSupervisor, i) end
  def init(x) do
		[port, func, id] = x
		y=sup_name(id)
    children = [
      supervisor(Task.Supervisor, [[name: y]]),
    worker(Task, [Tcp, :accept, x])
    ]
    opts = [strategy: :one_for_one, name: TcpServer.Supervisor]
    supervise(children, opts)
  end
  def accept(port, func, id) do
		:timer.sleep(100)
    {x, socket} = open(port)
		IO.puts("tcp accept #{inspect x}")
		case x do
			:ok -> 
				IO.puts "Accepting connections on port #{port}"
				loop_acceptor(socket, port, func, id)
			_ ->
				IO.puts("failed to connect 2")
				reset_acceptor(socket, port, func, id)
		end
  end
	def reset_acceptor(socket, port, func, id) do
    close(socket)
    :timer.sleep(8000)
    spawn_link(fn -> accept(port, func, id) end)
	end
  def loop_acceptor(socket, port, func, id) do
    {x, conn} = :gen_tcp.accept(socket)
    cond do
      x == :ok ->
				Task.Supervisor.start_child(sup_name(id), fn -> serve(conn, func) end)
				:timer.sleep(10)
				loop_acceptor(socket, port, func, id)
      true ->
        IO.puts("failed to connect #{inspect conn}")
				reset_acceptor(socket, port, func, id)
    end
  end
  def serve(client, func) do client |> listen |> func.() |> ms(client) end
  defp ms(string, socket) do
    if is_pid(string) do
      true = false
    end
    m=PackWrap.pack(string)
    s=byte_size(m)
    a=<<s::size(32)>>
    :gen_tcp.send(socket, a <> m)
  end
  defp connect(host, port) do
    {x, s} = :gen_tcp.connect(:erlang.binary_to_list(host), port, [{:active, false}, {:packet, 0}])
    cond do
      x == :ok -> s
      true -> "error"
    end
  end
  def talk(host, port, msg) do
    s = connect(host, port)
    if s == "error" do
      {:error, "peer is off"}
    else
      case ms(msg, s) do
        :ok -> {:ok, listen(s, "")}
        x -> {:error, x}
      end
    end
  end
  def ping(host, port) do
    s = connect(host, port)
    ms("ping", s)
  end
	defp to_bytes(list) do
		cond do
			is_binary(list) -> list
			true -> to_bytes(list, "")
		end
	end
	defp to_bytes(list, out) do
		cond do
			list == [] -> out
			true -> to_bytes(tl(list), out <> <<hd(list)>>)
		end
	end
  defp listen(conn, data \\ "") do
		:timer.sleep(20)
		case :gen_tcp.recv(conn, 0) do
      {:ok, d} -> done_listening?(conn, data <> to_bytes(d))
      {:error, :closed} -> IO.puts "error"
    end
  end
  defp done(data) do
    cond do
      byte_size(data) < 4 -> false
      true ->
        <<a::size(32), b::binary>> = data
        cond do
          byte_size(b) == a -> true
          true -> false
        end
    end
  end
  defp done_listening?(conn, data) do
    cond do
      done(data) ->
        <<_::size(32), data::binary>> = data
        PackWrap.unpack(data)
      true -> listen(conn, data)
    end
  end
  def test do
    port = 6664
    start_link(port, &(&1))
    IO.puts(inspect talk("localhost", port, ["spend"]))
  end
end
