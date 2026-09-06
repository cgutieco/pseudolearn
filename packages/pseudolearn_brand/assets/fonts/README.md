# Caras tipográficas de este paquete

Las dos caras exactas de las que `pseudolearn_brand` contornea el logotipo:

| archivo                    | familia y peso        | de dónde sale                                  |
|----------------------------|-----------------------|------------------------------------------------|
| `IBMPlexMono-Medium.ttf`   | IBM Plex Mono Medium  | «Pseudo», la mitad monoespaciada del logotipo  |
| `IBMPlexSans-Bold.ttf`     | IBM Plex Sans Bold    | «Learn», la mitad en prosa del logotipo        |

Ambas están bajo **SIL Open Font License 1.1**, que permite empaquetarlas y derivar contornos de ellas.

Viven aquí, y no se leen de `apps/pseudolearn_app/assets/fonts/`, para que el motor de marca no dependa
de los activos de una aplicación. El porqué está en §4.2 del `README.md` de este paquete. Los bytes de
ambas copias se comparan en cada verificación (`BRAND-FONT-DRIFT`), así que no pueden divergir en
silencio.
