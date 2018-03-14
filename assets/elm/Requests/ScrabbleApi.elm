module Requests.ScrabbleApi exposing (getScore)

import Data.ScrabblePlay as Play exposing (Play, encode)
import Http
import Json.Decode as Decode
import Responses.Scrabble as ScrabbleResponse exposing (ScrabbleResponse)


api : String
api =
    "http://localhost:4000/api/scrabble"


post : String -> Http.Body -> Decode.Decoder a -> Http.Request a
post url body decoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


getScore : Play -> Http.Request ScrabbleResponse
getScore play =
    let
        jsonBody =
            Play.encode play
                |> Http.jsonBody
    in
    ScrabbleResponse.decoder
        |> Http.post api jsonBody
