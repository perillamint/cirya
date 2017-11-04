require Exquisite
use Amnesia

defdatabase CiryaBot.Mnesia.RoutingTable do
  deftable Destination, [{:id, autoincrement}, :svc_name, :room], type: :ordered_set do
    @type t :: %Destination{
      id: non_neg_integer,
      svc_name: atom,
      room: binary
    }
  end

  deftable Source, [
    {:id, autoincrement},
    :svc_name,
    :room,
    :destinations
  ], type: :ordered_set, index: [:svc_name, :room] do
    @type t :: %Source{
      id: non_neg_integer,
      svc_name: atom,
      room: binary,
      destinations: list(non_neg_integer)
    }

    def get_destinations(self) do
      {_, destinations} = Enum.map_reduce(self.destinations, [], fn(destination, acc) ->
        dest = Destination.read(destination)
        {dest, acc ++ [dest]}
      end)

      destinations
    end
  end
end
