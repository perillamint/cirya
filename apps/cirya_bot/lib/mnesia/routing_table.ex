require Exquisite
use Amnesia

defdatabase CiryaBot.Mnesia.RoutingTable do
  deftable Room, [
    {:id, autoincrement},
    :svc_name,
    :room,
    :alias,
    :destinations
  ], type: :ordered_set, index: [:svc_name, :room] do
    @type t :: %Room{
      id: non_neg_integer,
      svc_name: atom,
      room: binary,
      alias: String.t,
      destinations: list(non_neg_integer)
    }

    def get_destinations(self) do
      {_, destinations} = Enum.map_reduce(self.destinations, [], fn(destination, acc) ->
        dest = Room.read(destination)
        {dest, acc ++ [dest]}
      end)

      destinations
    end
  end
end
