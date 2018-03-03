module Widgets.DragAndDrop exposing (..)

import Html exposing (..)
import Html.Attributes exposing (attribute)
import Html.Events exposing (on, onWithOptions)
import Json.Decode as Json


type alias Config msg dragData dropData =
    { dragMsg : dragData -> msg
    , dropMsg : dropData -> msg
    }


draggable : msg -> List (Attribute msg)
draggable toMsg =
    [ attribute "draggable" "true"
    , on "dragstart" <| Json.succeed <| toMsg
    ]


droppable : msg -> List (Attribute msg)
droppable toMsg =
    [ attribute "droppable" "true"
    , onWithOptions "drop" { preventDefault = True, stopPropagation = True } <| Json.succeed <| toMsg
    ]
