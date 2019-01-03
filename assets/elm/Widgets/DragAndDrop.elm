module Widgets.DragAndDrop exposing (Config, draggable, droppable)

import Html exposing (..)
import Html.Attributes exposing (attribute)
import Html.Events exposing (custom, on)
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
    , custom "drop" <| Json.succeed { message = dropMsg, preventDefault = True, stopPropagation = True }
    , custom "dragover" <| Json.succeed { message = dragOverMsg, preventDefault = True, stopPropagation = True }
    ]
