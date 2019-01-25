module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, input, button, ul, li)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)


---- MODEL ----


type alias Model =
    { post : String
    , allPosts : List String
     }

init : ( Model, Cmd Msg )
init =
    ( { post = "", allPosts = []}, Cmd.none )



---- UPDATE ----


type Msg
    = AddPost String
    | EditText String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
    AddPost newPost ->
        ({ model | allPosts = newPost :: model.allPosts, post = "" }, Cmd.none)
    EditText currentPost ->
        ({model | post = currentPost }, Cmd.none)



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text model.post ]
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


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
