port module Main exposing (..)
import Browser
import Http
import Time exposing (..)
import Task

import Json.Decode as Decode exposing (Decoder, field, string, map7)
import Json.Encode as Encode exposing (..)

import Css exposing (..)
import Html.Styled  exposing (..)
import Html.Styled.Attributes exposing (css, value)
import Html.Styled.Events exposing (onInput, onSubmit)

---- PROGRAM ----

main : Program Flags Model Msg
main =
    Browser.element
        { view = view >> toUnstyled
        , init = init
        , update = update
        , subscriptions = subscriptions
        }

api : Flags -> String
api flags =
    flags.apiUrl

---- SUBSCRIPTIONS ----

subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick

---- PORTS ----

port savePost : String -> Cmd msg
port saveImage : Encode.Value -> Cmd msg

-- ---- MODEL ----

type alias NasaResponse =
    { copyright: String
    , date: String
    , explanation: String
    , hdurl: String
    , media_type: String
    , title: String
    , url: String
    }

initialImage : NasaResponse
initialImage =
    { copyright = ""
    , date = ""
    , explanation = ""
    , hdurl = ""
    , media_type = ""
    , title = ""
    , url = ""
    }


type alias Flags =
    { apiUrl: String
    , cachedImage: Maybe NasaResponse
    , cachedTodos: Maybe (List String)
    }

type FetchState = Failure | Loading | Success

type alias Model =
    { post : String
    , allPosts : List String
    , apiUrl : String
    , fetchState: FetchState
    , image : NasaResponse
    , time : Time.Posix
    , zone : Time.Zone
    }

init : Flags -> ( Model, Cmd Msg )
init config =
    (
        { post = ""
        , allPosts = Maybe.withDefault [] config.cachedTodos
        , apiUrl = config.apiUrl
        , fetchState = Success
        , image = Maybe.withDefault initialImage config.cachedImage
        , time = Time.millisToPosix 0
        , zone = Time.utc
        }
        , Cmd.batch[Task.perform AdjustTimeZone Time.here,
                    fetchImageCmd config]
    )

---- UPDATE ----

fetchImageCmd : Flags -> Cmd Msg
fetchImageCmd flags =
    case flags.cachedImage of
        Nothing ->
            Http.get
                { url = flags.apiUrl
                , expect = Http.expectJson FetchImageFinished imageDecoder
                }
        Just _ ->
            Cmd.none


imageDecoder : Decoder NasaResponse
imageDecoder =
    map7 NasaResponse
        (field "copyright" Decode.string)
        (field "date" Decode.string)
        (field "explanation" Decode.string)
        (field "hdurl" Decode.string)
        (field "media_type" Decode.string)
        (field "title" Decode.string)
        (field "url" Decode.string)

imageEncoder : NasaResponse -> Encode.Value
imageEncoder nasaResponse = Encode.object
                [ ("copyright", Encode.string nasaResponse.copyright)
                , ("date", Encode.string nasaResponse.date)
                , ("explanation", Encode.string nasaResponse.explanation)
                , ("hdurl", Encode.string nasaResponse.hdurl)
                , ("media_type", Encode.string nasaResponse.media_type)
                , ("title", Encode.string nasaResponse.title)
                , ("url", Encode.string nasaResponse.url)
                ]

type Msg
    = AddPost String
    | EditText String
    | Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | FetchImageFinished (Result Http.Error NasaResponse)




update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
    Tick newTime ->
        ( { model | time = newTime}, Cmd.none)
    AdjustTimeZone newZone ->
        ( { model | zone = newZone}, Cmd.none)
    AddPost newPost ->
        ({ model | allPosts = newPost :: model.allPosts, post = "" }, savePost newPost)
    EditText currentPost ->
        ({ model | post = currentPost }, Cmd.none)
    FetchImageFinished result ->
        Debug.log("FetchImageFinished")
        fetchImageFinished model result



fetchImageFinished : Model -> Result Http.Error NasaResponse -> ( Model, Cmd Msg )
fetchImageFinished model result =
    case result of
        Ok newImage ->
            Debug.log("Success")
            ( { model | image = newImage, fetchState = Success }, saveImage (imageEncoder newImage))
        Err _ ->
            Debug.log("failure")
            ( { model | fetchState = Failure }, Cmd.none)



---- VIEW ----

view : Model -> Html Msg
view model =
    background model


background : Model -> Html Msg
background model =
    let
        hour = String.fromInt (Time.toHour model.zone model.time)
        minute = String.fromInt (Time.toMinute model.zone model.time)

    in
    div [css
            [ backgroundImage (url model.image.url)
            , width (pct 100)
            , height (pct 100)
            , backgroundRepeat noRepeat
            , displayFlex
            , justifyContent center
            , alignItems center
            , backgroundSize cover
            , flexDirection column
            ]
        ]
        [div [] [
            h1
                [css
                    [fontSize (px 64)]
                ]
                [text (hour ++  ":" ++ minute)]
            ,h1 [] [text "Morjesta Pöytään"]
        ]
        , form [onSubmit (AddPost model.post)]
            [ input [
                ( css
                    [ backgroundColor (rgba 0 0 0 0)
                    , borderStyle none
                    , focus [borderStyle none]
                    , height (px 60)
                    , width (px 600)
                    , color (hex "fafafa")
                    , borderBottom3 (px 1) solid (hex "ffffff")
                    , fontSize (px 48)
                    ]
                )
                , value model.post, onInput EditText][]]
            , div
                [ css
                    [ marginTop (px 20)
                    , height (px 200)
                    , overflowY scroll
                    , width (px 600)
                    ]
                ]
                [
                ul [css [listStyle none
                        , margin (px 0)
                        , padding (px 0)

                ]] (List.map listPosts model.allPosts)
            ]
        ]

listPosts : String -> Html msg
listPosts post =
        li
            [ css
                [ margin (px 0)
                , padding (px 0)
                , fontSize (px 24)
                ]
            ]
            [text post]
