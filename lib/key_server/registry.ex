defmodule KeyServer.Registry do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Registers a user if it doesn't exist; authenticates it otherwise.

  Returns `{:ok, :registered}` on register, `{:ok, :authenticated}` on
  successful authentication, and `{:error, :invalid_key}` on unsuccessful
  authentication. `{:error, :invalid_key}` will be returned if the public key
  has already been authenticated to a different user.
  """
  def authenticate_or_register_user(name, public_key) do
    GenServer.call(__MODULE__, {:auth_or_register, name, public_key})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{keys: HashSet.new, users: HashDict.new}}
  end

  def handle_call({:auth_or_register, name, public_key}, _from, state) do
    r = case HashDict.fetch(state.users, name) do
      {:ok, ^public_key} ->
        {:ok, :authenticated}
      {:ok, _} ->
        {:error, :invalid_key}
      :error ->
        case HashSet.member?(state.keys, public_key) do
          true ->
            {:error, :key_exists}
          false ->
            state = state
              |> put_in([:users], HashDict.put(state.users, name, public_key))
              |> put_in([:keys], HashSet.put(state.keys, public_key))
            {:ok, :registered}
        end
    end

    {:reply, r, state}
  end
end
