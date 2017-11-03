use Amnesia

defdatabase CiryaBot.Mnesia.RoutingTable do
  deftable Destination, [{:id, autoincrement}, :svc_name, :room], type: :ordered_set do
    @type t :: %Destination{
      id: non_neg_integer,
      svc_name: String.t,
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
      svc_name: String.t,
      room: binary,
      destinations: list(non_neg_integer)
    }
  end
end