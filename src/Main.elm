module Main exposing (main)

{-| Ponto de entrada: liga as regras de `Game` à tela, seguindo a Arquitetura
Elm (modelo, mensagens, `update` e `view`).
-}

import Browser
import Game exposing (Card, Face(..), Game, Turn(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Process
import Rng exposing (Seed)
import Task


{-| O JavaScript passa um número aleatório como semente (veja `src/main.js`).
-}
type alias Flags =
    Int


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODELO


type alias Model =
    { game : Game
    , seed : Seed
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( newModel (Rng.seed flags), Cmd.none )


newModel : Seed -> Model
newModel seed =
    let
        ( game, nextSeed ) =
            Game.new seed
    in
    { game = game, seed = nextSeed }



-- ATUALIZAÇÃO


type Msg
    = CardClicked Int
    | MismatchTimeout
    | NewGameClicked


{-| Tempo, em milissegundos, que as duas cartas erradas ficam à mostra.
-}
mismatchDelay : Float
mismatchDelay =
    1000


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CardClicked id ->
            let
                game =
                    Game.reveal id model.game
            in
            case ( model.game.turn, game.turn ) of
                -- A jogada acabou de errar: desvira as cartas daqui a pouco.
                ( OnePicked _, Mismatch _ _ ) ->
                    ( { model | game = game }
                    , Task.perform (\_ -> MismatchTimeout) (Process.sleep mismatchDelay)
                    )

                _ ->
                    ( { model | game = game }, Cmd.none )

        MismatchTimeout ->
            ( { model | game = Game.hideMismatch model.game }, Cmd.none )

        NewGameClicked ->
            ( newModel model.seed, Cmd.none )



-- VISUALIZAÇÃO


view : Model -> Html Msg
view model =
    main_ [ class "table" ]
        [ viewBoard model.game
        , viewNewGameButton
        , if Game.isWon model.game then
            viewVictory model.game

          else
            text ""
        ]


viewNewGameButton : Html Msg
viewNewGameButton =
    button
        [ class "fab"
        , type_ "button"
        , onClick NewGameClicked
        , attribute "aria-label" "Novo jogo"
        , title "Novo jogo"
        ]
        []


viewBoard : Game -> Html Msg
viewBoard game =
    ol [ class "board", attribute "aria-label" "Tabuleiro" ]
        (List.map (viewCard game.turn) game.cards)


viewCard : Turn -> Card -> Html Msg
viewCard turn card =
    li [ class "board__slot" ]
        [ button
            [ type_ "button"
            , classList
                [ ( "card", True )
                , ( "card--up", card.face /= FaceDown )
                , ( "card--matched", card.face == Matched )
                , ( "card--miss", isMissed turn card )
                ]
            , onClick (CardClicked card.id)
            , disabled (card.face /= FaceDown)
            , attribute "aria-label" (cardLabel card)
            ]
            [ span [ class "card__inner" ]
                [ span [ class "card__back" ] []
                , span [ class "card__front" ]
                    [ img [ class "card__image", src (imagePath card), alt "" ] [] ]
                ]
            ]
        ]


{-| Pasta das imagens das cartas, dentro de `public/`. Para usar outro
conjunto, ponha os arquivos `a1` a `h2` numa pasta nova e troque aqui.
-}
cardsFolder : String
cardsFolder =
    "cards/ia/"


cardsExtension : String
cardsExtension =
    ".webp"


{-| Caminho da imagem da carta, como `cards/ia/a1.webp`.
-}
imagePath : Card -> String
imagePath card =
    cardsFolder ++ String.fromChar card.group ++ String.fromInt card.member ++ cardsExtension


isMissed : Turn -> Card -> Bool
isMissed turn card =
    case turn of
        Mismatch a b ->
            card.id == a || card.id == b

        _ ->
            False


cardLabel : Card -> String
cardLabel card =
    let
        position =
            "Carta " ++ String.fromInt (card.id + 1)
    in
    case card.face of
        FaceDown ->
            position

        FaceUp ->
            position ++ ", aberta"

        Matched ->
            position ++ ", par encontrado"


viewVictory : Game -> Html Msg
viewVictory game =
    div [ class "overlay" ]
        [ node "dialog"
            [ class "victory", attribute "open" "", attribute "aria-labelledby" "victory-title" ]
            [ h2 [ id "victory-title", class "victory__title" ] [ text "Parabéns!" ]
            , p [ class "victory__text" ] [ text (String.fromInt game.moves ++ " jogadas") ]
            , button [ class "button button--primary", type_ "button", onClick NewGameClicked, autofocus True ]
                [ text "Jogar de novo" ]
            ]
        ]
