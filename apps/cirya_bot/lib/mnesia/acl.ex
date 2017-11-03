use Amnesia

defdatabase CiryaBot.Mnesia.ACL do
  deftable Role, [
    {:id, autoincrement},
    :name,
    :flags,
  ], type: :ordered_set do
    @type t :: %Role{
      id: non_neg_integer,
      name: String.t,
      flags: list(String.t)
    }
  end

  deftable User, [
    {:id, autoincrement},
    :svc_name,
    :username,
    :roles
  ], type: :ordered_set, index: [:svc_name, :username] do
    @type t :: %User{
      id: non_neg_integer,
      svc_name: String.t,
      username: String.t,
      roles: list(non_neg_integer)
    }

    def get_flags(self) do
      Enum.map_reduce(self.roles, [], fn(role, acc) ->
        flags = Role.read(role).flags
        {flags, acc <> flags}
      end) |> Enum.uniq()
    end
  end
end
