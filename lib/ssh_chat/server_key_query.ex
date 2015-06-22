defmodule SSHChat.ServerKeyQuery do
  @behaviour :ssh_server_key_api

  def host_key(:"ssh-rsa", _opts) do
    {:ok, pem} = File.read("./ssh/ssh_host_key")
    [rsa] = :public_key.pem_decode pem

    {:ok, :public_key.pem_entry_decode rsa}
  end

  def host_key(_other, _opts) do
    {:error, :unsupported}
  end

  def is_auth_key(key, user, _opts) do
    case KeyServer.Registry.authenticate_or_register_user(user, key) do
      {:ok, _msg} ->
        true
      {:error, _msg} ->
        false
    end
  end
end
