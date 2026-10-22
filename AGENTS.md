# Memória dos Casais

Jogo da memória educacional em Elm para ensinar programação funcional. O par
é formado por similaridade (no tema pronto, macho e fêmea da mesma espécie), não por cartas
iguais. Visão geral e arquitetura no `README.md`.

## Idioma

Nível 1 do ADR 0002 do tooling-root:

- A conversa com o humano é sempre em português.
- Português em documentos, comentários, docstrings e mensagens de commit.
- Identificadores em inglês. Textos mostrados ao jogador ficam em português.

## Comandos

O gerenciador de pacotes é o pnpm.

- `pnpm dev`: servidor com hot reload.
- `pnpm test`: testes com elm-test.
- `pnpm check`: formatação, testes e build. Define "pronto".

## Regras do projeto

- `src/Game.elm` e `src/Main.elm` são o código que os
  alunos leem e escrevem. Mantenha-os curtos e sem truques: só `elm/core`,
  `elm/html` e `elm/browser`, sem JSON, portas ou `Http`.
- `src/Rng.elm`, `src/styles/` e `public/cards/` são infraestrutura
  fornecida e podem ter mais complexidade.
- Efeitos visuais ficam no CSS. O Elm só escolhe classes.
- O layout assume o tabuleiro 4 × 4 com 16 cartas, em arquivos fixos
  `a1` a `h2`. Cada conjunto de imagens fica numa pasta de `public/cards/`,
  escolhida por `cardsFolder` e `cardsExtension` em `src/Main.elm`. A origem
  e a licença de cada imagem ficam num `CREDITS.md` na mesma pasta; só
  entram imagens de domínio público.
- Estética de mesa de jogo: feltro verde, cartas de papel-cartão, tons de
  vinho e creme, fontes Alegreya e Alegreya Sans. Sem neon, brilho ou
  degradês chamativos.
