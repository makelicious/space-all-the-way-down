module Main exposing (..)

import Browser
import Http
import Json.Decode exposing (Decoder, field, string, map7)
import Html exposing (Html, text, div, h1, img, input, button, ul, li)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)

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

---- MODEL ----
type alias Flags = String

type FetchState = Failure | Loading | Success

type alias NasaResponse =
    { copyright: String
    , date: String
    , explanation: String
    , hdurl: String
    , media_type: String
    , title: String
    , url: String
    }

type alias Model =
    { post : String
    , allPosts : List String
    , apiUrl : String
    , fetchState: FetchState
    , image : NasaResponse

    }

init : Flags -> ( Model, Cmd Msg )
init config =
    ( { post = "", allPosts = [], apiUrl = config, fetchState = Success, image = initialImage}, Cmd.none)



---- UPDATE ----

fetchImageCmd : Model -> Cmd Msg
fetchImageCmd model = Http.get
    { url = model.apiUrl
    , expect = Http.expectJson FetchImageFinished imageDecoder
    }


imageDecoder : Decoder NasaResponse
imageDecoder =
    map7 NasaResponse
        (field "copyright" string)
        (field "date" string)
        (field "explanation" string)
        (field "hdurl" string)
        (field "media_type" string)
        (field "title" string)
        (field "url" string)





type Msg
    = AddPost String
    | EditText String
    | FetchImage
    | FetchImageFinished (Result Http.Error NasaResponse)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
    AddPost newPost ->
        ({ model | allPosts = newPost :: model.allPosts, post = "" }, fetchImageCmd model)
    EditText currentPost ->
        ({ model | post = currentPost }, Cmd.none)
    FetchImage ->
        Debug.log("FetchImage")
        ({ model | fetchState = Loading }, fetchImageCmd model)
    FetchImageFinished result ->
        Debug.log("FetchImageFinished")
        fetchImageFinished model result

fetchImageFinished : Model -> Result Http.Error NasaResponse -> ( Model, Cmd Msg )
fetchImageFinished model result =
    case result of
        Ok newImage ->
            Debug.log("Success")
            ( { model | image = newImage, fetchState = Success }, Cmd.none)
        Err _ ->
            Debug.log("failure")
            ( { model | fetchState = Failure }, Cmd.none)



---- VIEW ----

view : Model -> Html Msg
view model =
    div []
        [ img [ src model.image.url ] []
        , h1 [] [ text model.apiUrl ]
        ,  Html.form [ onSubmit (AddPost model.post) ]
            [ input [placeholder "Write here", value model.post, onInput EditText ] []
            ,  button [] [text "Add"]
            ]
        , div [] [ul [] (List.map listPosts model.allPosts)
        ]
        ]

listPosts : String -> Html msg
listPosts post =
        li [] [text post]


---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
