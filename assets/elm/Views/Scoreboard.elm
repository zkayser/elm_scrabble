module Views.Scoreboard exposing (view)

import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events


view : model -> Html msg
view model =
    div [ Attributes.class "scoreboard-header" ]
        [ text "Scoreboard" ]
