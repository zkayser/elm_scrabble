module Phoenix.Internal.EntityState exposing (EntityState(..))


type EntityState
    = Initializing
    | Connected
    | Errored
    | Closed
    | TimedOut
    | LeaveErrored
