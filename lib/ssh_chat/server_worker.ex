defmodule SSHChat.ServerWorker do
  use GenServer

  @doc """
  Starts the worker.
  """
  def start_link(%{port: _} = state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    IO.puts "Starting SSH server on port #{state[:port]}"
    {:ok, daemon_pid} = :ssh.daemon(:any, state[:port],
      key_cb: SSHChat.ServerKeyQuery,
      shell: fn(user) -> start_shell(user) end,
      auth_methods: 'publickey'
    )
    Process.link(daemon_pid)

    {:ok, %{port: state[:port], daemon_pid: daemon_pid}}
  end

  defp start_shell(user) do
    spawn(fn() ->
      # :io.setopts(expand_fun: fn(bef) -> expand(bef) end)
      IO.puts "Hello #{user}!"
      Process.put :user, user
    end)
  end
end
