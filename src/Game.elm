module Game exposing
    ( Card
    , Face(..)
    , Game
    , Turn(..)
    , fromDeck
    , hideMismatch
    , isPair
    , isWon
    , new
    , reveal
    )

{-| As regras do jogo da memória, sem nenhuma parte visual.

Tudo aqui é função pura: recebe um jogo e devolve outro. Isso permite
testar as regras sem abrir o navegador (veja `tests/GameTest.elm`).

Cada carta pertence a um grupo (`'a'` a `'h'`) e é o membro 1 ou 2 dele.
No tema dos animais, o grupo é a espécie e o membro é o macho ou a fêmea.
A regra que diferencia este jogo do tradicional fica em `isPair`: duas
cartas formam par quando são do mesmo grupo e membros diferentes, e não
quando são iguais.

-}

import Rng exposing (Seed)


type alias Game =
    { cards : List Card
    , turn : Turn
    , moves : Int
    }


type alias Card =
    { id : Int
    , group : Char
    , member : Int
    , face : Face
    }


type Face
    = FaceDown
    | FaceUp
    | Matched


{-| Em que ponto da jogada estamos. Os `Int` são os `id` das cartas viradas.

`Mismatch` dura até a interface chamar `hideMismatch`. Enquanto isso, os
cliques são ignorados para o jogador ver as duas cartas.

-}
type Turn
    = Waiting
    | OnePicked Int
    | Mismatch Int Int


{-| Embaralha as cartas e começa um jogo. Devolve também a semente seguinte,
para a próxima partida sair diferente.
-}
new : Seed -> ( Game, Seed )
new seed =
    let
        ( deck, nextSeed ) =
            Rng.shuffle seed fullDeck
    in
    ( fromDeck deck, nextSeed )


{-| Começa um jogo com as cartas nesta ordem, todas viradas para baixo.
-}
fromDeck : List ( Char, Int ) -> Game
fromDeck deck =
    { cards = List.indexedMap toCard deck
    , turn = Waiting
    , moves = 0
    }


{-| Oito grupos com dois membros cada: as 16 cartas do tabuleiro 4 × 4.
-}
fullDeck : List ( Char, Int )
fullDeck =
    List.concatMap (\group -> [ ( group, 1 ), ( group, 2 ) ]) (String.toList "abcdefgh")


toCard : Int -> ( Char, Int ) -> Card
toCard id ( group, member ) =
    { id = id, group = group, member = member, face = FaceDown }


{-| Mesmo grupo, membros diferentes.
-}
isPair : Card -> Card -> Bool
isPair a b =
    a.group == b.group && a.member /= b.member


{-| Vira a carta com este `id`. Cartas que já estão viradas são ignoradas.
-}
reveal : Int -> Game -> Game
reveal id game =
    case findCard id game of
        Just card ->
            if card.face == FaceDown then
                pick card game

            else
                game

        Nothing ->
            game


pick : Card -> Game -> Game
pick card game =
    case game.turn of
        Waiting ->
            { game | cards = setFace FaceUp [ card.id ] game.cards, turn = OnePicked card.id }

        OnePicked firstId ->
            let
                paired =
                    case findCard firstId game of
                        Just first ->
                            isPair first card

                        Nothing ->
                            False
            in
            if paired then
                { game
                    | cards = setFace Matched [ firstId, card.id ] game.cards
                    , turn = Waiting
                    , moves = game.moves + 1
                }

            else
                { game
                    | cards = setFace FaceUp [ card.id ] game.cards
                    , turn = Mismatch firstId card.id
                    , moves = game.moves + 1
                }

        Mismatch _ _ ->
            game


{-| Desvira as duas cartas que não formaram par.
-}
hideMismatch : Game -> Game
hideMismatch game =
    case game.turn of
        Mismatch a b ->
            { game | cards = setFace FaceDown [ a, b ] game.cards, turn = Waiting }

        _ ->
            game


isWon : Game -> Bool
isWon game =
    List.all (\card -> card.face == Matched) game.cards


findCard : Int -> Game -> Maybe Card
findCard id game =
    List.head (List.filter (\card -> card.id == id) game.cards)


setFace : Face -> List Int -> List Card -> List Card
setFace face ids cards =
    List.map
        (\card ->
            if List.member card.id ids then
                { card | face = face }

            else
                card
        )
        cards
