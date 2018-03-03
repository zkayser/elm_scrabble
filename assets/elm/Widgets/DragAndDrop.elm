module Widgets.DragAndDrop exposing (..)

import Html exposing (..)
import Html.Attributes exposing (attribute)
import Html.Events exposing (on, onWithOptions)
import Json.Decode as Json


type alias Config msg dragData dropData =
    { dragStartMsg : dragData -> msg
    , dragEndMsg : msg
    , dropMsg : dropData -> msg
    , dragOverMsg : dropData -> msg
    }


draggable : msg -> msg -> List (Attribute msg)
draggable dragStartMsg dragEndMsg =
    [ attribute "draggable" "true"
    , on "dragstart" <| Json.succeed <| dragStartMsg
    , on "dragend" <| Json.succeed <| dragEndMsg
    ]


droppable : msg -> msg -> List (Attribute msg)
droppable dropMsg dragOverMsg =
    [ attribute "droppable" "true"
    , onWithOptions "drop" { preventDefault = True, stopPropagation = True } <| Json.succeed <| dropMsg
    , onWithOptions "dragover" { preventDefault = True, stopPropagation = True } <| Json.succeed <| dragOverMsg
    ]
